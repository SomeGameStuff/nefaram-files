$ErrorActionPreference = 'Stop'

$compiler = 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$source = 'C:\Users\antho\nefaram-files\NEFARAM - Vampire Lord Consequences\Source\Scripts'
$output = 'C:\Games\nefaram\mods\NEFARAM - Vampire Lord Consequences\Scripts'
$vanilla = 'C:\tmp\skyrim-scripts-source\Source\Scripts'
$skse = 'C:\Games\nefaram\mods\SKSE\Scripts\Source'
$flags = 'C:\games\steamapps\common\Skyrim Special Edition\Data\Scripts\Source\TESV_Papyrus_Flags.flg'
if (!(Test-Path -LiteralPath $flags)) {
  $flags = 'C:\tmp\skyrim-scripts-source\Source\Scripts\TESV_Papyrus_Flags.flg'
}

New-Item -ItemType Directory -Force -Path $output | Out-Null
& $compiler 'NVLC_Controller.psc' "-i=$source;$skse;$vanilla" "-o=$output" "-f=$flags"
if ($LASTEXITCODE -ne 0) {
  throw "Papyrus compiler failed with exit code $LASTEXITCODE"
}
