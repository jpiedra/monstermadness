// ============================================================
// MonsterMadness.MonsterMadness: Adds some monsters from
//      Unreal SP to the game. Shooting them will give you
//      frags. Killing a Titan will give you 3 frags.
//
// (C) 2000 by MeltDown - meltdown@thirdtower.com
//
// You may NOT modify this code without written permission from
// the author. You are free to use and distribute this code,
// as long as there is no money charged for it.
// ============================================================

class MonsterMadness expands Mutator config(MonsterMadness);

var bool bInitialized;
var MonsterList Monsters;
var string MonsterTypes[255];
var int NrOfMonsterTypes;
var int MonsterTeam;
var int HumanTeam;

// Used in the state initialSpawn
var int i; 


var() config int InitialNrOfMonsters;
var() config float HealthMultiplier;
var() config string BigMonsters[30];

var() config bool bUseBrute;
var() config bool bUseGasBag;
var() config bool bUseGiantGasBag;
var() config bool bUseIceSkaarj;
var() config bool bUseKrall;
var() config bool bUseKrallElite;
var() config bool bUseLeglessKrall;
var() config bool bUseMercenary;
var() config bool bUseQueen;
var() config bool bUseSkaarjWarrior;
var() config bool bUseSkaarjAssassin;
var() config bool bUseSkaarjBerserker;
var() config bool bUseSkaarjLord;
var() config bool bUseSkaarjScout;
var() config bool bUseSkaarjTrooper;
var() config bool bUseSkaarjGunner;
var() config bool bUseSkaarjInfantry;
var() config bool bUseSkaarjOfficer;
var() config bool bUseSkaarjSniper;
var() config bool bUseTitan;
var() config bool bUseWarlord;
var() config bool bUseFly;
var() config bool bUseManta;
var() config bool bUseCaveManta;
var() config bool bUseGiantManta;
var() config bool bUseSlith;
var() config bool bUsePupae;
var() config bool bUseNaliRabbit;
var() config bool bUseTestQueen;
var() config bool bUseBehemoth;
var() config bool bUseLesserBrute;
var() config bool bUseCow;

var() config bool bProgressLevel;
var() config bool bNoRespawn;
var() config bool bMatchLevel;

replication {
	reliable if(Role == ROLE_Authority) Monsters;
}

simulated function PreBeginPlay() {
	local MMHUDSpawnNotify notify;
	
	notify = spawn(class'MonsterMadness.MMHUDSpawnNotify');
	if(notify == none) {
		Log("Unable to spawn MMHUDSpawnNotify!", Class.Name);
	} else {
		Log("Spawned a MMHudSpawnNotify", Class.Name);
	}

	CreateMonsterTypeList();
	Monsters = Spawn(class'MonsterList');

	Level.Game.bNoMonsters = false;
	class'Pawn'.default.PlayerReplicationInfoClass = class'MMPlayerReplicationInfo';
	class'Bot'.default.PlayerReplicationInfoClass = class'MMBotReplicationInfo';
}

function PostBeginPlay() {
	SetTimer(1.0, false);
}

function Initialize() {
	if(!bInitialized) {
		if(bMatchLevel) {
			GetIdealPlayerCount();
			if(InitialNrOfMonsters <= 0) {
				Log(InitialNrOfMonsters$" is not what we want. Using "$
				    self.default.InitialNrOfMonsters$" monsters instead.", Class.Name);
				InitialNrOfMonsters = self.default.InitialNrOfMonsters;
			}
		}
		SpawnQueenTeleportPoints();
		bInitialized = true;
		//SpawnInitialMonsters();
		GotoState('initialSpawn');
	}
}

event Timer() {
	if(!begunPlay()) {
		//BroadcastMessage("Game hasn't started yet, not initializing");
		// Try again in a second
		SetTimer(1.0, false);
		return;
	}
	Initialize();
}

// Returns 'true' if the game has actually started.
// MonsterMadness will not be initialized, unless
// this function returns 'true'.
function bool begunPlay() {
	local int timeLimit;
	local int timeRemaining;
	
	if(Level.Game.GameReplicationInfo.IsA('TournamentGameReplicationInfo')) {
		timeLimit     = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo).TimeLimit * 60;
		timeRemaining = Level.Game.GameReplicationInfo.RemainingTime;
		if(timeRemaining < timeLimit) return true;
	}

	if(Level.Game.GameReplicationInfo.ElapsedTime > 0) return true;

	return false;
}


function GetIdealPlayerCount() {
	local string strCount, leftStr, rightStr;
	local int minPos, spacePos;
	local int min, max;
	local int playerCount;
	local pawn p;
	
	strCount = Level.IdealPlayerCount;

	if(Len(strCount) == 0) {
		Log("There is no ideal player count", Class.Name);
		return;
	}

	minPos   = InStr(strCount, "-");
	leftStr  = left(strCount, minPos);
	rightStr = right(strCount, len(strcount)-minPos-1);

	do {
		spacePos = InStr(leftStr, " ");
		if(spacePos >= 0) leftStr  = right(leftStr, spacePos-1);
	} until (spacePos < 0);

	do {
		spacePos = InStr(rightStr, " ");
		if(spacePos >= 0) rightStr = left(rightStr, spacePos);
	} until (spacePos < 0);


	min = int(leftStr);
	max = int(rightStr);

	/*
	playerCount = 0;
	for(p = Level.PawnList; p != none; p = p.nextPawn) {
		if(p.IsA('PlayerPawn') || p.IsA('Bot'))
			playerCount++;
	}

	Log("Player count: from "$min$" to "$max, Class.Name);
	Log("Players currently in the game: "$playerCount, Class.Name);
	
	InitialNrOfMonsters = max - playerCount;
	*/
	InitialNrOfMonsters = (max+min)/2;
	Log("Going to use "$InitialNrOfMonsters$" monsters", Class.Name);
}

// Spawns the teleport points needed for the Queen.
function SpawnQueenTeleportPoints() {
	local NavigationPoint N, lastPoint;
	
	// Find the last NavigationPoint in the list
	for (N=Level.NavigationPointList; N.NextNavigationPoint!=None; N=N.NextNavigationPoint);
	lastPoint = N;
	
	for (N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint) {
		if(N!=None && !N.Region.Zone.bWaterZone) {
			// If there isn't enough room, Spawn(...) will fail.
			// If there is enough room, the queen will find it.
			Spawn(class'MMQueenDest',self,,N.Location);
		}
	}
}

function ModifyLogin(out class<playerpawn> SpawnClass, out string Portal, out string Options)
{
	if(SpawnClass.IsA('Bot')) {
		SpawnClass.default.PlayerReplicationInfoClass=class'MMBotReplicationInfo';
		log("Setting default PRIClass for "$SpawnClass.Name$" to MMBotReplicationInfo", Class.Name);
	} else {
		SpawnClass.default.PlayerReplicationInfoClass=class'MMPlayerReplicationInfo';
		log("Setting default PRIClass for "$SpawnClass.Name$" to MMPlayerReplicationInfo", Class.Name);
	}

	if ( NextMutator != None )
		NextMutator.ModifyLogin(SpawnClass, Portal, Options);
}


function CreateMonsterTypeList() {
  local int nr;
  local int maxmonsters;

  if(InitialNrOfMonsters>127) {
    Log("InitialNrOfMonsters can't exceed 127.",Class.Name);
    InitialNrOfMonsters=127;
  }

	if(bUseBrute)     		{ MonsterTypes[nr]="MonsterMadness.MMBrute"; nr++; }
	if(bUseMercenary) 		{ MonsterTypes[nr]="MonsterMadness.MMMercenary"; nr++; }
	if(bUseSkaarjWarrior) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjWarrior"; nr++; }
	if(bUseIceSkaarj) 		{ MonsterTypes[nr]="MonsterMadness.MMIceSkaarj"; nr++; }
	if(bUseSkaarjAssassin) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjAssassin"; nr++; }
	if(bUseSkaarjBerserker) { MonsterTypes[nr]="MonsterMadness.MMSkaarjBerserker"; nr++; }
	if(bUseSkaarjLord) 		{ MonsterTypes[nr]="MonsterMadness.MMSkaarjLord"; nr++; }
	if(bUseSkaarjScout) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjScout"; nr++; }
	if(bUseSkaarjTrooper) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjTrooper"; nr++; }
	if(bUseSkaarjGunner) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjGunner"; nr++; }
	if(bUseSkaarjInfantry) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjInfantry"; nr++; }
	if(bUseSkaarjOfficer) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjOfficer"; nr++; }
	if(bUseSkaarjSniper) 	{ MonsterTypes[nr]="MonsterMadness.MMSkaarjSniper"; nr++; }
	if(bUseQueen) 			{ MonsterTypes[nr]="MonsterMadness.MMQueen"; nr++; }
	if(bUseTitan)     		{ MonsterTypes[nr]="MonsterMadness.MMTitan"; nr++; }
	if(bUseWarlord)   		{ MonsterTypes[nr]="MonsterMadness.MMWarlord"; nr++; }
	if(bUseGasBag) 			{ MonsterTypes[nr]="MonsterMadness.MMGasBag"; nr++; }
	if(bUseGiantGasBag) 	{ MonsterTypes[nr]="MonsterMadness.MMGiantGasBag"; nr++; }
	if(bUseKrall) 			{ MonsterTypes[nr]="MonsterMadness.MMKrall"; nr++; }
	if(bUseKrallElite) 		{ MonsterTypes[nr]="MonsterMadness.MMKrallElite"; nr++; }
	if(bUseLeglessKrall) 	{ MonsterTypes[nr]="MonsterMadness.MMLeglessKrall"; nr++; }
	if(bUseFly) 			{ MonsterTypes[nr]="MonsterMadness.MMFly"; nr++; }
	if(bUseManta) 			{ MonsterTypes[nr]="MonsterMadness.MMManta"; nr++; }
	if(bUseCaveManta)		{ MonsterTypes[nr]="MonsterMadness.MMCaveManta"; nr++; }
	if(bUseGiantManta)		{ MonsterTypes[nr]="MonsterMadness.MMGiantManta"; nr++; }
	if(bUseSlith) 			{ MonsterTypes[nr]="MonsterMadness.MMSlith"; nr++; }
	if(bUsePupae) 			{ MonsterTypes[nr]="MonsterMadness.MMPupae"; nr++; }
	if(bUseNaliRabbit)		{ MonsterTypes[nr]="MonsterMadness.MMNaliRabbit"; nr++; }
	if(bUseTestQueen)		{ MonsterTypes[nr]="MonsterMadness.MMTestQueen"; nr++; }
	if(bUseBehemoth)		{ MonsterTypes[nr]="MonsterMadness.MMBehemoth"; nr++; }
	if(bUseLesserBrute)		{ MonsterTypes[nr]="MonsterMadness.MMLesserBrute"; nr++; }
	if(bUseCow)				{ MonsterTypes[nr]="MonsterMadness.MMCow"; nr++; }

	if(nr==0) {
		Log("No monsters selected to be used. Using brutes only.",Class.Name);
		bUseBrute=true;
		CreateMonsterTypeList();
		return;
	}

	maxmonsters=nr;
	NrOfMonsterTypes=nr;

  for(nr=0; nr<maxmonsters; nr++) {
    if(!MonsterIsBig(MonsterTypes[nr])) {
      MonsterTypes[NrOfMonsterTypes]=MonsterTypes[nr];
      NrOfMonsterTypes++;
    }
  }

  //for(nr=0;nr<NrOfMonsterTypes; nr++)
  //  Log("Monsters used:"@MonsterTypes[nr],Class.Name);
}

function bool MonsterIsBig(string PossibleMonster) {
	local int nr;
  
	for(nr=0; nr<20; nr++) {
    	if(BigMonsters[nr]~=PossibleMonster) return true;
	}
	return false;
}

function SpawnInitialMonsters() {
	local int i;

	for(i=0;i<InitialNrOfMonsters;i++) {
		SpawnRandomMonster();
	}
}

function LogMonsterList() {
	local MonsterList FoundMonster;
	local int NrOfMonsters;
	local Pawn DezePawn;

	NrOfMonsters=0;
	for(FoundMonster=Monsters; FoundMonster!=None; FoundMonster=FoundMonster.NextMonster) {
		if(FoundMonster.Monster==None) {
			if(FoundMonster.bDelayedSpawning)
				Log("LogMonsterList: (MonsterList) Monster is spawning delayed",Class.Name);
			else
				Log("LogMonsterList: (MonsterList) Monster has died",Class.Name);
		} else {
			Log("LogMonsterList: (MonsterList)"@FoundMonster.Monster.GetHumanName()@
				"found, Health:"@FoundMonster.Monster.Health@
				", BigMonster:"@string(MonsterIsBig(string(FoundMonster.Monster.Class))),Class.Name);
			/*if(FoundMonster.Monster.Health>0)*/ NrOfMonsters++;
		}
	}
	Log("LogMonsterList:"@NrOfMonsters@" monsters counted in MonsterList",Class.Name);

	NrOfMonsters=0;
	for(DezePawn=Level.PawnList; DezePawn!=None; DezePawn=DezePawn.NextPawn) {
		if(ScriptedPawn(DezePawn)!=None) {
			Log("LogMonsterList: (PawnList)"@DezePawn.GetHumanName()@"found, Health:"@
			DezePawn.Health,Class.Name);
			NrOfMonsters++;
		}
	}

	Log("LogMonsterList:"@NrOfMonsters@"monsters counted in PawnList",Class.Name);
}


function CountMonsterList(PlayerPawn Sender) {
	local MonsterList FoundMonster;
	local int NrOfMonsters, NrOfWaiting, NrOfGone, NrOfDead;
	local Pawn DezePawn;

	NrOfMonsters = 0;
	NrOfWaiting  = 0;
	NrOfGone     = 0;
	NrOfDead     = 0;
	for(FoundMonster=Monsters; FoundMonster!=None; FoundMonster=FoundMonster.NextMonster) {
		if(FoundMonster.Monster==None) {
			if(FoundMonster.bDelayedSpawning) NrOfWaiting++;
			else NrOfGone++;
		} else {
			if(FoundMonster.Monster.Health>0) NrOfMonsters++;
			else NrOfDead++;
		}
	}
	Sender.ClientMessage("LogMonsterList:"@
			NrOfMonsters@"walking,"@
			NrOfWaiting@"waiting,"@
			NrOfDead@"dead and"@
			NrOfGone@"gone monsters counted in MonsterList");
}


function PlayerList(PlayerPawn Sender)
{
	local PlayerReplicationInfo PRI;
	local MMPlayerReplicationInfo mmPRI;
	local string msg;
	
	Log("--- Player List {", Class.Name);
	ForEach AllActors(class'PlayerReplicationInfo', PRI) {
		mmPRI = MMPlayerReplicationInfo(PRI);
		if(mmPRI == none) {
			msg = PRI.PlayerName$" ( team "$PRI.Team$
				", isMonster -NOT A MMPRI-"$
				", Score "$PRI.Score$")";
		} else {
			msg = PRI.PlayerName$" ( team "$PRI.Team$
				", isMonster "$MMPlayerReplicationInfo(PRI).bIsMonster$
				", Score "$PRI.Score$")";
		}
		log("    "$msg, Class.Name);
		Sender.ClientMessage(msg);
	}
	Log("--- }", Class.Name);
}


function bool SpawnRandomMonster() {
	local string MonsterClass;

	MonsterClass=MonsterTypes[Rand(NrOfMonsterTypes)];
	if(Monsters.AddMonster(MonsterClass)==None) {
	 	Log("Unable to spawn "$MonsterClass, Class.Name);
		return false;
	}
	
	Log("Spawned "$MonsterClass, Class.Name);
	return true;
}

function bool AlwaysKeep(Actor Other) {
  if(Other.IsA('MMScriptedPawn')) return true;
  return Super.AlwaysKeep(Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(Other.IsA('ImpactHammer')) {
		Other.Destroy();
		bSuperRelevant = 1;
		return false;
	}
	return true;
}


function Mutate(string MutateString, PlayerPawn Sender) {
	Super.Mutate(MutateString,Sender);

	if(MutateString ~= "hateme") {
		hateMe(Sender);
		return;
	}

	if(Sender.bAdmin || Level.NetMode==NM_Standalone) {
		if(MutateString~="AddMonster") {
			SpawnRandomMonster();
			BroadcastMessage("Spawned a new monster");
			Log("Mutate: Spawned a new monster",Class.Name);
		} else if(MutateString~="LogMonsterList") {
			LogMonsterList();
		} else if(MutateString~="monstercount") {
			CountMonsterList(Sender);
		} else if(MutateString~="playerlist") {
			PlayerList(Sender);
		} else if(MutateString~="alllist") {
			LogMonsterList();
			CountMonsterList(Sender);
			PlayerList(Sender);
		} else if(MutateString ~= "mmhelp" || MutateString ~= "monsterhelp") {
			Sender.ClientMessage("addmonster, alllist, logmonsterilst, monstercount, playerist");
		}
	}
}


function startDragCarcass(PlayerPawn Other) {
	
}


// Makes all monsters hate Other
function hateMe(PlayerPawn other) {
	local MonsterList FoundMonster;
	local Pawn DezePawn;

	for(FoundMonster=Monsters; FoundMonster!=None; FoundMonster=FoundMonster.NextMonster) {
		if(FoundMonster.Monster == None) continue;
		FoundMonster.Monster.setEnemy(other);
	}
	other.ClientMessage("All monsters are coming to get you now!");
}


// Re-calculate the team score based on the score of the
// individual members
function fixTeamScore() {
	local TournamentGameReplicationInfo GRI;
	local PlayerReplicationInfo PRI;
	local TeamInfo TI;
	local int teamnr;
	local pawn p;
	
	if(!Level.Game.bTeamGame || 
	   !Level.Game.GameReplicationInfo.IsA('TournamentGameReplicationInfo'))
		return;
	
	GRI = TournamentGameReplicationInfo(Level.Game.GameReplicationInfo);
	for(teamnr=0; teamnr<4; teamnr++) {
		TI = GRI.Teams[teamnr];
		if(TI != none) TI.Score = 0;
	}

	for(p = Level.PawnList; p != None; p = p.nextPawn) {
		PRI = p.PlayerReplicationInfo;
		if(PRI == None || PRI.Team == 255) continue;
		TI = GRI.Teams[PRI.Team];
		if(TI == None) continue;
		TI.Score += PRI.Score;
	}	
}

function ScoreKill(Pawn Killer, Pawn Other) {
	local MonsterList KilledMonsterItem;
	local ScriptedPawn NewMonster;
	local DelayedSpawner Spawner;

	Super.ScoreKill(Killer, Other);

	fixTeamScore();
	
	// If it isn't a monster that is killed, we're not interested,
	// because it will all be handled by the superclass.
	if(Other == none || !Other.IsA('ScriptedPawn')) return;

	// Score 2 extra points for big monsters
	if(Killer != None && Killer.bIsPlayer && Killer.PlayerReplicationInfo != None && 
       MonsterIsBig(string(Other.Class))) {
		Killer.PlayerReplicationInfo.Score += 2;
	}

	KilledMonsterItem = Monsters.FindMonster(ScriptedPawn(Other));
	if(KilledMonsterItem == None) {
		Log("ScoreKill: Killed monster ("$Other.GetHumanName()$") could not be found in the monster list.",Class.Name);
		return;
	}

	// When there are no monsters left, we don't do overtime.
	if(Monsters != None && Monsters.MonstersAlive())
		Level.Game.bOverTime = false;
		
	if(bProgressLevel || bNoRespawn) KilledMonsterItem.Monster=None;

	if(bProgressLevel) {
		MaybeProgressLevel();
		//Log("ScoreKill: Progressing gameplay because there are monsters left",Class.Name);
		return;
	}

	if(bNoRespawn) {
		//Log("ScoreKill: not respawining"@Other.Class.Name,Class.Name);
		return;
	}

	Spawner=Spawn(class'DelayedSpawner');
	if(Spawner==None) {
		Log("Failed to spawn a DelayedSpawner!",Class.Name);
		return;
	}
	
	Spawner.MonsterType=Other.Class;
	Spawner.MonsterItem=KilledMonsterItem;
	Spawner.Go(1.0);
}

function MaybeProgressLevel() {
	if(Monsters!=None && Monsters.MonstersAlive()) return;

	/*
	Log("Ending game because all monsters are killed.",Class.Name);
	Level.Game.bOverTime = false;
	*/
	Level.Game.SetEndCams("All monsters are killed!");
	//GameReplicationInfo.GameEndedComments = Reason;
}

// Handle the end of the game. Set the number of
// teams to 4, since bots are in the gold team
function bool HandleEndGame() {
	local TeamGamePlus tgp;

	tgp = TeamGamePlus(Level.Game);
	if(tgp != none) tgp.MaxTeams = 4;

	return super.HandleEndGame();

	// Handle the end of the game. If there are no more
	// monsters, set bOverTime to false and allow the
	// game to end.
	/*
	if(Monsters!=None && Monsters.MonstersAlive())
		return nextMutator.HandleEndGame();
	Level.Game.bOverTime = false;
	return true;
	*/
}

// Prevent monsters from picking up weapons or ammo
function bool HandlePickupQuery(Pawn Other, Inventory item, out byte bAllowPickup)
{
	local MMPlayerReplicationInfo MMPRI;
	local MMScriptedPawn MMOther;

	MMPRI = MMPlayerReplicationInfo(Other.PlayerReplicationInfo);
	if(MMPRI != None && MMPRI.bIsMonster &&
	   (item.IsA('Weapon') || item.IsA('Ammo') || item.IsA('CTFFlag'))) {
	   	MMOther = MMScriptedPawn(Other);
		if(MMOther != none && MMOther.bMayPickupWeapon) {
			bAllowPickup = 1;
			return true;
		}
	   	bAllowPickup = 0;
		return true;
	}
	
	if ( NextMutator != None )
		return NextMutator.HandlePickupQuery(Other, item, bAllowPickup);
	return false;
}

// Make sure that human players will start
// on the blue side of a team map
// FIXME: the original spawning location still
// shows the teleport effect
// FIXME: players shouldn't always be on the blue
// team when playing with the mutator
function ModifyPlayer(Pawn Other)
{
	local NavigationPoint N;
	local NavigationPoint Candidate[16];
	local int num;
	local int teamNr;
	local PlayerStart ps;
	
	Super.ModifyPlayer(Other);

	if(Other == None) return;

	if(Other.PlayerReplicationInfo != None) {
		teamNr = Other.PlayerReplicationInfo.Team;
	} else {
		teamNr = HumanTeam;
	}

	for(N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint) {
		if(N.IsA('PlayerStart')) {
			ps = PlayerStart(N);
			if(ps != none && ps.TeamNumber == teamNr) {
				if (num<16) Candidate[num] = N;
				else if (Rand(num) < 16) Candidate[Rand(16)] = N;
				num++;
			}
		}
	}

	if(num == 0) return;

	Other.SetLocation(Candidate[Rand(Min(16,num))].Location);
}


state initialSpawn {
	function endState() {
		Log("Ending state initialSpawn", Class.Name);
	}
begin:

	Log("In state initialSpawn, going to spawn beasties!", Class.Name);
	for(i=0;i<InitialNrOfMonsters;i++) {
		SpawnRandomMonster();
		sleep(0.5);
	}
	Log("Done spawning beasties, going to default state", Class.Name);
	GotoState('');
}

defaultproperties
{
     MonsterTeam=3
     HumanTeam=2
     InitialNrOfMonsters=5
     HealthMultiplier=2.000000
     BigMonsters(0)="MonsterMadness.MMTitan"
     BigMonsters(1)="MonsterMadness.MMQueen"
     BigMonsters(2)="MonsterMadness.MMWarLord"
     bUseBrute=True
     bUseGasBag=True
     bUseKrall=True
     bUseKrallElite=True
     bUseMercenary=True
     bUseSkaarjWarrior=True
     bUseSkaarjAssassin=True
     bUseSkaarjLord=True
     bUseSkaarjScout=True
     bUseSkaarjOfficer=True
     bUseSkaarjSniper=True
     bUseSlith=True
     bUsePupae=True
     bUseBehemoth=True
}
