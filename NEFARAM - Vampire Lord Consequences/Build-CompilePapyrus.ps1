$ErrorActionPreference = 'Stop'

$compiler = '<game-install>\Papyrus Compiler\PapyrusCompiler.exe'
$source = '<user-home>\nefaram-files\NEFARAM - Vampire Lord Consequences\Source\Scripts'
$output = '<mo2-root>\mods\NEFARAM - Vampire Lord Consequences\Scripts'
$vanilla = '<temporary>\skyrim-scripts-source\Source\Scripts'
$skse = '<mo2-root>\mods\SKSE\Scripts\Source'
$flags = '<game-install>\Data\Scripts\Source\TESV_Papyrus_Flags.flg'
if (!(Test-Path -LiteralPath $flags)) {
  $flags = '<temporary>\skyrim-scripts-source\Source\Scripts\TESV_Papyrus_Flags.flg'
}

New-Item -ItemType Directory -Force -Path $output | Out-Null
& $compiler 'NVLC_Controller.psc' "-i=$source;$skse;$vanilla" "-o=$output" "-f=$flags"
if ($LASTEXITCODE -ne 0) {
  throw "Papyrus compiler failed with exit code $LASTEXITCODE"
}
