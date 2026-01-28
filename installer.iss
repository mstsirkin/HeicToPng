[Setup]
AppName=HEIC to PNG Converter
AppVersion=1.0.3
CloseApplications=force
AppPublisher=
AppPublisherURL=
DefaultDirName={autopf}\HeicToPng
DefaultGroupName=HEIC to PNG Converter
OutputBaseFilename=HeicToPng-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
OutputDir=installer-output
UninstallDisplayIcon={app}\HeicToPng.dll
DisableProgramGroupPage=yes
DisableDirPage=yes

[Files]
Source: "HeicToPng\bin\x64\Release\HeicToPng.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "HeicToPng\bin\x64\Release\SharpShell.dll"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{dotnet4064}\regasm.exe"; Parameters: "/codebase ""{app}\HeicToPng.dll"""; Flags: runhidden; StatusMsg: "Registering shell extension..."

[UninstallRun]
Filename: "{dotnet4064}\regasm.exe"; Parameters: "/unregister ""{app}\HeicToPng.dll"""; Flags: runhidden; RunOnceId: "UnregisterShellExt"

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Restart Explorer after uninstall to ensure extension is unloaded
    Exec(ExpandConstant('{win}\explorer.exe'), '', '', SW_SHOW, ewNoWait, ResultCode);
  end;
end;
