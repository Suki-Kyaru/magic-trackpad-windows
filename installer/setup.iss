; Magic Trackpad for Windows - v0.1.0-dev.5.3
; Persistent install logging + installed diagnostics tools.
; x64 Windows 11 only.

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
#define MyAppVersion "0.1.0-dev.5.3"
#define MyAppExeName "AmtPtpControlPanel.exe"

[Setup]
AppId={{A7CB31F4-1DB4-4CBA-A392-4F7AC39F34C4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={autopf}\Magic Trackpad for Windows
DefaultGroupName=Magic Trackpad for Windows
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64os
ArchitecturesInstallIn64BitMode=x64os
MinVersion=10.0.22000
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
OutputDir={#OutputDir}
OutputBaseFilename=MagicTrackpad-for-Windows-Setup-{#MyAppVersion}-x64
UninstallDisplayName=Magic Trackpad for Windows（控制面板；驱动保留）
UninstallDisplayIcon={app}\{#MyAppExeName}
InfoBeforeFile={#RepoRoot}\installer\INFO_BEFORE.txt
CloseApplications=yes
RestartIfNeededByRun=no
ShowLanguageDialog=no
SetupLogging=yes

[Languages]
#ifdef ChineseMessagesFile
Name: "chinesesimp"; MessagesFile: "{#ChineseMessagesFile}"
#else
Name: "english"; MessagesFile: "compiler:Default.isl"
#endif

[Messages]
SetupAppTitle=安装
SetupWindowTitle=安装 - %1
InformationTitle=信息
ConfirmTitle=确认
ErrorTitle=错误
ButtonBack=< 上一步(&B)
ButtonNext=下一步(&N) >
ButtonInstall=安装(&I)
ButtonOK=确定
ButtonCancel=取消
ButtonFinish=完成(&F)
ButtonBrowse=浏览(&B)...
WizardInfoBefore=信息
InfoBeforeLabel=请在继续安装前阅读以下重要信息。
InfoBeforeClickLabel=准备好继续安装后，点击“下一步”。
WizardSelectDir=选择安装位置
SelectDirDesc=请选择 [name] 的安装位置。
SelectDirLabel3=安装程序将把 [name] 安装到下列文件夹。
SelectDirBrowseLabel=点击“下一步”继续；如需更改位置，请点击“浏览”。
WizardReady=准备安装
ReadyLabel1=安装程序已准备好将 [name] 安装到您的计算机。
ReadyLabel2a=点击“安装”开始；如需检查或修改设置，请点击“上一步”。
ReadyLabel2b=点击“安装”开始。
ReadyMemoDir=安装位置：
ReadyMemoGroup=开始菜单文件夹：
WizardPreparing=正在准备安装
PreparingDesc=安装程序正在准备安装 [name]。
CannotContinue=安装程序无法继续，请点击“取消”退出。
WizardInstalling=正在安装
InstallingLabel=正在安装 [name]，请稍候。
FinishedHeadingLabel=[name] 安装完成
FinishedLabelNoIcons=[name] 已成功安装到您的计算机。
FinishedLabel=[name] 已成功安装到您的计算机，可通过开始菜单快捷方式启动。
ClickFinish=点击“完成”退出安装程序。
RunEntryExec=运行 %1
StatusCreateDirs=正在创建文件夹...
StatusExtractFiles=正在提取文件...
StatusCreateIcons=正在创建快捷方式...
StatusSavingUninstall=正在保存卸载信息...
StatusRunProgram=正在完成安装...
SetupAborted=安装尚未完成。%n%n请解决问题后重新运行安装程序。
ErrorExecutingProgram=无法执行文件：%n%1

[Dirs]
Name: "{commonappdata}\Magic Trackpad for Windows\Logs"

[Files]
Source: "{#RuntimeZip}"; DestName: "MagicTrackpadSetupPayload.zip"; Flags: dontcopy noencryption
Source: "{#RepoRoot}\installer\Run-SafeInstall.ps1"; DestName: "Run-SafeInstall.ps1"; Flags: dontcopy noencryption

Source: "{#RepoRoot}\third_party\MagicTrackpad2ForWindows-v2.0\AmtPtpControlPanel.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RepoRoot}\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RepoRoot}\installer\INFO_BEFORE.txt"; DestDir: "{app}"; DestName: "README_FIRST.txt"; Flags: ignoreversion

Source: "{#RepoRoot}\build\Release\MagicTrackpadHelper.exe"; DestDir: "{app}\Tools"; Flags: ignoreversion
Source: "{#RepoRoot}\scripts\Collect-Diagnostics.ps1"; DestDir: "{app}\Tools"; Flags: ignoreversion
Source: "{#RepoRoot}\scripts\Get-UninstallPlan.ps1"; DestDir: "{app}\Tools"; Flags: ignoreversion
Source: "{#RepoRoot}\scripts\Invoke-SafeDriverUninstall.ps1"; DestDir: "{app}\Tools"; Flags: ignoreversion

[Icons]
Name: "{group}\Magic Trackpad 控制面板"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Windows 触摸板设置"; Filename: "{sys}\cmd.exe"; Parameters: "/c start """" ms-settings:devices-touchpad"; WorkingDir: "{app}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\生成诊断报告"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoLogo -NoProfile -ExecutionPolicy Bypass -File ""{app}\Tools\Collect-Diagnostics.ps1"" -HelperPath ""{app}\Tools\MagicTrackpadHelper.exe"" -OpenFolder"; WorkingDir: "{app}\Tools"
Name: "{group}\打开诊断日志文件夹"; Filename: "{sys}\explorer.exe"; Parameters: """{commonappdata}\Magic Trackpad for Windows\Logs"""
Name: "{group}\卸载 Magic Trackpad for Windows"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "打开 Magic Trackpad 控制面板"; Flags: postinstall nowait skipifsilent runascurrentuser

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  PowerShellPath: String;
  RunnerPath: String;
  PayloadPath: String;
  Params: String;
  ResultCode: Integer;
  Started: Boolean;
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

    WizardForm.StatusLabel.Caption := '正在检查并准备 Magic Trackpad 驱动...';

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
      Result := '无法启动 Windows PowerShell 来执行驱动安装检查。';
      exit;
    end;

    if ResultCode <> 0 then
    begin
      Result :=
        '驱动安装检查未通过，安装程序已停止。' + #13#10 +
        '退出代码：' + IntToStr(ResultCode) + #13#10 +
        '诊断日志目录：' + ExpandConstant('{commonappdata}\Magic Trackpad for Windows\Logs') + #13#10 +
        '当前版本不会自动清理旧驱动、降级新驱动或处理多个残留驱动包。';
      exit;
    end;
  except
    Result := '准备驱动安装时发生错误：' + GetExceptionMessage;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    MsgBox(
      '当前开发版卸载程序只移除控制面板、工具、文档和快捷方式。' + #13#10 +
      'Magic Trackpad 驱动会保留，不会删除其他 Apple/iPhone 驱动。',
      mbInformation,
      MB_OK
    );
  end;
end;
