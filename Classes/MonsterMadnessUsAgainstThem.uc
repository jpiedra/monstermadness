// ===============================================================
// MonsterMadness.MonsterMadnessUsAgainstThem: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class MonsterMadnessUsAgainstThem expands TeamGamePlus;

var() int MonsterTeam;
var() int HumanTeam;

function PreBeginPlay()
{
	local Mutator aMutator, theMMMutator;
	local bool foundMM;
	
	class'MonsterMadness'.default.MonsterTeam = MonsterTeam;
 	class'MonsterMadness'.default.HumanTeam   = HumanTeam;
	
	Super.PreBeginPlay();

	foundMM = false;
	for(aMutator=BaseMutator; aMutator!=None; aMutator=aMutator.NextMutator) {
		if(aMutator.IsA('MonsterMadness')) {
			foundMM = true;
			theMMMutator = aMutator;
			Log("Found MonsterMadness mutator!", Class.Name);
			break;
		}
	}
	if(!foundMM) {
		Log("Didn't find Monster Madness mutator, loading now.", Class.Name);
		aMutator                = BaseMutator;
		BaseMutator             = spawn(class'MonsterMadness');
		BaseMutator.NextMutator = aMutator;
		theMMMutator            = BaseMutator;
	}
}

function PostBeginPlay() {
	Super.PostBeginPlay();

	Teams[MonsterTeam].TeamName = "Them"; TeamColor[MonsterTeam] = "Them";
	Teams[HumanTeam].TeamName = "Us";     TeamColor[HumanTeam]   = "Us";

	MaxTeams = 2;

	if(LocalLog != None) {
		LocalLog.Destroy();
		LocalLog = None;
	}
	if(WorldLog != None) {
		WorldLog.Destroy();
		WorldLog = None;
	}
}

event PostLogin( playerpawn NewPlayer )
{
	NewPlayer.PlayerReplicationInfo.Team = HumanTeam;
	Super.PostLogin(NewPlayer);
}

function bool IsOnTeam(Pawn Other, int TeamNum)
{
	if(Other == None) return false;
	if((Other.IsA('PlayerPawn') || Other.IsA('Bot'))   && Other.PlayerReplicationInfo.Team == TeamNum ) return true;
	if(Other.IsA('ScriptedPawn') && TeamNum == 0) return true;

	return false;
}


function ReBalance() {
}

function AddToTeam( int num, Pawn Other) {
	if(Other == None) return;
	if(Other.IsA('PlayerPawn') || Other.IsA('Bot')) Super.AddToTeam(num, Other);
	if(Other.IsA('ScriptedPawn')) Teams[MonsterTeam].size++;
}

function bool ChangeTeam(Pawn Other, int NewTeam) {
	if((Other.IsA('PlayerPawn') || Other.IsA('Bot')) && Other.PlayerReplicationInfo.Team != HumanTeam) {
		AddToTeam(HumanTeam, Other);
		return true;
	} else if(Other.IsA('ScriptedPawn')) {
		AddToTeam(MonsterTeam, Other);
		return true;
	}
	return false;
}

function TeamInfo GetTeam(int TeamNum )
{
	if ( TeamNum < MaxTeams )
		return Teams[TeamNum];
	else return None;
}

function int teamNr(pawn Other) {
	if(Other == None) return 0;

	if(Other.IsA('PlayerPawn') || Other.IsA('Bot')) return HumanTeam;
	return MonsterTeam;
}

function int ReduceDamage( int Damage, name DamageType, pawn injured, pawn instigatedBy )
{
	if(injured.Region.Zone.bNeutralZone) Damage = 0;

	if(instigatedBy == None) return Damage;

	if(instigatedBy != injured && 
	   injured.bIsPlayer &&
	   instigatedBy.bIsPlayer &&
	   teamNr(injured) == teamNr(instigatedBy)) {
		if(injured.IsA('Bot')) Bot(Injured).YellAt(instigatedBy);
		return (Damage * FriendlyFireScale);
	} else {
		return Damage;
	}
}

function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[16], Best;
	local float Score[16], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;
	local byte Team;

	if ( bStartMatch && (Player != None) && Player.IsA('TournamentPlayer') 
		&& (Level.NetMode == NM_Standalone)
		&& (TournamentPlayer(Player).StartSpot != None) )
		return TournamentPlayer(Player).StartSpot;

	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = teamNr(Player);

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	if ( Team == 255 )
		Team = 0;
				
	//choose candidates	
	for ( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
	{
		Dest = PlayerStart(N);
		if ( (Dest != None) && Dest.bEnabled
			&& (!bSpawnInTeamArea || (Team == Dest.TeamNumber)) )
		{
			if (num<16)
				Candidate[num] = Dest;
			else if (Rand(num) < 16)
				Candidate[Rand(16)] = Dest;
			num++;
		}
	}

	if (num == 0 )
	{
		log("Didn't find any player starts in list for team"@Team@"!!!"); 
		foreach AllActors( class'PlayerStart', Dest )
		{
			if (num<16)
				Candidate[num] = Dest;
			else if (Rand(num) < 16)
				Candidate[Rand(16)] = Dest;
			num++;
		}
		if ( num == 0 )
			return None;
	}

	if (num>16) 
		num = 16;
	
	//assess candidates
	for (i=0;i<num;i++)
	{
		if ( Candidate[i] == LastStartSpot )
			Score[i] = -6000.0;
		else
			Score[i] = 4000 * FRand(); //randomize
	}		
	
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) && !OtherPlayer.IsA('Spectator') )
			for (i=0; i<num; i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone ) 
				{
					Score[i] -= 1500;
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < 2 * (CollisionRadius + CollisionHeight))
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && (teamNr(OtherPlayer) != Team)
							&& FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= (10000.0 - NextDist);
				}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1; i<num; i++)
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	LastStartSpot = Best;
				
	return Best;
}

function String getPlayerName(pawn Other) {
	if(Other == None)
		return "getPlayerName(None)";
	if((Other.IsA('PlayerPawn') || Other.IsA('Bot'))&& Other.PlayerReplicationInfo != None)
		return Other.PlayerReplicationInfo.PlayerName;
	if(Other.IsA('ScriptedPawn'))
		return Other.GetHumanName();
	return String(Other.Class.Name);
}
		
//------------------------------------------------------------------------------
// Level death message functions.
function Killed( pawn Killer, pawn Other, name damageType )
{
	local String Message, KillerWeapon, OtherWeapon;
	local bool bSpecialDamage;

	if(Other == None) {
		Log("Killed: Other = None!!", Class.Name);
		return;
	}

	if((Killer == None || Killer.IsA('PlayerPawn')  || Killer.IsA('Bot')) && 
	   (Other.IsA('PlayerPawn') || Other.IsA('Bot'))) {
		Super.Killed(Killer, Other, damageType);
		return;
	}


	if ( (Killer != None) && (!Killer.bIsPlayer) ) {
		Message = Killer.KillMessage(damageType, Other);
		BroadcastMessage( Message, false, 'DeathMessage');
		return;
	}
		
	if ( (DamageType == 'SpecialDamage') && (SpecialDamageString != "") ) {
		BroadcastMessage( ParseKillMessage(
				getPlayerName(Killer),
				getPlayerName(Other),
				Killer.Weapon.ItemName,
				SpecialDamageString
				),
			false, 'DeathMessage');
		bSpecialDamage = True;
	}
	if(Other.PlayerReplicationInfo != None)
		Other.PlayerReplicationInfo.Deaths += 1;

	if ( (Killer == Other) || (Killer == None) ) {
		if (!bSpecialDamage && !MMPlayerReplicationInfo(Other.PlayerReplicationInfo).bIsMonster) {
			if ( damageType == 'Fell' )
				BroadcastLocalizedMessage(DeathMessageClass, 2, Other.PlayerReplicationInfo, None);
			else if ( damageType == 'Eradicated' )
				BroadcastLocalizedMessage(DeathMessageClass, 3, Other.PlayerReplicationInfo, None);
			else if ( damageType == 'Drowned' )
				BroadcastLocalizedMessage(DeathMessageClass, 4, Other.PlayerReplicationInfo, None);
			else if ( damageType == 'Burned' )
				BroadcastLocalizedMessage(DeathMessageClass, 5, Other.PlayerReplicationInfo, None);
			else if ( damageType == 'Corroded' )
				BroadcastLocalizedMessage(DeathMessageClass, 6, Other.PlayerReplicationInfo, None);
			else if ( damageType == 'Mortared' )
				BroadcastLocalizedMessage(DeathMessageClass, 7, Other.PlayerReplicationInfo, None);
			else
				BroadcastLocalizedMessage(DeathMessageClass, 1, Other.PlayerReplicationInfo, None);
		}
	} else {
		KillerWeapon = "None";
		if (Killer.Weapon != None) KillerWeapon = Killer.Weapon.ItemName;
		OtherWeapon = "None";
		if (Other.Weapon != None) OtherWeapon = Other.Weapon.ItemName;
		if (!bSpecialDamage && (Other != None))
			BroadcastRegularDeathMessage(Killer, Other, damageType);
	}
	ScoreKill(Killer, Other);
}

function ScoreKill(pawn Killer, pawn Other)
{
	local int killerTeam, otherTeam;
	local MMPlayerReplicationInfo KPRI, OPRI;
	local MMBotReplicationInfo KBRI, OBRI;
	local string msg;
	
	killerTeam = teamNr(Killer);
	otherTeam  = teamNr(Other);
	
	msg = "(Killer=";
	if(Killer != None) {
		KPRI = MMPlayerReplicationInfo(Killer.PlayerReplicationInfo);
		KBRI = MMBotReplicationInfo(Killer.PlayerReplicationInfo);
		killer.killCount++;
		msg = msg $ Killer.GetHumanName();
	} else {
		msg = msg $ "None";
	}
	msg = msg $ ", Other=";
	if(Other != None) {
		OPRI = MMPlayerReplicationInfo(Other.PlayerReplicationInfo);
		OBRI = MMBotReplicationInfo(Other.PlayerReplicationInfo);
		Other.DieCount++;
		msg = msg $ Other.GetHumanName();
	} else {
		msg = msg $ "None";
	}
	msg = msg $ ")";

	if(Killer == Other || Killer == None) {
		Teams[otherTeam].Score -= 1;
		if(OPRI!=None) OPRI.Score -= 1;
		else if(OBRI != None) OBRI.Score -= 1;
		else Log("ScoreKill: OPRI=None "$msg, Class.Name);
	} else if(killerTeam != otherTeam) {
		Teams[killerTeam].Score += 1;
		if(KPRI!=None) KPRI.Score += 1;
		else if(KBRI != None) KBRI.Score += 1;
		else Log("ScoreKill: KPRI=None "$msg, Class.Name);
	} else if(FriendlyFireScale > 0) {
		Teams[otherTeam].Score -= 1;
		if(OPRI!=None) OPRI.Score -= 1;
		else if(OBRI!=None) OBRI.Score -= 1;
		else Log("ScoreKill: OPRI=None "$msg, Class.Name);
	}

	BaseMutator.ScoreKill(Killer, Other);

	if((bOverTime || GoalTeamScore > 0) && 
	   Killer.bIsPlayer &&
	   Teams[killerTeam].Score >= GoalTeamScore ) {
		EndGame("teamscorelimit");
	}
}

function bool SetEndCams(string Reason) {
	local bool result;
	
	if(Teams[MonsterTeam].Score > Teams[HumanTeam].Score)
		Reason = "They have proven to be stronger...";
	if(Teams[MonsterTeam].Score < Teams[HumanTeam].Score)
		Reason = "We have been victorious!";
	if(Teams[MonsterTeam].Score == Teams[HumanTeam].Score)
		Reason = "Let's call it a draw, shall we?";
	result = super.SetEndCams(Reason);
	if(result) GameReplicationInfo.GameEndedComments = Reason;
	return result;
}

defaultproperties
{
     HumanTeam=1
     MaxAllowedTeams=2
     GoalTeamScore=350.000000
     FragLimit=30
     bUseTranslocator=True
     StartUpMessage="Let's get those bastards!"
     MaxCommanders=2
     MapPrefix=""
     BeaconName="MMUAT"
     GameName="Us against Them"
     bLoggingGame=False
}
