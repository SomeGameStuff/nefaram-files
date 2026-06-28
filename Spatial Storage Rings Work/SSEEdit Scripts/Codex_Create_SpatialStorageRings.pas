unit UserScript;

const
  PatchName = 'Spatial Storage Rings.esp';

var
  patchFile, skyrimFile: IInterface;
  ringKeyword, capacityGlobal, accessSpell, storageRef: IInterface;
  msgNoRing, msgFull: IInterface;

function SetLocalID(rec: IInterface; localID: Cardinal): IInterface;
var
  prefix: Cardinal;
begin
  prefix := GetLoadOrderFormID(rec) and $FF000000;
  SetLoadOrderFormID(rec, prefix + localID);
  Result := rec;
end;

function RequireByEDID(sig, edid: string): IInterface;
begin
  Result := MainRecordByEditorID(GroupBySignature(skyrimFile, sig), edid);
  if not Assigned(Result) then begin
    AddMessage('Missing Skyrim.esm template ' + sig + ':' + edid);
    Result := nil;
  end;
end;

function CopyAsNew(template: IInterface; localID: Cardinal; edid, fullName: string): IInterface;
begin
  AddRequiredElementMasters(template, patchFile, False);
  Result := wbCopyElementToFile(template, patchFile, True, True);
  if not Assigned(Result) then begin
    AddMessage('Failed to copy template: ' + Name(template));
    Exit;
  end;
  SetLocalID(Result, localID);
  SetElementEditValues(Result, 'EDID', edid);
  if fullName <> '' then
    SetElementEditValues(Result, 'FULL', fullName);
end;

procedure AttachScript(rec: IInterface; scriptName: string);
var
  vmad, scripts, scriptEntry: IInterface;
begin
  if ElementExists(rec, 'VMAD') then
    RemoveElement(rec, 'VMAD');
  Add(rec, 'VMAD', False);
  vmad := ElementByPath(rec, 'VMAD');
  scripts := ElementByPath(vmad, 'Scripts');
  if not Assigned(scripts) then
    scripts := Add(vmad, 'Scripts', False);
  scriptEntry := ElementAssign(scripts, HighInteger, nil, False);
  SetElementEditValues(scriptEntry, 'scriptName', scriptName);
end;

procedure SetSingleEffect(rec, mgef: IInterface);
var
  effects, effect: IInterface;
begin
  if ElementExists(rec, 'Effects') then
    RemoveElement(rec, 'Effects');
  effects := Add(rec, 'Effects', False);
  effect := ElementByIndex(effects, 0);
  if not Assigned(effect) then
    effect := ElementAssign(effects, HighInteger, nil, False);
  SetElementEditValues(effect, 'EFID', Name(mgef));
  SetElementEditValues(effect, 'EFIT\Magnitude', '0');
  SetElementEditValues(effect, 'EFIT\Area', '0');
  SetElementEditValues(effect, 'EFIT\Duration', '0');
end;

procedure AddKeyword(rec, kw: IInterface);
var
  kwda, entry: IInterface;
begin
  kwda := ElementByPath(rec, 'KWDA');
  if not Assigned(kwda) then
    kwda := Add(rec, 'KWDA', False);
  entry := ElementAssign(kwda, HighInteger, nil, False);
  SetEditValue(entry, Name(kw));
  if ElementExists(rec, 'KSIZ') then
    SetElementNativeValues(rec, 'KSIZ', ElementCount(kwda));
end;

function CreateGlobal(localID: Cardinal; edid: string; value: string): IInterface;
var
  groupRef: IInterface;
begin
  Add(patchFile, 'GLOB', True);
  groupRef := GroupBySignature(patchFile, 'GLOB');
  Result := Add(groupRef, 'GLOB', True);
  SetLocalID(Result, localID);
  SetElementEditValues(Result, 'EDID', edid);
  SetElementEditValues(Result, 'FNAM', 'Short');
  SetElementEditValues(Result, 'FLTV', value);
end;

function CreateMessage(localID: Cardinal; edid, textValue: string): IInterface;
var
  groupRef: IInterface;
begin
  Add(patchFile, 'MESG', True);
  groupRef := GroupBySignature(patchFile, 'MESG');
  Result := Add(groupRef, 'MESG', True);
  SetLocalID(Result, localID);
  SetElementEditValues(Result, 'EDID', edid);
  SetElementEditValues(Result, 'DESC', textValue);
end;

function CreateKeyword(localID: Cardinal; edid: string): IInterface;
var
  groupRef: IInterface;
begin
  Add(patchFile, 'KYWD', True);
  groupRef := GroupBySignature(patchFile, 'KYWD');
  Result := Add(groupRef, 'KYWD', True);
  SetLocalID(Result, localID);
  SetElementEditValues(Result, 'EDID', edid);
end;

function CreateMagicEffect(template: IInterface; localID: Cardinal; edid, fullName, scriptName: string): IInterface;
begin
  Result := CopyAsNew(template, localID, edid, fullName);
  if not Assigned(Result) then Exit;
  SetElementEditValues(Result, 'Magic Effect Data\DATA - Data\Casting Type', 'Constant Effect');
  SetElementEditValues(Result, 'Magic Effect Data\DATA - Data\Delivery', 'Self');
  SetElementEditValues(Result, 'Magic Effect Data\DATA - Data\Magic Skill', 'None');
  SetElementEditValues(Result, 'Magic Effect Data\DATA - Data\Minimum Skill Level', '0');
  SetElementEditValues(Result, 'Magic Effect Data\DATA - Data\Archetype\Actor Value', 'None');
  AttachScript(Result, scriptName);
end;

function CreateEnchantment(template, mgef: IInterface; localID: Cardinal; edid, fullName: string): IInterface;
begin
  Result := CopyAsNew(template, localID, edid, fullName);
  if not Assigned(Result) then Exit;
  SetSingleEffect(Result, mgef);
end;

function CreateRing(template, ench: IInterface; localID: Cardinal; edid, fullName, value: string): IInterface;
begin
  Result := CopyAsNew(template, localID, edid, fullName);
  if not Assigned(Result) then Exit;
  SetElementEditValues(Result, 'EITM', Name(ench));
  SetElementEditValues(Result, 'DATA\Value', value);
  SetElementEditValues(Result, 'DATA\Weight', '0.25');
  AddKeyword(Result, ringKeyword);
end;

function CreateStorageContainer(template: IInterface): IInterface;
begin
  Result := CopyAsNew(template, $000805, 'SSR_SpatialStorageContainer', 'Spatial Storage');
  if Assigned(Result) then
    RemoveElement(Result, 'Items');
end;

function CreateStorageReference(baseContainer: IInterface): IInterface;
var
  qaSmoke, child, tempGroup: IInterface;
begin
  qaSmoke := MainRecordByEditorID(GroupBySignature(skyrimFile, 'CELL'), 'QASmoke');
  if not Assigned(qaSmoke) then begin
    AddMessage('Unable to find QASmoke cell for storage reference.');
    Result := nil;
    Exit;
  end;

  AddRequiredElementMasters(qaSmoke, patchFile, False);
  child := ChildGroup(qaSmoke);
  tempGroup := FindChildGroup(child, 9, qaSmoke);
  if not Assigned(tempGroup) then begin
    AddMessage('Unable to find QASmoke temporary reference group.');
    Result := nil;
    Exit;
  end;

  tempGroup := wbCopyElementToFile(tempGroup, patchFile, False, False);
  Result := Add(tempGroup, 'REFR', True);
  SetLocalID(Result, $00080F);
  SetElementEditValues(Result, 'NAME', Name(baseContainer));
  SetElementEditValues(Result, 'DATA\Position\X', '0');
  SetElementEditValues(Result, 'DATA\Position\Y', '0');
  SetElementEditValues(Result, 'DATA\Position\Z', '-30000');
  AttachScript(Result, 'SSR_StorageContainerScript');
end;

procedure AddToLeveledList(listEdid: string; item: IInterface; level, count: Integer);
var
  srcList, patchList, entries, entry: IInterface;
begin
  srcList := MainRecordByEditorID(GroupBySignature(skyrimFile, 'LVLI'), listEdid);
  if not Assigned(srcList) then begin
    AddMessage('Skipped missing LVLI: ' + listEdid);
    Exit;
  end;

  AddRequiredElementMasters(srcList, patchFile, False);
  patchList := wbCopyElementToFile(WinningOverride(srcList), patchFile, False, True);
  entries := ElementByPath(patchList, 'Leveled List Entries');
  if not Assigned(entries) then
    entries := Add(patchList, 'Leveled List Entries', False);
  entry := ElementAssign(entries, HighInteger, nil, False);
  SetElementEditValues(entry, 'LVLO\Reference', Name(item));
  SetElementNativeValues(entry, 'LVLO\Level', level);
  SetElementNativeValues(entry, 'LVLO\Count', count);
end;

function Initialize: Integer;
var
  tplRing, tplMgef, tplEnch, tplSpell, tplContainer: IInterface;
  mgefOpen, mgefLesser, mgefGreater, mgefGrand, mgefInfinite: IInterface;
  enchLesser, enchGreater, enchGrand, enchInfinite: IInterface;
  ringLesser, ringGreater, ringGrand, ringInfinite, baseContainer: IInterface;
begin
  skyrimFile := FileByName('Skyrim.esm');
  if not Assigned(skyrimFile) then begin
    AddMessage('Skyrim.esm is not loaded.');
    Result := 1;
    Exit;
  end;

  patchFile := AddNewFileName(PatchName);
  if not Assigned(patchFile) then begin
    AddMessage('Failed to create ' + PatchName);
    Result := 1;
    Exit;
  end;

  SetFlag(ElementByPath(ElementByIndex(patchFile, 0), 'Record Header\Record Flags'), 9, True);
  AddMasterIfMissing(patchFile, 'Skyrim.esm');

  tplRing := RequireByEDID('ARMO', 'GoldDiamondRing');
  tplMgef := RequireByEDID('MGEF', 'EnchFortifyCarryWeightConstantSelf');
  tplEnch := RequireByEDID('ENCH', 'EnchRingCarry04');
  tplSpell := RequireByEDID('SPEL', 'VoiceUnrelentingForce1');
  tplContainer := RecordByFormID(skyrimFile, $0001D13C, False);

  if not Assigned(tplRing) or not Assigned(tplMgef) or not Assigned(tplEnch) or not Assigned(tplSpell) or not Assigned(tplContainer) then begin
    AddMessage('One or more required templates are missing; aborting.');
    Result := 1;
    Exit;
  end;

  capacityGlobal := CreateGlobal($000800, 'SSR_CurrentStorageCapacity', '0');
  msgNoRing := CreateMessage($000801, 'SSR_MsgNoRingEquipped', 'Equip a Spatial Storage Ring to access spatial storage.');
  msgFull := CreateMessage($000802, 'SSR_MsgStorageFull', 'The spatial storage is full. Excess items were returned.');
  ringKeyword := CreateKeyword($000810, 'SSR_KeywordSpatialStorageRing');

  mgefOpen := CreateMagicEffect(tplMgef, $000803, 'SSR_MGEF_OpenStorage', 'Open Spatial Storage', 'SSR_OpenStorageEffect');
  accessSpell := CopyAsNew(tplSpell, $000804, 'SSR_PowerOpenSpatialStorage', 'Open Spatial Storage');
  SetElementEditValues(accessSpell, 'SPIT\Type', 'Lesser Power');
  SetElementEditValues(accessSpell, 'SPIT\Cast Type', 'Fire and Forget');
  SetElementEditValues(accessSpell, 'SPIT\Delivery', 'Self');
  SetSingleEffect(accessSpell, mgefOpen);

  mgefLesser := CreateMagicEffect(tplMgef, $000811, 'SSR_MGEF_RingLesser', 'Spatial Storage - Lesser', 'SSR_RingLesserEffect');
  mgefGreater := CreateMagicEffect(tplMgef, $000812, 'SSR_MGEF_RingGreater', 'Spatial Storage - Greater', 'SSR_RingGreaterEffect');
  mgefGrand := CreateMagicEffect(tplMgef, $000813, 'SSR_MGEF_RingGrand', 'Spatial Storage - Grand', 'SSR_RingGrandEffect');
  mgefInfinite := CreateMagicEffect(tplMgef, $000814, 'SSR_MGEF_RingInfinite', 'Spatial Storage - Infinite', 'SSR_RingInfiniteEffect');

  enchLesser := CreateEnchantment(tplEnch, mgefLesser, $000821, 'SSR_Ench_RingLesser', 'Spatial Storage - Lesser');
  enchGreater := CreateEnchantment(tplEnch, mgefGreater, $000822, 'SSR_Ench_RingGreater', 'Spatial Storage - Greater');
  enchGrand := CreateEnchantment(tplEnch, mgefGrand, $000823, 'SSR_Ench_RingGrand', 'Spatial Storage - Grand');
  enchInfinite := CreateEnchantment(tplEnch, mgefInfinite, $000824, 'SSR_Ench_RingInfinite', 'Spatial Storage - Infinite');

  ringLesser := CreateRing(tplRing, enchLesser, $000831, 'SSR_RingLesser', 'Spatial Storage Ring - Lesser', '100');
  ringGreater := CreateRing(tplRing, enchGreater, $000832, 'SSR_RingGreater', 'Spatial Storage Ring - Greater', '1000');
  ringGrand := CreateRing(tplRing, enchGrand, $000833, 'SSR_RingGrand', 'Spatial Storage Ring - Grand', '5000');
  ringInfinite := CreateRing(tplRing, enchInfinite, $000834, 'SSR_RingInfinite', 'Spatial Storage Ring - Infinite', '20000');

  baseContainer := CreateStorageContainer(tplContainer);
  storageRef := CreateStorageReference(baseContainer);

  AddToLeveledList('LItemMiscVendorMiscItems75', ringLesser, 1, 1);
  AddToLeveledList('LItemMiscVendorMiscItems75', ringGreater, 12, 1);
  AddToLeveledList('LItemMiscVendorMiscItems75', ringGrand, 24, 1);
  AddToLeveledList('LItemMiscVendorMiscItems75', ringInfinite, 36, 1);

  AddToLeveledList('LItemSpellTomes75AllAlteration', ringLesser, 1, 1);
  AddToLeveledList('LItemSpellTomes75AllAlteration', ringGreater, 12, 1);
  AddToLeveledList('LItemSpellTomes75AllAlteration', ringGrand, 24, 1);
  AddToLeveledList('LItemSpellTomes75AllAlteration', ringInfinite, 36, 1);

  SortMasters(patchFile);
  CleanMasters(patchFile);
  AddMessage('Created ' + PatchName + '.');
end;

end.
