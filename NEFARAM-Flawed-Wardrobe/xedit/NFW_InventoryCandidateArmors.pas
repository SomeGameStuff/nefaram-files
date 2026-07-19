unit userscript;

{ Read-only SSEEdit inventory script. Apply to loaded ARMO records through MO2. }

var
  Sources, Seen: TStringList;
  CandidateCount: Integer;

function IsSourceFile(f: IInterface): Boolean;
begin
  Result := Sources.IndexOf(GetFileName(f)) >= 0;
end;

function HasModelOrAddon(e: IInterface): Boolean;
begin
  Result := ElementExists(e, 'Models\\MOD2') or ElementExists(e, 'Armature');
end;

function Initialize: Integer;
begin
  Sources := TStringList.Create;
  Seen := TStringList.Create;
  Sources.Sorted := True;
  Sources.Duplicates := dupIgnore;
  Seen.Sorted := True;
  Seen.Duplicates := dupIgnore;
  Sources.Text :=
    'The Amazing World of Bikini Armors REMASTERED.esp'#13#10+
    '(Pumpkin)-TEWOBA-TheExpandedWorldofBikiniArmor.esp'#13#10+
    'TAWOBA_dawn.esp'#13#10+
    'TAWOBA_guards_addon.esp'#13#10+
    'TAWOBA_sons.esp'#13#10+
    'Ghaan Revealing Outfit Craftable.esp'#13#10+
    'GirlHeavyArmor.esp'#13#10+
    'StormcloakWarmaidenArmor.esp'#13#10+
    'StalhrimBikini.esp'#13#10+
    'Demon Hunter Armour.esp'#13#10+
    'ralfetas-deze-armor.esp'#13#10+
    'ralfetas-deze-clothing.esp'#13#10+
    'Twilight Princess Armor.esp'#13#10+
    'Elven Sentry Armor.esp'#13#10+
    'Azure Knight Armor.esp'#13#10+
    'DracaniaArmor.esp'#13#10+
    'C5Kevs_Yumiko_Light_Tank_Armor_CBBE.esp'#13#10+
    '[FB] Bishop Armor.esp'#13#10+
    'ObiDruchiiArmor.esp'#13#10+
    'Obi''s Gladiator Armor.esp'#13#10+
    'Iron Rose Armor.esp'#13#10+
    'RoverArmor.esp'#13#10+
    'ChronomancerArmor.esp'#13#10+
    'RoyalVanguardArmor.esp'#13#10+
    '[Enovilum] Vampire Temptress Armor.esp';
  CandidateCount := 0;
  AddMessage('NFW inventory started. Apply this script to loaded ARMO records.');
  Result := 0;
end;

function Process(e: IInterface): Integer;
var
  f: IInterface;
  edid, fullName, key: string;
begin
  Result := 0;
  if Signature(e) <> 'ARMO' then Exit;
  f := GetFile(e);
  if not IsSourceFile(f) then Exit;
  if not HasModelOrAddon(e) then Exit;
  edid := GetElementEditValues(e, 'EDID');
  fullName := GetElementEditValues(e, 'FULL');
  if (edid = '') or (fullName = '') then Exit;
  key := GetFileName(f) + '|' + edid;
  if Seen.IndexOf(key) >= 0 then Exit;
  Seen.Add(key);
  Inc(CandidateCount);
  AddMessage('NFW_CANDIDATE|' + IntToStr(CandidateCount) + '|' + GetFileName(f) + '|' + IntToHex(GetLoadOrderFormID(e), 8) + '|' + edid + '|' + fullName);
end;

function Finalize: Integer;
begin
  AddMessage('NFW inventory complete: ' + IntToStr(CandidateCount) + ' candidate armour records.');
  Sources.Free;
  Seen.Free;
  Result := 0;
end;

end.
