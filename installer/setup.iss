; Magic Trackpad for Windows - v0.1.0
; UI-language auto detection + bilingual user-safe driver removal.
; dev.5.3 destructive lifecycle remains the validated safety reference.
; x64 Windows 11 stable-release gate.

#ifndef RepoRoot
  #define RepoRoot ".."
#endif

#ifndef RuntimeZip
  #define RuntimeZip "..\out\installer-runtime\MagicTrackpadSetupPayload.zip"
#endif

#ifndef OutputDir
  #define OutputDir "..\out\installer"
#endif

#define MyAppName "Magic Trackpad for Windows"
#define MyAppVersion "0.1.0"
#define MyAppExeName "AmtPtpControlPanel.exe"

[Setup]
AppId={{A7CB31F4-1DB4-4CBA-A392-4F7AC39F34C4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf}\Magic Trackpad for Windows
DefaultGroupName=Magic Trackpad for Windows
DisableProgramGroupPage=yes
DisableDirPage=no
DisableReadyPage=yes
UsePreviousAppDir=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64os
ArchitecturesInstallIn64BitMode=x64os
MinVersion=10.0.22000
Compression=lzma2
SolidCompression=yes
WizardStyle=modern dynamic windows11
OutputDir={#OutputDir}
OutputBaseFilename=MagicTrackpad-for-Windows-Setup-{#MyAppVersion}-x64
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
CloseApplications=yes
RestartIfNeededByRun=no
ShowLanguageDialog=no
LanguageDetectionMethod=uilanguage
UsePreviousLanguage=yes
SetupLogging=yes

[Languages]
; English MUST remain first: unsupported UI languages fall back to English.
Name: "english"; MessagesFile: "compiler:Default.isl"; InfoBeforeFile: "{#RepoRoot}\installer\INFO_BEFORE.en.txt"
#ifdef ChineseMessagesFile
Name: "chinesesimp"; MessagesFile: "{#ChineseMessagesFile}"; InfoBeforeFile: "{#RepoRoot}\installer\INFO_BEFORE.zh-CN.txt"
#endif


[Messages]
english.WizardInfoBefore=Installation Information
chinesesimp.WizardInfoBefore=安装说明

english.InfoBeforeLabel=Please review the following before continuing.
chinesesimp.InfoBeforeLabel=安装前请确认以下事项。

english.InfoBeforeClickLabel=When you are ready, click Next to choose the installation folder.
chinesesimp.InfoBeforeClickLabel=确认后点击“下一步”选择安装位置。

english.SelectDirBrowseLabel=Click Browse to choose a different folder. When ready, click Install.
chinesesimp.SelectDirBrowseLabel=如需更改安装位置，请点击“浏览”。确认后点击“安装”。

[CustomMessages]
english.ShortcutControlPanel=Magic Trackpad Control Panel
chinesesimp.ShortcutControlPanel=Magic Trackpad 控制面板

english.ShortcutTouchpadSettings=Windows Touchpad Settings
chinesesimp.ShortcutTouchpadSettings=Windows 触摸板设置

english.ShortcutDiagnostics=Generate Diagnostic Report
chinesesimp.ShortcutDiagnostics=生成诊断报告

english.ShortcutLogs=Open Diagnostic Logs Folder
chinesesimp.ShortcutLogs=打开诊断日志文件夹

english.ShortcutUninstall=Uninstall Magic Trackpad for Windows
chinesesimp.ShortcutUninstall=卸载 Magic Trackpad for Windows

english.RunControlPanel=Open Magic Trackpad Control Panel
chinesesimp.RunControlPanel=打开 Magic Trackpad 控制面板

english.DriverPreparing=Checking and preparing the Magic Trackpad driver...
chinesesimp.DriverPreparing=正在检查并准备 Magic Trackpad 驱动...

english.PowerShellLaunchFailed=Unable to start Windows PowerShell for the driver installation check.
chinesesimp.PowerShellLaunchFailed=无法启动 Windows PowerShell 来执行驱动安装检查。

english.DriverGateFailed=Driver installation check failed. Setup has stopped. Exit code: %1
chinesesimp.DriverGateFailed=驱动安装检查未通过，安装程序已停止。退出代码：%1

english.DriverLogDirectory=Diagnostic log directory: %1
chinesesimp.DriverLogDirectory=诊断日志目录：%1

english.DriverGateSafety=This version will not automatically clean older drivers, downgrade newer drivers, or resolve multiple matching driver packages.
chinesesimp.DriverGateSafety=当前版本不会自动清理旧驱动、降级新驱动或处理多个残留驱动包。

english.DriverPrepareException=An error occurred while preparing the driver installation: %1
chinesesimp.DriverPrepareException=准备驱动安装时发生错误：%1

english.UninstallChoice=Would you also like to remove the Magic Trackpad driver?%n%nYes: remove the application and the Magic Trackpad driver.%nNo: remove the application only and keep the driver (recommended).%nCancel: exit Uninstall.%n%nDriver removal backs up the exact matching package first and does not remove other Apple, iPhone, or Apple Mobile Device drivers.
chinesesimp.UninstallChoice=是否同时移除 Magic Trackpad 驱动？%n%n是：卸载程序并同时移除 Magic Trackpad 驱动。%n否：仅卸载程序并保留驱动（推荐）。%n取消：退出卸载。%n%n移除驱动前会先备份精确匹配的驱动包，不会删除其他 Apple、iPhone 或 Apple Mobile Device 驱动。

english.UninstallRemovalSuccess=The Magic Trackpad driver is no longer installed.%n%nA backup was kept under:%n%1%n%nThe application will now be uninstalled.
chinesesimp.UninstallRemovalSuccess=Magic Trackpad 驱动已不再安装。%n%n驱动备份保存在：%n%1%n%n现在将继续卸载程序。

english.UninstallRemovalConnected=A Magic Trackpad is currently connected.%n%nTurn it off or disconnect USB, then run Uninstall again if you want to remove the driver.%n%nThe driver has been kept.%n%nContinue uninstalling the application while keeping the driver?
chinesesimp.UninstallRemovalConnected=当前检测到 Magic Trackpad 正在连接使用。%n%n如需移除驱动，请先关闭妙控板或断开 USB，然后重新运行卸载程序。%n%n驱动已保留。%n%n是否继续卸载程序并保留驱动？

english.UninstallRemovalFailed=The Magic Trackpad driver could not be safely removed (exit code %1).%n%nThe driver has been kept. Review the technical log before trying again.%n%nContinue uninstalling the application while keeping the driver?
chinesesimp.UninstallRemovalFailed=无法安全移除 Magic Trackpad 驱动（退出代码 %1）。%n%n驱动已保留。再次尝试前请先检查技术日志。%n%n是否继续卸载程序并保留驱动？

english.UninstallRemovalLaunchFailed=The safe driver-removal tool could not be started.%n%nThe driver has been kept.%n%nContinue uninstalling the application while keeping the driver?
chinesesimp.UninstallRemovalLaunchFailed=无法启动安全驱动移除工具。%n%n驱动已保留。%n%n是否继续卸载程序并保留驱动？

[Dirs]
Name: "{commonappdata}\Magic Trackpad for Windows\Logs"

[Files]
Source: "{#RuntimeZip}"; DestName: "MagicTrackpadSetupPayload.zip"; Flags: dontcopy noencryption
Source: "{#RepoRoot}\installer\Run-SafeInstall.ps1"; DestName: "Run-SafeInstall.ps1"; Flags: dontcopy noencryption

Source: "{#RepoRoot}\third_party\MagicTrackpad2ForWindows-v2.0\AmtPtpControlPanel.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RepoRoot}\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion

Source: "{#RepoRoot}\installer\INFO_BEFORE.en.txt"; DestDir: "{app}"; DestName: "README_FIRST.txt"; Flags: ignoreversion; Languages: english
Source: "{#RepoRoot}\installer\INFO_BEFORE.zh-CN.txt"; DestDir: "{app}"; DestName: "README_FIRST.txt"; Flags: ignoreversion; Languages: chinesesimp

Source: "{#RepoRoot}\build\Release\MagicTrackpadHelper.exe"; DestDir: "{app}\Tools"; Flags: ignoreversion
Source: "{#RepoRoot}\scripts\Collect-Diagnostics.ps1"; DestDir: "{app}\Tools"; Flags: ignoreversion
Source: "{#RepoRoot}\scripts\Get-UninstallPlan.ps1"; DestDir: "{app}\Tools"; Flags: ignoreversion
Source: "{#RepoRoot}\scripts\Invoke-UserSafeDriverUninstall.ps1"; DestDir: "{app}\Tools"; Flags: ignoreversion

[Icons]
Name: "{group}\{cm:ShortcutControlPanel}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:ShortcutTouchpadSettings}"; Filename: "{sys}\cmd.exe"; Parameters: "/c start """" ms-settings:devices-touchpad"; WorkingDir: "{app}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:ShortcutDiagnostics}"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoLogo -NoProfile -ExecutionPolicy Bypass -File ""{app}\Tools\Collect-Diagnostics.ps1"" -HelperPath ""{app}\Tools\MagicTrackpadHelper.exe"" -OpenFolder"; WorkingDir: "{app}\Tools"
Name: "{group}\{cm:ShortcutLogs}"; Filename: "{sys}\explorer.exe"; Parameters: """{commonappdata}\Magic Trackpad for Windows\Logs"""
Name: "{group}\{cm:ShortcutUninstall}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:RunControlPanel}"; Flags: postinstall nowait skipifsilent runascurrentuser

[Code]
var
  UninstallRemoveDriverRequested: Boolean;
  UninstallDriverRemovalRan: Boolean;
  UninstallDriverRemovalExitCode: Integer;
  UninstallDriverRemovalCompleted: Boolean;

procedure InitializeWizard;
begin
  WizardForm.InfoBeforeClickLabel.Visible := False;

  { Keep the Windows stock folder icon, but do not use header coordinates }
  { to place controls that live on a different wizard page surface. }
  WizardForm.SelectDirBitmapImage.Width := ScaleX(32);
  WizardForm.SelectDirBitmapImage.Height := ScaleY(32);
  InitializeBitmapImageFromStockIcon(WizardForm.SelectDirBitmapImage, SIID_FOLDER, clNone, [16, 20, 24, 32, 40, 48, 64]);
end;

procedure LayoutHeader;
begin
  { Page title and subtitle share the same MainPanel coordinate system. }
  WizardForm.PageNameLabel.AdjustHeight;
  WizardForm.PageDescriptionLabel.Left := WizardForm.PageNameLabel.Left;
  WizardForm.PageDescriptionLabel.AdjustHeight;
  WizardForm.PageDescriptionLabel.Top :=
    WizardForm.PageNameLabel.Top +
    WizardForm.PageNameLabel.Height +
    ScaleY(8);
end;

procedure LayoutInfoBeforeLocal;
var
  OriginalBottom: Integer;
  ContentTop: Integer;
begin
  { InfoBeforeMemo uses its own page-local coordinate system. }
  OriginalBottom :=
    WizardForm.InfoBeforeMemo.Top + WizardForm.InfoBeforeMemo.Height;

  ContentTop := ScaleY(4);

  WizardForm.InfoBeforeMemo.Top := ContentTop;

  if OriginalBottom - ContentTop > ScaleY(80) then
    WizardForm.InfoBeforeMemo.Height := OriginalBottom - ContentTop;
end;

procedure LayoutSelectDirLocal;
var
  ContentTop: Integer;
  FirstRowHeight: Integer;
begin
  { All controls below use SelectDirPage-local coordinates only. }
  ContentTop := ScaleY(8);

  WizardForm.SelectDirLabel.AdjustHeight;

  if WizardForm.SelectDirBitmapImage.Height > WizardForm.SelectDirLabel.Height then
    FirstRowHeight := WizardForm.SelectDirBitmapImage.Height
  else
    FirstRowHeight := WizardForm.SelectDirLabel.Height;

  WizardForm.SelectDirBitmapImage.Top :=
    ContentTop +
    (FirstRowHeight - WizardForm.SelectDirBitmapImage.Height) div 2;

  WizardForm.SelectDirLabel.Top :=
    ContentTop +
    (FirstRowHeight - WizardForm.SelectDirLabel.Height) div 2;

  WizardForm.SelectDirBrowseLabel.AdjustHeight;
  WizardForm.SelectDirBrowseLabel.Top :=
    ContentTop +
    FirstRowHeight +
    ScaleY(16);

  WizardForm.DirEdit.Top :=
    WizardForm.SelectDirBrowseLabel.Top +
    WizardForm.SelectDirBrowseLabel.Height +
    ScaleY(8);

  WizardForm.DirBrowseButton.Top :=
    WizardForm.DirEdit.Top +
    (WizardForm.DirEdit.Height - WizardForm.DirBrowseButton.Height) div 2;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  { Header controls live together on MainPanel. Page body controls use }
  { their own page-local coordinates. Never mix those coordinate systems. }
  if CurPageID in [wpInfoBefore, wpSelectDir] then
    LayoutHeader;

  if CurPageID = wpInfoBefore then
    LayoutInfoBeforeLocal
  else if CurPageID = wpSelectDir then
    LayoutSelectDirLocal;

  { Ready page is disabled. The destination page is now the final }
  { interactive pre-install page, so label its primary action Install. }
  if CurPageID in [wpSelectDir, wpReady] then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
  else if CurPageID = wpFinished then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish)
  else
    WizardForm.NextButton.Caption := SetupMessage(msgButtonNext);
end;

function BoolToLowerString(Value: Boolean): String;
begin
  if Value then
    Result := 'true'
  else
    Result := 'false';
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  PowerShellPath: String;
  RunnerPath: String;
  PayloadPath: String;
  Params: String;
  ResultCode: Integer;
  Started: Boolean;
  DriverLogDir: String;
begin
  Result := '';
  NeedsRestart := False;

  try
    ExtractTemporaryFile('MagicTrackpadSetupPayload.zip');
    ExtractTemporaryFile('Run-SafeInstall.ps1');

    PowerShellPath := ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe');
    RunnerPath := ExpandConstant('{tmp}\Run-SafeInstall.ps1');
    PayloadPath := ExpandConstant('{tmp}\MagicTrackpadSetupPayload.zip');

    Params :=
      '-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
      RunnerPath +
      '" -PayloadZip "' +
      PayloadPath +
      '"';

    WizardForm.StatusLabel.Caption := CustomMessage('DriverPreparing');

    Started := Exec(
      PowerShellPath,
      Params,
      ExpandConstant('{tmp}'),
      SW_HIDE,
      ewWaitUntilTerminated,
      ResultCode
    );

    if not Started then
    begin
      Result := CustomMessage('PowerShellLaunchFailed');
      exit;
    end;

    if ResultCode <> 0 then
    begin
      DriverLogDir := ExpandConstant('{commonappdata}\Magic Trackpad for Windows\Logs');
      Result := FmtMessage(CustomMessage('DriverGateFailed'), [IntToStr(ResultCode)]) + #13#10 +
        FmtMessage(CustomMessage('DriverLogDirectory'), [DriverLogDir]) + #13#10 +
        CustomMessage('DriverGateSafety');
      exit;
    end;
  except
    Result := FmtMessage(CustomMessage('DriverPrepareException'), [GetExceptionMessage]);
  end;
end;

function RunUserDriverRemoval(var ExitCode: Integer): Boolean;
var
  PowerShellPath: String;
  RemovalScript: String;
  HelperPath: String;
  Params: String;
begin
  Result := False;
  ExitCode := -1;

  PowerShellPath := ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe');
  RemovalScript := ExpandConstant('{app}\Tools\Invoke-UserSafeDriverUninstall.ps1');
  HelperPath := ExpandConstant('{app}\Tools\MagicTrackpadHelper.exe');

  if (not FileExists(RemovalScript)) or (not FileExists(HelperPath)) then
    exit;

  Params :=
    '-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    RemovalScript +
    '" -HelperPath "' +
    HelperPath +
    '"';

  Result := Exec(
    PowerShellPath,
    Params,
    ExpandConstant('{app}\Tools'),
    SW_HIDE,
    ewWaitUntilTerminated,
    ExitCode
  );
end;

procedure WriteUninstallDecisionLog;
var
  LogDir: String;
  LogPath: String;
  Lines: TArrayOfString;
begin
  LogDir := ExpandConstant('{commonappdata}\Magic Trackpad for Windows\Logs');
  if not ForceDirectories(LogDir) then exit;

  LogPath := AddBackslash(LogDir) + 'UninstallDecision-' +
    GetDateTimeString('yyyymmdd-hhnnss', '-', ':') + '.log';

  SetArrayLength(Lines, 8);
  Lines[0] := 'mode=user-uninstall';
  Lines[1] := 'active_language=' + ActiveLanguage;
  Lines[2] := 'remove_driver_requested=' + BoolToLowerString(UninstallRemoveDriverRequested);
  Lines[3] := 'driver_removal_ran=' + BoolToLowerString(UninstallDriverRemovalRan);
  Lines[4] := 'driver_removal_exit_code=' + IntToStr(UninstallDriverRemovalExitCode);
  Lines[5] := 'driver_removal_completed=' + BoolToLowerString(UninstallDriverRemovalCompleted);
  Lines[6] := 'app_uninstall_started=true';
  Lines[7] := 'silent_uninstall=' + BoolToLowerString(UninstallSilent);

  SaveStringsToUTF8FileWithoutBOM(LogPath, Lines, False);
end;

function InitializeUninstall: Boolean;
var
  Choice: Integer;
  ContinueChoice: Integer;
  Started: Boolean;
  FailureMessage: String;
  SuccessMessage: String;
  BackupRoot: String;
begin
  Result := False;
  UninstallRemoveDriverRequested := False;
  UninstallDriverRemovalRan := False;
  UninstallDriverRemovalExitCode := -1;
  UninstallDriverRemovalCompleted := False;

  { Silent uninstall is intentionally non-destructive: keep the driver. }
  if UninstallSilent then
  begin
    Result := True;
    exit;
  end;

  Choice := MsgBox(CustomMessage('UninstallChoice'), mbConfirmation, MB_YESNOCANCEL);
  if Choice = IDCANCEL then exit;

  if Choice = IDYES then
  begin
    UninstallRemoveDriverRequested := True;
    Started := RunUserDriverRemoval(UninstallDriverRemovalExitCode);
    UninstallDriverRemovalRan := Started;

    if not Started then
    begin
      ContinueChoice := MsgBox(CustomMessage('UninstallRemovalLaunchFailed'), mbError, MB_YESNO);
      if ContinueChoice <> IDYES then exit;
    end
    else if UninstallDriverRemovalExitCode = 0 then
    begin
      UninstallDriverRemovalCompleted := True;
      BackupRoot := ExpandConstant('{commonappdata}\Magic Trackpad for Windows\DriverBackup');
      SuccessMessage := FmtMessage(CustomMessage('UninstallRemovalSuccess'), [BackupRoot]);
      MsgBox(SuccessMessage, mbInformation, MB_OK);
    end
    else if UninstallDriverRemovalExitCode = 61 then
    begin
      ContinueChoice := MsgBox(CustomMessage('UninstallRemovalConnected'), mbError, MB_YESNO);
      if ContinueChoice <> IDYES then exit;
    end
    else
    begin
      FailureMessage := FmtMessage(CustomMessage('UninstallRemovalFailed'), [IntToStr(UninstallDriverRemovalExitCode)]);
      ContinueChoice := MsgBox(FailureMessage, mbError, MB_YESNO);
      if ContinueChoice <> IDYES then exit;
    end;
  end;

  Result := True;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    WriteUninstallDecisionLog;
end;
