using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using SharpShell.Attributes;
using SharpShell.SharpContextMenu;

namespace HeicToPng
{
    [ComVisible(true)]
    [COMServerAssociation(AssociationType.ClassOfExtension, ".heic")]
    [COMServerAssociation(AssociationType.ClassOfExtension, ".heif")]
    [Guid("C9E8D7F6-5B4A-3C2D-1E0F-A9B8C7D6E5F4")]
    public class HeicContextMenuHandler : SharpContextMenu
    {
        protected override bool CanShowMenu()
        {
            // Show menu if all selected files are HEIC/HEIF
            return SelectedItemPaths.All(path =>
            {
                string ext = Path.GetExtension(path).ToLowerInvariant();
                return ext == ".heic" || ext == ".heif";
            });
        }

        protected override ContextMenuStrip CreateMenu()
        {
            var menu = new ContextMenuStrip();

            int fileCount = SelectedItemPaths.Count();
            string menuText = fileCount == 1
                ? "Convert to PNG"
                : $"Convert {fileCount} files to PNG";

            var convertItem = new ToolStripMenuItem(menuText)
            {
                Image = null // Could add an icon here
            };
            convertItem.Click += ConvertItem_Click;

            menu.Items.Add(convertItem);

            return menu;
        }

        private void ConvertItem_Click(object sender, EventArgs e)
        {
            var filePaths = SelectedItemPaths.ToList();
            var results = new List<ConversionResult>();
            var successCount = 0;
            var failureCount = 0;
            var errors = new StringBuilder();

            foreach (string filePath in filePaths)
            {
                var result = HeicConverter.ConvertToPng(filePath);
                results.Add(result);

                if (result.Success)
                {
                    successCount++;
                }
                else
                {
                    failureCount++;
                    errors.AppendLine($"{Path.GetFileName(filePath)}: {result.Message}");
                }
            }

            // Show result message
            if (failureCount == 0)
            {
                if (successCount == 1)
                {
                    MessageBox.Show(
                        $"Successfully converted to:\n{results[0].Message}",
                        "Conversion Complete",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show(
                        $"Successfully converted {successCount} files to PNG.",
                        "Conversion Complete",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                }
            }
            else if (successCount == 0)
            {
                MessageBox.Show(
                    $"Conversion failed:\n\n{errors}",
                    "Conversion Failed",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            else
            {
                MessageBox.Show(
                    $"Converted {successCount} of {filePaths.Count} files.\n\nErrors:\n{errors}",
                    "Conversion Partially Complete",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
            }
        }
    }
}
