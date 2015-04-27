// ============================================================
// MonsterMadness.MonsterMadnessClientWindow
//
// This class is part of the Monster Madness mutator
// Created by MeltDown - meltdown@unrealtower.org
// For the latest version, go to:
// http://www.unrealtower.org/
// ============================================================

class MonsterMadnessClientWindow expands UWindowDialogClientWindow config(MonsterMadness);

var UWindowHSliderControl NrOfMonsters;
var UWindowHSliderControl HealthMultiplier;
var UWindowCheckBox Brute;
var UWindowCheckBox Behemoth;
var UWindowCheckBox LesserBrute;
var UWindowCheckBox Cow;
var UWindowCheckBox GasBag;
var UWindowCheckBox GiantGasBag;
var UWindowCheckBox IceSkaarj;
var UWindowCheckBox Krall;
var UWindowCheckBox KrallElite;
var UWindowCheckBox LeglessKrall;
var UWindowCheckBox Mercenary;
var UWindowCheckBox Queen;
var UWindowCheckBox SkaarjWarrior;
var UWindowCheckBox SkaarjAssassin;
var UWindowCheckBox SkaarjBerserker;
var UWindowCheckBox SkaarjLord;
var UWindowCheckBox SkaarjScout;
var UWindowCheckBox SkaarjTrooper;
var UWindowCheckBox SkaarjGunner;
var UWindowCheckBox SkaarjInfantry;
var UWindowCheckBox SkaarjOfficer;
var UWindowCheckBox SkaarjSniper;
var UWindowCheckBox Titan;
var UWindowCheckBox Warlord;
var UWindowCheckBox Fly;
var UWindowCheckBox Manta;
var UWindowCheckBox CaveManta;
var UWindowCheckBox GiantManta;
var UWindowCheckBox Slith;
var UWindowCheckBox Pupae;
var UWindowCheckBox ProgressLevel, NoRespawn, MatchLevel;
var UWindowSmallCloseButton CloseButton;
var UWindowComboControl PositionList;

function float getHealthMultiplier() {
	local int value;

	value = HealthMultiplier.value;
	if(value < 10) return 1/(10-value);
	return value-9;
}

function float getHealthMultiplierBarPos(float multiplier) {
	if(multiplier < 1) return 10-1/multiplier;
	return multiplier+9;
}

function Created() {
	Super.Created();
  
	NrOfMonsters=UWindowHSliderControl(CreateControl(class'UWindowHSliderControl',10,10,450,15));
	NrOfMonsters.SetRange(1,127,5);
	NrOfMonsters.SetValue(class'MonsterMadness'.default.InitialNrOfMonsters,true);
	NrOfMonsters.SetText("Initial number of monsters: " $ int(NrOfMonsters.Value));

	HealthMultiplier = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl',10,25,450,15));
	HealthMultiplier.SetRange(1,109,1);
	HealthMultiplier.SetValue(getHealthMultiplierBarPos(class'MonsterMadness'.default.HealthMultiplier),true);
	HealthMultiplier.SetText("Health of monsters are multiplied by: " $ getHealthMultiplier());

  
	Brute=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 60, 150, 15));
	Brute.SetText("Use Brute: ");
	Brute.bChecked=class'MonsterMadness'.default.bUseBrute;
	Brute.SetHelpText("Check this to use the Brute");
  
	Behemoth=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 75, 150, 15));
	Behemoth.SetText("Use Behemoth: ");
	Behemoth.bChecked=class'MonsterMadness'.default.bUseBehemoth;
	Behemoth.SetHelpText("Check this to use the Behemoth");
  
	LesserBrute=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 90, 150, 15));
	LesserBrute.SetText("Use LesserBrute: ");
	LesserBrute.bChecked=class'MonsterMadness'.default.bUseLesserBrute;
	LesserBrute.SetHelpText("Check this to use the LesserBrute");
  
	Cow=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 105, 150, 15));
	Cow.SetText("Use Cow: ");
	Cow.bChecked=class'MonsterMadness'.default.bUseCow;
	Cow.SetHelpText("Check this to use the Cow");
  
	GasBag=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 120, 150, 15));
	GasBag.SetText("Use GasBag: ");
	GasBag.bChecked=class'MonsterMadness'.default.bUseGasBag;
	GasBag.SetHelpText("Check this to use the GasBag");
  
	GiantGasBag=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 135, 150, 15));
	GiantGasBag.SetText("Use GiantGasBag: ");
	GiantGasBag.bChecked=class'MonsterMadness'.default.bUseGiantGasBag;
	GiantGasBag.SetHelpText("Check this to use the GiantGasBag");
  
	IceSkaarj=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 150, 150, 15));
	IceSkaarj.SetText("Use IceSkaarj: ");
	IceSkaarj.bChecked=class'MonsterMadness'.default.bUseIceSkaarj;
	IceSkaarj.SetHelpText("Check this to use the IceSkaarj");
  
	Krall=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 165, 150, 15));
	Krall.SetText("Use Krall: ");
	Krall.bChecked=class'MonsterMadness'.default.bUseKrall;
	Krall.SetHelpText("Check this to use the Krall");
  
	KrallElite=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 180, 150, 15));
	KrallElite.SetText("Use KrallElite: ");
	KrallElite.bChecked=class'MonsterMadness'.default.bUseKrallElite;
	KrallElite.SetHelpText("Check this to use the KrallElite");
  
	LeglessKrall=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 195, 150, 15));
	LeglessKrall.SetText("Use LeglessKrall: ");
	LeglessKrall.bChecked=class'MonsterMadness'.default.bUseLeglessKrall;
	LeglessKrall.SetHelpText("Check this to use the LeglessKrall");
  
	Mercenary=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 60, 150, 15));
	Mercenary.SetText("Use Mercenary: ");
	Mercenary.bChecked=class'MonsterMadness'.default.bUseMercenary;
	Mercenary.SetHelpText("Check this to use the Mercenary");
  
	Queen=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 75, 150, 15));
	Queen.SetText("Use Queen: ");
	Queen.bChecked=class'MonsterMadness'.default.bUseQueen;
	Queen.SetHelpText("Check this to use the Queen");
  
	SkaarjWarrior=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 90, 150, 15));
	SkaarjWarrior.SetText("Use SkaarjWarrior: ");
	SkaarjWarrior.bChecked=class'MonsterMadness'.default.bUseSkaarjWarrior;
	SkaarjWarrior.SetHelpText("Check this to use the SkaarjWarrior");
  
	SkaarjAssassin=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 105, 150, 15));
	SkaarjAssassin.SetText("Use SkaarjAssassin: ");
	SkaarjAssassin.bChecked=class'MonsterMadness'.default.bUseSkaarjAssassin;
	SkaarjAssassin.SetHelpText("Check this to use the SkaarjAssassin");
  
	SkaarjBerserker=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 120, 150, 15));
	SkaarjBerserker.SetText("Use SkaarjBerserker: ");
	SkaarjBerserker.bChecked=class'MonsterMadness'.default.bUseSkaarjBerserker;
	SkaarjBerserker.SetHelpText("Check this to use the SkaarjBerserker");
  
	SkaarjLord=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 135, 150, 15));
	SkaarjLord.SetText("Use SkaarjLord: ");
	SkaarjLord.bChecked=class'MonsterMadness'.default.bUseSkaarjLord;
	SkaarjLord.SetHelpText("Check this to use the SkaarjLord");
  
	SkaarjScout=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 150, 150, 15));
	SkaarjScout.SetText("Use SkaarjScout: ");
	SkaarjScout.bChecked=class'MonsterMadness'.default.bUseSkaarjScout;
	SkaarjScout.SetHelpText("Check this to use the SkaarjScout");
  
	SkaarjTrooper=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 165, 150, 15));
	SkaarjTrooper.SetText("Use SkaarjTrooper: ");
	SkaarjTrooper.bChecked=class'MonsterMadness'.default.bUseSkaarjTrooper;
	SkaarjTrooper.SetHelpText("Check this to use the SkaarjTrooper");
  
	SkaarjGunner=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 180, 150, 15));
	SkaarjGunner.SetText("Use SkaarjGunner: ");
	SkaarjGunner.bChecked=class'MonsterMadness'.default.bUseSkaarjGunner;
	SkaarjGunner.SetHelpText("Check this to use the SkaarjGunner");
  
	SkaarjInfantry=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 195, 150, 15));
	SkaarjInfantry.SetText("Use SkaarjInfantry: ");
	SkaarjInfantry.bChecked=class'MonsterMadness'.default.bUseSkaarjInfantry;
	SkaarjInfantry.SetHelpText("Check this to use the SkaarjInfantry");
  
	SkaarjOfficer=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 60, 150, 15));
	SkaarjOfficer.SetText("Use SkaarjOfficer: ");
	SkaarjOfficer.bChecked=class'MonsterMadness'.default.bUseSkaarjOfficer;
	SkaarjOfficer.SetHelpText("Check this to use the SkaarjOfficer");
  
	SkaarjSniper=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 75, 150, 15));
	SkaarjSniper.SetText("Use SkaarjSniper: ");
	SkaarjSniper.bChecked=class'MonsterMadness'.default.bUseSkaarjSniper;
	SkaarjSniper.SetHelpText("Check this to use the SkaarjSniper");
  
	Titan=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 90, 150, 15));
	Titan.SetText("Use Titan: ");
	Titan.bChecked=class'MonsterMadness'.default.bUseTitan;
	Titan.SetHelpText("Check this to use the Titan");
  
	Warlord=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 105, 150, 15));
	Warlord.SetText("Use Warlord: ");
	Warlord.bChecked=class'MonsterMadness'.default.bUseWarlord;
	Warlord.SetHelpText("Check this to use the Warlord");
  
	Fly=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 120, 150, 15));
	Fly.SetText("Use Fly: ");
	Fly.bChecked=class'MonsterMadness'.default.bUseFly;
	Fly.SetHelpText("Check this to use the Fly");
  
	Manta=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 135, 150, 15));
	Manta.SetText("Use Manta: ");
	Manta.bChecked=class'MonsterMadness'.default.bUseManta;
	Manta.SetHelpText("Check this to use the Manta");
  
	CaveManta=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 150, 150, 15));
	CaveManta.SetText("Use CaveManta: ");
	CaveManta.bChecked=class'MonsterMadness'.default.bUseCaveManta;
	CaveManta.SetHelpText("Check this to use the CaveManta");
  
	GiantManta=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 165, 150, 15));
	GiantManta.SetText("Use GiantManta: ");
	GiantManta.bChecked=class'MonsterMadness'.default.bUseGiantManta;
	GiantManta.SetHelpText("Check this to use the GiantManta");
  
	Slith=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 180, 150, 15));
	Slith.SetText("Use Slith: ");
	Slith.bChecked=class'MonsterMadness'.default.bUseSlith;
	Slith.SetHelpText("Check this to use the Slith");
  
	Pupae=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 330, 195, 150, 15));
	Pupae.SetText("Use Pupae: ");
	Pupae.bChecked=class'MonsterMadness'.default.bUsePupae;
	Pupae.SetHelpText("Check this to use the Pupae");
	ProgressLevel=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 235 , 150, 15));
	ProgressLevel.Text="Progress level: ";
	ProgressLevel.bChecked=class'MonsterMadness'.default.bProgressLevel;
	ProgressLevel.
		SetHelpText("Check this to go to the next level when all the monsters are dead.");

	MatchLevel = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 170, 235, 200, 15));
	MatchLevel.Text = "Let nr. of monsters match the level:";
	MatchLevel.bChecked = class'MonsterMadness'.default.bMatchLevel;
	MatchLevel.SetHelpText("Check this to let the number of monsters match the recommended average number of players.");

	NoRespawn=UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, 250, 150, 15));
	NoRespawn.Text="No respawn: ";
	if(ProgressLevel.bChecked)
		NoRespawn.bChecked=true;
	else
		NoRespawn.bChecked=class'monsterMadness'.default.bNoRespawn;
	NoRespawn.SetHelpText("Check this to prevent the monsters from respawning");

	CloseButton=UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton',
					WinWidth-110,WinHeight-20,100,15));


	PositionList=UWindowComboControl(CreateControl(class'UWindowComboControl', 170, 250, 300, 15));
	PositionList.List.AddItem("Top Left");
	PositionList.List.AddItem("Top middle");
	PositionList.List.AddItem("Top Right");
	PositionList.List.AddItem("Middle left");
	PositionList.List.AddItem("Middle right");
	PositionList.List.AddItem("Bottom Left");
	PositionList.List.AddItem("Bottom middle");
	PositionList.List.AddItem("Bottom Right");
	PositionList.bCanEdit=false;
	PositionList.SetSelectedIndex(int(class'MMRadarHUD'.default.Position));
	PositionList.Text="Position: ";
}

function Resized() {
	CloseButton.WinLeft=WinWidth-110;
	CloseButton.WinTop=WinHeight-20;
}

function Notify(UWindowDialogControl C, byte E) {
	local string Radar_Pos;

	switch(E) {
	case DE_Change:
		switch(C) {
		case NrOfMonsters:
			NrOfMonsters.SetText("Initial number of monsters: " $ int(NrOfMonsters.Value));
			class'MonsterMadness'.default.InitialNrOfMonsters=NrOfMonsters.Value;
			break;
		case HealthMultiplier:
			HealthMultiplier.SetText("Health of monsters are multiplied by: " $ getHealthMultiplier());
			class'MonsterMadness'.default.HealthMultiplier = getHealthMultiplier();
			break;
		case Brute:
			class'MonsterMadness'.default.bUseBrute=!class'MonsterMadness'.default.bUseBrute;
			break;
		case Behemoth:
			class'MonsterMadness'.default.bUseBehemoth=!class'MonsterMadness'.default.bUseBehemoth;
			break;
		case LesserBrute:
			class'MonsterMadness'.default.bUseLesserBrute=!class'MonsterMadness'.default.bUseLesserBrute;
			break;
		case Cow:
			class'MonsterMadness'.default.bUseCow=!class'MonsterMadness'.default.bUseCow;
			break;
		case GasBag:
			class'MonsterMadness'.default.bUseGasBag=!class'MonsterMadness'.default.bUseGasBag;
			break;
		case GiantGasBag:
			class'MonsterMadness'.default.bUseGiantGasBag=!class'MonsterMadness'.default.bUseGiantGasBag;
			break;
		case IceSkaarj:
			class'MonsterMadness'.default.bUseIceSkaarj=!class'MonsterMadness'.default.bUseIceSkaarj;
			break;
		case Krall:
			class'MonsterMadness'.default.bUseKrall=!class'MonsterMadness'.default.bUseKrall;
			break;
		case KrallElite:
			class'MonsterMadness'.default.bUseKrallElite=!class'MonsterMadness'.default.bUseKrallElite;
			break;
		case LeglessKrall:
			class'MonsterMadness'.default.bUseLeglessKrall=!class'MonsterMadness'.default.bUseLeglessKrall;
			break;
		case Mercenary:
			class'MonsterMadness'.default.bUseMercenary=!class'MonsterMadness'.default.bUseMercenary;
			break;
		case Queen:
			class'MonsterMadness'.default.bUseQueen=!class'MonsterMadness'.default.bUseQueen;
			break;
		case SkaarjWarrior:
			class'MonsterMadness'.default.bUseSkaarjWarrior=!class'MonsterMadness'.default.bUseSkaarjWarrior;
			break;
		case SkaarjAssassin:
			class'MonsterMadness'.default.bUseSkaarjAssassin=!class'MonsterMadness'.default.bUseSkaarjAssassin;
			break;
		case SkaarjBerserker:
			class'MonsterMadness'.default.bUseSkaarjBerserker=!class'MonsterMadness'.default.bUseSkaarjBerserker;
			break;
		case SkaarjLord:
			class'MonsterMadness'.default.bUseSkaarjLord=!class'MonsterMadness'.default.bUseSkaarjLord;
			break;
		case SkaarjScout:
			class'MonsterMadness'.default.bUseSkaarjScout=!class'MonsterMadness'.default.bUseSkaarjScout;
			break;
		case SkaarjTrooper:
			class'MonsterMadness'.default.bUseSkaarjTrooper=!class'MonsterMadness'.default.bUseSkaarjTrooper;
			break;
		case SkaarjGunner:
			class'MonsterMadness'.default.bUseSkaarjGunner=!class'MonsterMadness'.default.bUseSkaarjGunner;
			break;
		case SkaarjInfantry:
			class'MonsterMadness'.default.bUseSkaarjInfantry=!class'MonsterMadness'.default.bUseSkaarjInfantry;
			break;
		case SkaarjOfficer:
			class'MonsterMadness'.default.bUseSkaarjOfficer=!class'MonsterMadness'.default.bUseSkaarjOfficer;
			break;
		case SkaarjSniper:
			class'MonsterMadness'.default.bUseSkaarjSniper=!class'MonsterMadness'.default.bUseSkaarjSniper;
			break;
		case Titan:
			class'MonsterMadness'.default.bUseTitan=!class'MonsterMadness'.default.bUseTitan;
			break;
		case Warlord:
			class'MonsterMadness'.default.bUseWarlord=!class'MonsterMadness'.default.bUseWarlord;
			break;
		case Fly:
			class'MonsterMadness'.default.bUseFly=!class'MonsterMadness'.default.bUseFly;
			break;
		case Manta:
			class'MonsterMadness'.default.bUseManta=!class'MonsterMadness'.default.bUseManta;
			break;
		case CaveManta:
			class'MonsterMadness'.default.bUseCaveManta=!class'MonsterMadness'.default.bUseCaveManta;
			break;
		case GiantManta:
			class'MonsterMadness'.default.bUseGiantManta=!class'MonsterMadness'.default.bUseGiantManta;
			break;
		case Slith:
			class'MonsterMadness'.default.bUseSlith=!class'MonsterMadness'.default.bUseSlith;
			break;
		case Pupae:
			class'MonsterMadness'.default.bUsePupae=!class'MonsterMadness'.default.bUsePupae;
			break;
		case ProgressLevel:
			class'MonsterMadness'.default.bProgressLevel=ProgressLevel.bChecked;
			if(ProgressLevel.bChecked) {
				NoRespawn.bChecked=true;
				Class'MonsterMadness'.default.bNoRespawn=true;
			}
			break;
		case MatchLevel:
			class'MonsterMadness'.default.bMatchLevel = MatchLevel.bChecked;
			break;
		case NoRespawn:
			class'MonsterMadness'.default.bNoRespawn=NoRespawn.bChecked;
			break;
		case PositionList:
			Radar_Pos=MakeRadarPos(PositionList.GetSelectedIndex());
			GetPlayerOwner().ConsoleCommand("SET MonsterMadness.MMRadarHUD Position" @ Radar_Pos);
			break;
		}
		class'MonsterMadness'.static.StaticSaveConfig();
		class'MonsterMadness'.SaveConfig();
		self.Class.static.StaticSaveConfig();
		self.Class.SaveConfig();
	}
}
function string MakeRadarPos(int i) {
	switch(i) {
		case 0: return "RADAR_TopLeft";
		case 1: return "RADAR_TopMiddle";
		case 2: return "RADAR_TopRight";
		case 3: return "RADAR_MiddleLeft";
		case 4: return "RADAR_MiddleRight";
		case 5: return "RADAR_BottomLeft";
		case 6: return "RADAR_BottomMiddle";
		case 7: return "RADAR_BottomRight";
	}
}

defaultproperties
{
}
