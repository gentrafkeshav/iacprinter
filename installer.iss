[Setup]
AppName=IACPrinter
AppVersion=1.0.0
DefaultDirName={autopf}\IACPrinter
DefaultGroupName=IACPrinter
OutputDir=Output
OutputBaseFilename=IACPrinter_Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdir

[Icons]
Name: "{group}\IACPrinter"; Filename: "{app}\iacprinter.exe"
Name: "{commondesktop}\IACPrinter"; Filename: "{app}\iacprinter.exe"

[Run]
Filename: "{app}\iacprinter.exe"; Description: "Launch IACPrinter"; Flags: postinstall nowait skipifsilent
