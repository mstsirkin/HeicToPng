using System;
using System.IO;
using System.Windows.Media.Imaging;

namespace HeicToPng
{
    public static class HeicConverter
    {
        public static ConversionResult ConvertToPng(string heicFilePath)
        {
            if (string.IsNullOrEmpty(heicFilePath))
                return new ConversionResult(false, "File path is empty");

            if (!File.Exists(heicFilePath))
                return new ConversionResult(false, $"File not found: {heicFilePath}");

            string directory = Path.GetDirectoryName(heicFilePath);
            string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(heicFilePath);
            string pngFilePath = Path.Combine(directory, fileNameWithoutExtension + ".png");

            // Handle case where PNG already exists
            if (File.Exists(pngFilePath))
            {
                pngFilePath = GetUniqueFilePath(pngFilePath);
            }

            try
            {
                using (var stream = new FileStream(heicFilePath, FileMode.Open, FileAccess.Read, FileShare.Read))
                {
                    // Use WIC to decode the HEIC file
                    // Windows 10 1803+ has built-in HEIC codec support
                    var decoder = BitmapDecoder.Create(
                        stream,
                        BitmapCreateOptions.PreservePixelFormat,
                        BitmapCacheOption.OnLoad);

                    if (decoder.Frames.Count == 0)
                        return new ConversionResult(false, "No image frames found in HEIC file");

                    BitmapFrame frame = decoder.Frames[0];

                    // Create PNG encoder
                    var encoder = new PngBitmapEncoder();
                    encoder.Frames.Add(BitmapFrame.Create(frame));

                    // Save to PNG file
                    using (var outputStream = new FileStream(pngFilePath, FileMode.Create, FileAccess.Write))
                    {
                        encoder.Save(outputStream);
                    }
                }

                return new ConversionResult(true, pngFilePath);
            }
            catch (NotSupportedException)
            {
                return new ConversionResult(false,
                    "HEIC codec not available. Please install 'HEIF Image Extensions' from the Microsoft Store.");
            }
            catch (FileFormatException ex)
            {
                return new ConversionResult(false, $"Invalid or corrupted HEIC file: {ex.Message}");
            }
            catch (Exception ex)
            {
                return new ConversionResult(false, $"Conversion failed: {ex.Message}");
            }
        }

        private static string GetUniqueFilePath(string filePath)
        {
            string directory = Path.GetDirectoryName(filePath);
            string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(filePath);
            string extension = Path.GetExtension(filePath);

            int counter = 1;
            string newPath;
            do
            {
                newPath = Path.Combine(directory, $"{fileNameWithoutExtension} ({counter}){extension}");
                counter++;
            } while (File.Exists(newPath));

            return newPath;
        }
    }

    public class ConversionResult
    {
        public bool Success { get; }
        public string Message { get; }

        public ConversionResult(bool success, string message)
        {
            Success = success;
            Message = message;
        }
    }
}
