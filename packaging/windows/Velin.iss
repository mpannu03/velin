#define MyAppName "Velin"
#define MyAppPublisher "Velin"
#define MyAppExeName "velin.exe"

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{8B9E5F9B-8C9A-4B2D-9A1E-7E5E8C4D3A21}
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

; Refresh Explorer after (un)registering the .pdf handler below.
ChangesAssociations=yes

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

; Offer Velin under "Open with" for PDFs. This does not take over the
; default PDF app; Windows lets the user choose that.
[Registry]
Root: HKA; Subkey: "Software\Classes\.pdf\OpenWithProgids"; \
  ValueType: string; ValueName: "Velin.PDF"; ValueData: ""; \
  Flags: uninsdeletevalue

Root: HKA; Subkey: "Software\Classes\Velin.PDF"; \
  ValueType: string; ValueName: ""; ValueData: "PDF Document"; \
  Flags: uninsdeletekey

Root: HKA; Subkey: "Software\Classes\Velin.PDF\DefaultIcon"; \
  ValueType: string; ValueName: ""; ValueData: "{app}\velin.exe,0"

Root: HKA; Subkey: "Software\Classes\Velin.PDF\shell\open\command"; \
  ValueType: string; ValueName: ""; ValueData: """{app}\velin.exe"" ""%1"""

Root: HKA; Subkey: "Software\Classes\Applications\velin.exe\SupportedTypes"; \
  ValueType: string; ValueName: ".pdf"; ValueData: ""; \
  Flags: uninsdeletekey
