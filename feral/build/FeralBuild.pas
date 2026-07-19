unit UserScript;

uses lilmacelib;

var
  FeralFile, DollformFile, SkyrimFile: IInterface;
  QuestTemplate, MgefTemplate, SpellTemplate: IInterface;

function RecordByEDID(aFile: IInterface; aSignature, aEDID: string): IInterface;
var
  g: IInterface;
begin
  g := GroupBySignature(aFile, aSignature);
  Result := MainRecordByEditorID(g, aEDID);
end;

function RecordByScript(aFile: IInterface; aSignature, aScript: string): IInterface;
var
  g, r, scripts, s: IInterface;
  i, j: Integer;
begin
  Result := nil;
  g := GroupBySignature(aFile, aSignature);
  for i := 0 to ElementCount(g) - 1 do begin
    r := ElementByIndex(g, i);
    scripts := ElementByPath(r, 'VMAD\\Scripts');
    for j := 0 to ElementCount(scripts) - 1 do begin
      s := ElementByIndex(scripts, j);
      if SameText(GetEditValue(ElementByName(s, 'ScriptName')), aScript) then begin
        Result := r;
        Exit;
      end;
    end;
  end;
end;

procedure ReplaceScript(aRecord: IInterface; aScript: string);
var
  scripts, oldScript, newScript: IInterface;
begin
  RemoveElement(aRecord, 'VMAD');
  newScript := AddScript(aRecord, aScript, false);
end;

procedure AddRaceToList(aList: IInterface; aRaceEDID: string);
var
  race, entries, entry: IInterface;
begin
  race := RecordByEDID(SkyrimFile, 'RACE', aRaceEDID);
  if not Assigned(race) then begin
    AddMessage('Missing race: ' + aRaceEDID);
    Exit;
  end;
  entries := ElementByPath(aList, 'FormIDs');
  if not Assigned(entries) then entries := Add(aList, 'FormIDs', true);
  entry := ElementAssign(entries, HighInteger, nil, false);
  SetEditValue(entry, Name(race));
end;

procedure MakeFamilyList(aEDID, aName: string; aRaces: array of string);
var
  g, l: IInterface;
  i: Integer;
begin
  g := GroupBySignature(FeralFile, 'FLST');
  if not Assigned(g) then g := Add(FeralFile, 'FLST', true);
  l := Add(g, 'FLST', true);
  SetElementEditValues(l, 'EDID', aEDID);
  SetElementEditValues(l, 'FULL', aName);
  for i := Low(aRaces) to High(aRaces) do AddRaceToList(l, aRaces[i]);
end;

function Initialize: Integer;
var
  q, m, s, effect: IInterface;
begin
  DollformFile := FileByName('Dollform.esp');
  SkyrimFile := FileByName('Skyrim.esm');
  if not Assigned(DollformFile) or not Assigned(SkyrimFile) then begin
    AddMessage('Feral build requires Skyrim.esm and Dollform.esp to be loaded.');
    Result := 1;
    Exit;
  end;
  FeralFile := AddNewFileName('Feral.esp');
  AddMasterIfMissing(FeralFile, 'Dollform.esp');

  QuestTemplate := RecordByEDID(DollformFile, 'QUST', 'cfl_DollformMCMQuest');
  MgefTemplate := RecordByScript(DollformFile, 'MGEF', 'cfl_RabbitformEffect');
  SpellTemplate := RecordByEDID(DollformFile, 'SPEL', 'cfl_SpellRabbitform');
  if not Assigned(QuestTemplate) or not Assigned(MgefTemplate) or not Assigned(SpellTemplate) then begin
    AddMessage('Could not find Bodymorph templates.');
    Result := 1;
    Exit;
  end;

  q := wbCopyElementToFile(QuestTemplate, FeralFile, true, true);
  SetElementEditValues(q, 'EDID', 'cfl_FeralQuest');
  SetElementEditValues(q, 'FULL', 'Feral Controller');
  ReplaceScript(q, 'cfl_FeralQuest');

  q := wbCopyElementToFile(QuestTemplate, FeralFile, true, true);
  SetElementEditValues(q, 'EDID', 'cfl_FeralMCMQuest');
  SetElementEditValues(q, 'FULL', 'Feral MCM');
  ReplaceScript(q, 'cfl_FeralMCM');

  m := wbCopyElementToFile(MgefTemplate, FeralFile, true, true);
  SetElementEditValues(m, 'EDID', 'cfl_MGEFFeralClaim');
  SetElementEditValues(m, 'FULL', 'Claim Essence');
  SetElementEditValues(m, 'DATA\\Delivery', 'Target Actor');
  ReplaceScript(m, 'cfl_FeralClaimEffect');
  s := wbCopyElementToFile(SpellTemplate, FeralFile, true, true);
  SetElementEditValues(s, 'EDID', 'cfl_SpellClaimEssence');
  SetElementEditValues(s, 'FULL', 'Claim Essence');
  effect := ElementByPath(s, 'Effects\\Effect #0\\EFID');
  SetEditValue(effect, Name(m));

  m := wbCopyElementToFile(MgefTemplate, FeralFile, true, true);
  SetElementEditValues(m, 'EDID', 'cfl_MGEFFeralAspect');
  SetElementEditValues(m, 'FULL', 'Feral Aspect');
  ReplaceScript(m, 'cfl_FeralAspectEffect');
  s := wbCopyElementToFile(SpellTemplate, FeralFile, true, true);
  SetElementEditValues(s, 'EDID', 'cfl_SpellFeralAspect');
  SetElementEditValues(s, 'FULL', 'Feral Aspect');
  effect := ElementByPath(s, 'Effects\\Effect #0\\EFID');
  SetEditValue(effect, Name(m));

  MakeFamilyList('cfl_FeralWolfRaces', 'Feral - Wolf Races', ['WolfRace', 'IceWolfRace']);
  MakeFamilyList('cfl_FeralSabreRaces', 'Feral - Sabre Cat Races', ['SabreCatRace', 'SnowySabreCatRace']);
  MakeFamilyList('cfl_FeralBearRaces', 'Feral - Bear Races', ['BearRace', 'CaveBearRace', 'SnowBearRace']);
  MakeFamilyList('cfl_FeralSkeeverRaces', 'Feral - Skeever Races', ['SkeeverRace', 'GiantSkeeverRace']);
  MakeFamilyList('cfl_FeralSpiderRaces', 'Feral - Spider Races', ['FrostbiteSpiderRace', 'GiantFrostbiteSpiderRace', 'FrostbiteSpiderRaceGiant']);
  MakeFamilyList('cfl_FeralMudcrabRaces', 'Feral - Mudcrab Races', ['MudcrabRace', 'GiantMudcrabRace']);
  MakeFamilyList('cfl_FeralHorseRaces', 'Feral - Horse Races', ['HorseRace']);
  MakeFamilyList('cfl_FeralTrollRaces', 'Feral - Troll Races', ['TrollRace', 'FrostTrollRace']);
  AddMessage('Feral.esp created. Save and close xEdit.');
  Result := 0;
end;

function Process(e: IInterface): Integer;
begin
  Result := 0;
end;

end.
