#define MyAppName "Velin"
#define MyAppPublisher "Velin"
#define MyAppExeName "velin.exe"

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={8B9E5F9B-8C9A-4B2D-9A1E-7E5E8C4D3A21}
AppName={#MyAppName}
AppVersion={#AppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\Velin
DefaultGroupName=Velin

OutputDir=..\..\dist
OutputBaseFilename=Velin-{#AppVersion}-windows-x64-setup

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

Compression=lzma
SolidCompression=yes

WizardStyle=modern

SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\velin.exe

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; \
  DestDir: "{app}"; \
  Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Velin"; \
  Filename: "{app}\velin.exe"

Name: "{autodesktop}\Velin"; \
  Filename: "{app}\velin.exe"; \
  Tasks: desktopicon

[Tasks]
Name: "desktopicon"; \
  Description: "Create a desktop shortcut"; \
  GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\velin.exe"; \
  Description: "Launch Velin"; \
  Flags: nowait postinstall skipifsilent