$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot
$script:checks = 0
function Assert-Review($condition, [string]$message) {
    $script:checks++
    if (!$condition) { throw "Review regression: $message" }
}
function Function-Body([string]$source, [string]$name) {
    $match = [regex]::Match($source, "(?ims)^\s*(?:(?:Bool|Int|Float|String|GlobalVariable) )?Function $name\([^\r\n]*\)\r?\n(.*?)^EndFunction")
    Assert-Review $match.Success "Missing function $name"
    return $match.Groups[1].Value
}
function Eval-Formula([string]$formula, [int]$tier) {
    Assert-Review ($formula -match '^[0-9.()+* /_tier-]+$') "Unsafe/unrecognized formula: $formula"
    return & ([scriptblock]::Create($formula.Replace('_tier', '$tier')))
}

foreach ($name in @('Doll','Horse','Cow','Rabbit','Troll')) {
    $source = Get-Content -Raw -LiteralPath (Join-Path $root "Source\Scripts\cfl_${name}formEffect.psc")
    $apply = Function-Body $source 'ApplyActorValueChanges'
    $restore = Function-Body $source 'RestoreActorValueChanges'
    $finish = Function-Body $source 'FinishForm'
    $progression = Function-Body $source 'CheckProgression'
    $complete = Function-Body $source 'CompleteTransition'
    Assert-Review ($source -notmatch 'QueueNiNodeUpdate|UnregisterForUpdate\(') "$name rebuilds the skeleton or calls unbound effect natives"
    Assert-Review ($complete -match '_finishRequested \|\| !_running') "$name schedules updates after a requested finish"
    Assert-Review ($finish.IndexOf('RestoreActorValueChanges') -lt $finish.IndexOf('If IsActiveInstance')) "$name makes stat reversal depend on the shared lock"
    Assert-Review ($finish.IndexOf('_finished = true') -lt $finish.IndexOf('RestoreActorValueChanges')) "$name cleanup is not idempotent"
    Assert-Review ($progression -notmatch 'RestoreActorValueChanges') "$name removes its health pool during tier-up"
    Assert-Review ($source -notmatch 'simple_(?:add|remove)_tattoo\([^\r\n]*, true, (?:true|false)') "$name synchronizes inside a tattoo batch"
    Assert-Review ($source -match 'GetTimeElapsed\(\)' -and $source -notmatch 'GetValue\(\) \+ UpdateSeconds') "$name progression uses nominal polling time"
    Assert-Review ($source -match 'BodymorphAlterations.Recovering') "$name ignores recovery exclusion"
    Assert-Review ((Function-Body $source 'BeginActiveForm') -match 'controller.ClaimActiveForm') "$name bypasses serialized lock acquisition"
    if ($name -ne 'Rabbit') {
        Assert-Review ($source -match 'zad_DeviousDevice' -and $source -match 'zad_Lockable') "$name strips rendered/locked DD gear"
    }

    # Evaluate the actual source formulas across tier changes and third-party AV
    # changes. Check each contribution telescopes to zero, including fire suppression.
    $stats = [regex]::Matches($apply, 'akActor.ModActorValue\("([^"]+)", \(([^\r\n]+)\) - (_\w+)\)')
    Assert-Review ($stats.Count -gt 0) "$name has no delta-based stats"
    foreach ($stat in $stats) {
        $av = $stat.Groups[1].Value
        $formula = $stat.Groups[2].Value
        $field = $stat.Groups[3].Value
        Assert-Review ($restore -match [regex]::Escape("ModActorValue(`"$av`", -$field)")) "$name doesn't reverse $av"
        Assert-Review ($restore -match [regex]::Escape("$field = 0.0")) "$name doesn't clear its $av bookkeeping"
        foreach ($suppressed in @($false, $true)) {
            $value = 1000.0
            $owned = 0.0
            foreach ($tier in @(0,1,2,3,4,4,2,0)) {
                $next = Eval-Formula $formula $tier
                if (!($suppressed -and $av -eq 'HealRate')) { $value += $next - $owned }
                $owned = $next
                # Simulate another mod adding a contribution during the form.
                if ($tier -eq 3) { $value += 7.0 }
            }
            if (!($suppressed -and $av -eq 'HealRate')) { $value -= $owned }
            Assert-Review ([Math]::Abs($value - 1007.0) -lt 0.001) "$name leaks or erases $av (suppressed=$suppressed)"
        }
    }
}
$troll = Get-Content -Raw -LiteralPath (Join-Path $root 'Source\Scripts\cfl_TrollformEffect.psc')
Assert-Review ($troll -match '_weaponSpeedMod = -0.15' -and $troll -notmatch '_weaponSpeedMod = -15.0') 'Troll weapon speed uses percentage units'
Assert-Review ($troll -match 'Event OnMagicEffectApply' -and $troll -match '_fireUntilElapsed = GetTimeElapsed\(\) \+ 10.0') 'Troll fire handling misses spell effects or uses a polling counter'
$mcm = Get-Content -Raw -LiteralPath (Join-Path $root 'Source\Scripts\cfl_DollformMCM.psc')
$recovery = Function-Body $mcm 'RunFormRecovery'
$claim = Function-Body $mcm 'ClaimActiveForm'
Assert-Review ($claim.IndexOf('_claimBusy = true') -lt $claim.IndexOf('GetValueInt()')) 'Form acquisition yields before reserving its controller guard'
Assert-Review ($recovery -notmatch 'RemoveActiveFormTattoos|RestoreBaseHairColor|RemoveCowHorns|SetValue\(0\)') 'Recovery destroys progression, personal cosmetics, or a live lock'
Assert-Review ($recovery -match 'WaitMenuMode' -and $recovery -match 'activeForm > 5') 'Recovery does not wait or can steal Feral ownership'
Assert-Review ((Function-Body $mcm 'ClearActiveLock') -match 'RunFormRecovery') 'Unsafe raw lock-clear action remains'
Assert-Review ($mcm -match 'Function OnVersionUpdate' -and $mcm -match 'Return 20261024') 'MCM update migration is missing'

# A lowered debug tier must survive the next progression update at every scale.
$setTier = Function-Body $mcm 'SetTier'
$counterMap = Function-Body $mcm 'UseCounterForTier'
$tierTime = Function-Body $mcm 'UseSecondsForTier'
Assert-Review ($setTier -match 'useCounter.SetValue\(UseSecondsForTier\(aiTier\)\)') 'Debug tier edits leave the old timer in place'
$tierTimes = @{0=0.0}
foreach ($match in [regex]::Matches($tierTime, '(?:If|ElseIf) aiTier (?:==|>=) ([1-4])\r?\n\s*seconds = ([0-9.]+)')) {
    $tierTimes[[int]$match.Groups[1].Value] = [double]::Parse($match.Groups[2].Value,[Globalization.CultureInfo]::InvariantCulture)
}
Assert-Review ($tierTimes.Count -eq 5) 'Debug tier timing table is incomplete'
foreach ($name in @('Doll','Horse','Cow','Rabbit','Troll')) {
    Assert-Review ($counterMap -match "akTier == cfl_${name}formMarkTier\r?\n\s*Return cfl_${name}formUseSeconds") "$name debug edit targets the wrong timer"
    $formSource = Get-Content -Raw -LiteralPath (Join-Path $root "Source\Scripts\cfl_${name}formEffect.psc")
    $poll = [double]([regex]::Match($formSource, 'Property UpdateSeconds = ([0-9.]+)').Groups[1].Value)
    $thresholds = @{}
    foreach ($match in [regex]::Matches($formSource, 'Property Tier([1-4])Seconds = ([0-9.]+)')) { $thresholds[[int]$match.Groups[1].Value] = [double]$match.Groups[2].Value }
    foreach ($scale in @(0.25,0.5,1.0,2.0,4.0)) {
        foreach ($selectedTier in 0..4) {
            $afterNextUpdate = ($tierTimes[$selectedTier] * $scale) + $poll
            $resultTier = 0
            foreach ($candidateTier in 1..4) { if ($afterNextUpdate -ge $thresholds[$candidateTier] * $scale) { $resultTier = $candidateTier } }
            Assert-Review ($resultTier -eq $selectedTier) "$name debug tier $selectedTier immediately changes to $resultTier at scale $scale"
        }
    }
}

# Execute the actual source's boolean horn-ownership guards with representative saves.
$cow = Get-Content -Raw -LiteralPath (Join-Path $root 'Source\Scripts\cfl_CowformEffect.psc')
$hornCleanup = Function-Body $cow 'RemoveHorns'
$managedExpression = [regex]::Match($hornCleanup, 'Bool managedHorns = ([^\r\n]+)').Groups[1].Value
$removeExpression = [regex]::Match($hornCleanup, 'If (managedHorns[^\r\n]+)').Groups[1].Value
Assert-Review ($managedExpression -ne '' -and $removeExpression -ne '') 'Horn cleanup has no ownership guard'
function Eval-HornGuard([bool]$_hornOwnershipRecorded,[bool]$_equippedCowHorns,[bool]$_addedCowHorns,[bool]$_hornsWereEquipped,[bool]$isEquipped) {
    $managedCode = [regex]::Replace($managedExpression, '(_\w+)', '$$$1').Replace('||','-or').Replace('!','-not ')
    $managedHorns = & ([scriptblock]::Create($managedCode))
    $removeCode = $removeExpression.Replace('akActor.IsEquipped(_cowHorns)', '$isEquipped').Replace('managedHorns', '$managedHorns')
    $removeCode = [regex]::Replace($removeCode, '(_\w+)', '$$$1').Replace('&&','-and').Replace('!','-not ')
    return & ([scriptblock]::Create($removeCode))
}
Assert-Review (!(Eval-HornGuard $true $false $false $false $true)) 'Blocked auto-equip strips manually equipped horns on fade'
Assert-Review (!(Eval-HornGuard $true $false $false $true $true)) 'Pre-equipped horns are stripped on fade'
Assert-Review (Eval-HornGuard $true $true $false $false $true) 'Auto-equipped borrowed horns are not cleaned up'
Assert-Review (Eval-HornGuard $true $true $true $false $true) 'Form-created horns are not cleaned up'
Assert-Review (!(Eval-HornGuard $true $true $true $false $false)) 'Cleanup unequips horns that are not equipped'
Assert-Review (Eval-HornGuard $false $false $false $false $true) 'Legacy saves lose their horn cleanup path'
Assert-Review ($hornCleanup -match '_equippedCowHorns = false' -and $hornCleanup -match '_hornOwnershipRecorded = true') 'Repeated horn cleanup can claim player equipment'

# Fire handling must be immediate without rescheduling polling on every flame hit.
$fireQueue = Function-Body $troll 'QueueFireSuppression'
$trollComplete = Function-Body $troll 'CompleteTransition'
Assert-Review ($fireQueue -match 'UpdateRegenSuppression\(PlayerRef\)' -and $fireQueue -notmatch 'RegisterForSingleUpdate|CompleteTransition\(') 'Fire hits defer suppression or disturb the progression timer'
Assert-Review ($fireQueue.IndexOf('_transitioning = true') -lt $fireQueue.IndexOf('UpdateRegenSuppression')) 'Fire stat changes bypass transition exclusion'
Assert-Review ($trollComplete -match 'ClampFloat\(_fireUntilElapsed - GetTimeElapsed\(\), 0.1, afDelay\)') 'Fire expiry is rounded to the polling interval'
Assert-Review ($troll -match '_leftWeaponSpeedMod = -0.15' -and $troll -match 'ModActorValue\("LeftWeaponSpeedMult", -_leftWeaponSpeedMod\)') 'Offhand weapons bypass the Troll attack-speed penalty or fail to restore'
$duration = [double]([regex]::Match($fireQueue, '_fireUntilElapsed = GetTimeElapsed\(\) \+ ([0-9.]+)').Groups[1].Value)
$deadline = 3.25 + $duration
$now = 5.0
while ($now -lt $deadline) { $now += [Math]::Min(5.0,[Math]::Max(0.1,$deadline - $now)) }
Assert-Review ([Math]::Abs($now - 13.25) -lt 0.001) 'A hit between polls keeps suppression past its ten-second deadline'
# Parse the small plugin directly, including VMAD object properties. No writes.
$bytes = [IO.File]::ReadAllBytes((Join-Path $root 'Dollform.esp'))
$records = [Collections.Generic.List[object]]::new()
function Read-Records([int]$start, [int]$end) {
    $pos = $start
    while ($pos -lt $end) {
        $type = [Text.Encoding]::ASCII.GetString($bytes, $pos, 4)
        $size = [BitConverter]::ToUInt32($bytes, $pos + 4)
        if ($type -eq 'GRUP') { Read-Records ($pos + 24) ($pos + $size); $pos += $size; continue }
        Assert-Review ($pos + 24 + $size -le $end) "Truncated $type record"
        Assert-Review (([BitConverter]::ToUInt32($bytes, $pos + 8) -band 0x40000) -eq 0) 'Compressed records need an expanded parser'
        $subs = @{}
        $at = $pos + 24
        while ($at -lt $pos + 24 + $size) {
            $tag = [Text.Encoding]::ASCII.GetString($bytes, $at, 4)
            $len = [BitConverter]::ToUInt16($bytes, $at + 4)
            $value = [byte[]]::new($len)
            [Array]::Copy($bytes, $at + 6, $value, 0, $len)
            if (!$subs.ContainsKey($tag)) { $subs[$tag] = [Collections.Generic.List[byte[]]]::new() }
            $subs[$tag].Add($value)
            $at += 6 + $len
        }
        $edid = ''
        if ($subs.ContainsKey('EDID')) { $edid = [Text.Encoding]::UTF8.GetString($subs['EDID'][0]).TrimEnd([char]0) }
        $records.Add([pscustomobject]@{Type=$type; Id=[BitConverter]::ToUInt32($bytes,$pos+12); Edid=$edid; Subs=$subs})
        $pos += 24 + $size
    }
}
Read-Records 0 $bytes.Length
function Read-VmadString($reader) { return [Text.Encoding]::UTF8.GetString($reader.ReadBytes($reader.ReadUInt16())) }
foreach ($record in $records) {
    if (!$record.Subs.ContainsKey('VMAD')) { continue }
    $reader = [IO.BinaryReader]::new([IO.MemoryStream]::new($record.Subs['VMAD'][0]))
    $version = $reader.ReadUInt16()
    $format = $reader.ReadUInt16()
    Assert-Review ($format -eq 2) 'Unrecognized VMAD object format'
    $scriptCount = $reader.ReadUInt16()
    for ($s = 0; $s -lt $scriptCount; $s++) {
        $scriptName = Read-VmadString $reader
		$sourcePath = Join-Path $root "Source\Scripts\$scriptName.psc"
		$scriptSource = Get-Content -Raw -LiteralPath $sourcePath
		$filledProps = @{}
        $null = $reader.ReadByte()
        $propCount = $reader.ReadUInt16()
        Assert-Review (Test-Path -LiteralPath (Join-Path $root "Scripts\$scriptName.pex")) "Missing script attached to $($record.Edid): $scriptName"
        for ($p = 0; $p -lt $propCount; $p++) {
            $propName = Read-VmadString $reader
			$filledProps[$propName] = $true
            $propType = $reader.ReadByte()
            $null = $reader.ReadByte()
            switch ($propType) {
                1 {
                    $null = $reader.ReadUInt32()
                    $formId = $reader.ReadUInt32()
                    Assert-Review ($formId -ne 0) "$scriptName.$propName is unfilled"
                    if (($formId -shr 24) -eq 1) {
                        Assert-Review (@($records | Where-Object Id -EQ $formId).Count -eq 1) "$scriptName.$propName references missing local record $formId"
						$targetRecord = $records | Where-Object Id -EQ $formId
						if ($propName -like '*HairColor') {
							Assert-Review ($targetRecord.Type -eq 'CLFM') "$scriptName.$propName is not a color record"
						} elseif ($propName -like 'cfl_*') {
							$expectedEdid = $propName
							if ($propName -eq 'cfl_DollformEnemyDistractSpell') { $expectedEdid = 'cfl_SpellDollformEnemyDistract' }
							Assert-Review ($targetRecord.Edid -eq $expectedEdid) "$scriptName.$propName links to $($targetRecord.Edid)"
						}
                    }
                }
                2 { $null = Read-VmadString $reader }
                3 { $null = $reader.ReadInt32() }
                4 { $null = $reader.ReadSingle() }
                5 { $null = $reader.ReadByte() }
                default { throw "Unhandled VMAD property type $propType" }
            }
        }
		foreach ($property in [regex]::Matches($scriptSource, '(?im)^(?:GlobalVariable|Spell|ColorForm|Actor) Property (\w+) Auto')) {
			Assert-Review $filledProps.ContainsKey($property.Groups[1].Value) "$scriptName is missing required property $($property.Groups[1].Value)"
		}
    }
    $reader.Dispose()
}
foreach ($name in @('Doll','Horse','Cow','Rabbit','Troll')) {
    $spell = $records | Where-Object Edid -EQ "cfl_Spell${name}form"
    Assert-Review ($null -ne $spell) "Missing $name spell"
    Assert-Review ([BitConverter]::ToUInt32($spell.Subs['SPIT'][0],8) -eq 3) "$name is not a Lesser Power"
    Assert-Review ([BitConverter]::ToUInt32($spell.Subs['EFIT'][0],8) -eq 420) "$name duration is not 420 seconds"
}
$catalog = Get-Content -Raw -LiteralPath (Join-Path $root 'Textures\Actors\Character\slavetats\dollform.json') | ConvertFrom-Json
foreach ($entry in $catalog) {
    $texture = Join-Path $root ("Textures\Actors\Character\slavetats\" + $entry.texture)
    if ($entry.texture -eq 'makeup\both_feet_nails.dds') { continue } # Installed Apropos2 asset.
    Assert-Review (Test-Path -LiteralPath $texture) "Missing tattoo texture: $($entry.texture)"
}
$seq = [IO.File]::ReadAllBytes((Join-Path $root 'SEQ\Dollform.seq'))
Assert-Review ($seq.Length -eq 4) 'Unexpected SEQ content'
$questId = [BitConverter]::ToUInt32($seq,0)
Assert-Review (@($records | Where-Object { $_.Type -eq 'QUST' -and ($_.Id -band 0xFFFFFF) -eq $questId }).Count -eq 1) 'SEQ does not point to a quest'
Write-Output "Bodymorph review: $script:checks source, stat arithmetic, plugin/property, duration, and asset checks passed. These are offline checks; in-game behavior still needs playtesting."
