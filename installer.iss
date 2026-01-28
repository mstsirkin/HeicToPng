[Setup]
AppName=HEIC to PNG Converter
AppVersion=1.0.2
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
procedure RestartExplorer(Kill: Boolean);
var
  ResultCode: Integer;
begin
  if Kill then
  begin
    Exec(ExpandConstant('{sys}\taskkill.exe'), '/f /im explorer.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Sleep(1000);
  end
  else
  begin
    Exec(ExpandConstant('{win}\explorer.exe'), '', '', SW_SHOW, ewNoWait, ResultCode);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Restart Explorer to load the new extension
    RestartExplorer(True);
    RestartExplorer(False);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    // Kill Explorer BEFORE unregistering and deleting files
    RestartExplorer(True);
  end;

  if CurUninstallStep = usPostUninstall then
  begin
    // Restart Explorer after uninstall is complete
    RestartExplorer(False);
  end;
end;
