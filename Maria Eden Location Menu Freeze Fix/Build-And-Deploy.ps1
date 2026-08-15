[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$source = Join-Path $projectRoot 'Source\Scripts\MariaLocationManager.psc'
$stubs = Join-Path $projectRoot 'build-stubs'
$projectScripts = Join-Path $projectRoot 'Scripts'
$runtime = 'C:\games\nefaram\mods\[NoDelete] Maria Eden Location Menu Freeze Fix'
$runtimeScripts = Join-Path $runtime 'Scripts'

$compiler = 'C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe'
$vanilla = 'C:\Users\antho\nefaram-files\tools\vanilla-source\Source\Scripts'
$skse = 'C:\games\nefaram\mods\SKSE\Scripts\Source'
$papyrusUtil = 'C:\games\nefaram\mods\PapyrusUtil SE - Modders Scripting Utility Functions\Source\Scripts'

foreach ($required in @($source, $stubs, $compiler, $vanilla, $skse, $papyrusUtil)) {
    if (!(Test-Path -LiteralPath $required)) {
        throw "Required path not found: $required"
    }
}

New-Item -ItemType Directory -Force -Path $projectScripts | Out-Null
New-Item -ItemType Directory -Force -Path $runtimeScripts | Out-Null

$include = "$(Split-Path -Parent $source);$stubs;$skse;$papyrusUtil;$vanilla"
$flags = Join-Path $vanilla 'TESV_Papyrus_Flags.flg'

& $compiler $source "-f=$flags" "-i=$include" "-o=$projectScripts"
if ($LASTEXITCODE -ne 0) {
    throw 'Papyrus compilation failed.'
}

$pex = Join-Path $projectScripts 'MariaLocationManager.pex'
if (!(Test-Path -LiteralPath $pex)) {
    throw "Compiler did not create $pex"
}

Copy-Item -LiteralPath $pex -Destination (Join-Path $runtimeScripts 'MariaLocationManager.pex') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination (Join-Path $runtime 'README.md') -Force

Write-Host "Built and deployed: $runtime"
