unit userscript;

var
  patchFile: IwbFile;

function AddScript(rec: IInterface; ScriptName: string): IInterface;
var
  eScripts: IInterface;
begin
  eScripts := ElementByPath(Add(rec, 'VMAD', false), 'Scripts');
  Result := ElementAssign(eScripts, HighInteger, Nil, false);
  SetElementEditValues(Result, 'ScriptName', ScriptName);
end;

procedure AddObjectProperty(script: IInterface; propertyName: string; target: IInterface);
var
  props, prop: IInterface;
begin
  if not Assigned(target) then begin
    AddMessage('WARN: missing property target ' + propertyName);
    Exit;
  end;
  props := ElementByPath(script, 'Properties');
  prop := ElementAssign(props, HighInteger, Nil, false);
  SetElementEditValues(prop, 'propertyName', propertyName);
  SetElementEditValues(prop, 'Type', 'Object');
  SetElementEditValues(prop, 'Value\Object Union\Object v2\FormID', Name(target));
end;

function AddGlobal(edid: string; value: string): IInterface;
begin
  Result := Add(GroupBySignature(patchFile, 'GLOB'), 'GLOB', true);
  SetElementEditValues(Result, 'EDID', edid);
  SetElementEditValues(Result, 'FNAM', 'Float');
  SetElementEditValues(Result, 'FLTV', value);
end;

function FindRecord(sig: string; edid: string): IInterface;
var
  i: integer;
  group, rec: IInterface;
begin
  Result := nil;
  for i := 0 to Pred(FileCount) do begin
    group := GroupBySignature(FileByIndex(i), sig);
    if not Assigned(group) then
      Continue;
    rec := MainRecordByEditorID(group, edid);
    if Assigned(rec) then begin
      Result := rec;
      Exit;
    end;
  end;
end;

function Initialize: integer;
var
  quest, script: IInterface;
  gHeat, gHumanity, gCorruption, gLastTransform, gCrash: IInterface;
begin
  patchFile := AddNewFileName('NEFARAM - Vampire Lord Consequences.esp');
  AddMasterIfMissing(patchFile, 'Skyrim.esm');
  AddMasterIfMissing(patchFile, 'Update.esm');
  AddMasterIfMissing(patchFile, 'Dawnguard.esm');
  SetIsESL(patchFile, true);

  gHeat := AddGlobal('NVLC_Heat', '0');
  gHumanity := AddGlobal('NVLC_Humanity', '100');
  gCorruption := AddGlobal('NVLC_Corruption', '0');
  gLastTransform := AddGlobal('NVLC_LastTransformTime', '0');
  gCrash := AddGlobal('NVLC_CrashSeverity', '0');

  quest := Add(GroupBySignature(patchFile, 'QUST'), 'QUST', true);
  SetElementEditValues(quest, 'EDID', 'NVLC_ControllerQuest');
  SetElementEditValues(quest, 'FULL', 'NEFARAM Vampire Lord Consequences Controller');
  SetElementEditValues(quest, 'DNAM\Flags\Start Game Enabled', '1');
  SetElementEditValues(quest, 'DNAM\Flags\Run Once', '0');
  SetElementEditValues(quest, 'DNAM\Priority', '0');
  SetElementEditValues(quest, 'DATA\Flags', 'Start Game Enabled');

  script := AddScript(quest, 'NVLC_Controller');
  AddObjectProperty(script, 'DLC1VampireBeastRace', FindRecord('RACE', 'DLC1VampireBeastRace'));
  AddObjectProperty(script, 'LocTypeCity', FindRecord('KYWD', 'LocTypeCity'));
  AddObjectProperty(script, 'LocTypeTown', FindRecord('KYWD', 'LocTypeTown'));
  AddObjectProperty(script, 'LocTypeHabitation', FindRecord('KYWD', 'LocTypeHabitation'));
  AddObjectProperty(script, 'ActorTypeNPC', FindRecord('KYWD', 'ActorTypeNPC'));
  AddObjectProperty(script, 'GameDaysPassed', FindRecord('GLOB', 'GameDaysPassed'));
  AddObjectProperty(script, 'NVLC_Heat', gHeat);
  AddObjectProperty(script, 'NVLC_Humanity', gHumanity);
  AddObjectProperty(script, 'NVLC_Corruption', gCorruption);
  AddObjectProperty(script, 'NVLC_LastTransformTime', gLastTransform);
  AddObjectProperty(script, 'NVLC_CrashSeverity', gCrash);
  AddObjectProperty(script, 'NVLC_DawnguardHunter', FindRecord('NPC_', 'DLC1HunterMelee1HImperialM01'));

  AddMessage('Created NEFARAM - Vampire Lord Consequences.esp');
end;

function Process(e: IInterface): integer;
begin
end;

function Finalize: integer;
begin
end;
end.
