// ===============================================================
// MonsterMadness.MMScriptedPawn: Makes scripted pawns extra
// aggressive towards players

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================
class MMScriptedPawn expands ScriptedPawn;

var MonsterList monsterListItem;
var bool bMayPickupWeapon;
var float deadTime;

function HidePlayer()
{
	SetCollision(false, false, false);
	TweenToFighter(0.01);
	Destroy();
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	local pawn aPawn;

	Super.Killed(Killer, Other, damageType);

	if(Enemy == None) {
		aPawn = Level.PawnList;
		while(aPawn != None ) {
			if(AttitudeTo(aPawn) == ATTITUDE_HATE &&
			   VSize(Location - aPawn.Location) < 500 &&
			   CanSee(aPawn) ) {
				if(SetEnemy(aPawn)) {
					GotoState('Attacking');
					return;
				}
			}
			aPawn = aPawn.nextPawn;
		}	
	}
}	

function bLog(coerce string S, optional name Tag) {
	Super.Log(S, Tag);
	BroadcastMessage(Tag$": "$S);
}

function tick(float deltaTime) {
	Super.tick(deltaTime);
	
	// Fix for bug #2
	if(Health <= 0) {
		deadTime += deltaTime;
		if(deadTime > 2) {
			Log("Had to make a monster commit suicide because he has been dead for 2 sec. and still walking", Class.Name);
			Died(None, 'Suicided', Location);
		}

		// Nobody sees me, so I'm gone.
		if(bHidden) Destroy();
	} else {
		deadTime = 0;
	}
}

function ManagePRI() {
	//Log("-------- ManagePRI() {", Class.Name);
	//Log("    checking for PRI", Class.Name);
	if(PlayerReplicationInfo == None) {
		if(monsterListItem == None) {
			//Log("    My monsterlistItem is none!", Class.Name);
			if(Owner.IsA('MonsterList')) {
				//Log("    My owner ("$Owner$") is a MonsterList, using that.", Class.Name);
				monsterListItem = MonsterList(Owner);
				PlayerReplicationInfo = monsterListItem.MonsterPRI;
			}
		} else {
			//Log("    Got my PRI from my monsterListItem", Class.Name);
			PlayerReplicationInfo = monsterListItem.MonsterPRI;
		}
		if(PlayerReplicationInfo == None) {
			//Log("    Giving myself a new PRI", Class.Name);
			PlayerReplicationInfo = spawn(class'MMPlayerReplicationInfo', self,, Location);
		}
	} else {
		//Log("    Keeping old PRI", Class.Name);
	}

	if(PlayerReplicationInfo == none) {
		Log("ManagePRI(): Unable to give myself a PRI!!!", Class.Name);
	}

	//Log("    My PRI now is "$PlayerReplicationInfo, Class.Name);
	//Log("    My PRI now is a "$PlayerReplicationInfo.Class, Class.Name);
	//Log("    My owner is "$Owner, Class.Name);
	if(monsterListItem != None) {
		//Log("    Storing my PRI in monsterListItem for later use", Class.Name);
		monsterListItem.MonsterPRI = PlayerReplicationInfo;
	}
	//Log("    My score is "$PlayerReplicationInfo.Score, Class.Name);
	//Log("-------- }", Class.Name);
}

function PostBeginPlay() {
	if(Role==ROLE_Authority || Level.NetMode == NM_Standalone) ManagePRI();
	InitPlayerReplicationInfo();
}


function InitPlayerReplicationInfo() {
	local MMPlayerReplicationInfo PRI;

	PRI=MMPlayerReplicationInfo(Self.PlayerReplicationInfo);
	if(PRI == None) {
		Log("InitPlayerReplicationInfo: PRI=None!", Class.Name);
		return;
	}
	PRI.PlayerName = GetHumanName();
	PRI.bIsMonster = true;
	if(Level.Game.bTeamGame)
		PRI.Team   = class'MonsterMadness'.default.MonsterTeam;
	else
		PRI.Team   = 0;
}

function string GetHumanName() {
	local int pos;
	local string FullName;

	FullName = Super.GetHumanName();

	pos = InStr(FullName, "MM");
	if(pos != -1) FullName = Right(FullName, Len(FullName) - pos - 2);

	return FullName;
}

function damageAttitudeTo(pawn Other)
{
	local eAttitude OldAttitude;
	
	if ( (Other == Self) || (Other == None) || (FlockPawn(Other) != None) )
		return;

	// MonsterMadness:: Don't rely on Other.isPlayer
	if( Other.IsA('PlayerPawn') || Other.IsA('Bot')) //change attitude to player
	{ //FIXME - also frenzy or run away against non-players
		if ( (Health < 30) && (Aggressiveness * FRand() > 0.5) )	
		{
			AttitudeToPlayer = ATTITUDE_Frenzy;
			Aggressiveness = 1.0;
		}
		else if (AttitudeToPlayer == ATTITUDE_Ignore) AttitudeToPlayer = ATTITUDE_Hate;
		else if (AttitudeToPlayer == ATTITUDE_Threaten) AttitudeToPlayer = ATTITUDE_Hate;
		else if (AttitudeToPlayer == ATTITUDE_Friendly) AttitudeToPlayer = ATTITUDE_Threaten;
	}
	else 
	{
		OldAttitude = AttitudeToCreature(Other);
		if (OldAttitude > ATTITUDE_Ignore )
			return;
		else if ( OldAttitude > ATTITUDE_Frenzy )
		{
			//log(class$" hates "$Other.class);
			Hated = Other;
		}
	}
	SetEnemy(Other);				
}


function eAttitude AttitudeTo(Pawn Other)
{
	if(Other.IsA('MMScriptedPawn')) return ATTITUDE_Friendly;
	return ATTITUDE_Hate;
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	return AttitudeTo(Other);
}

// toss out the weapon currently held
function TossWeapon()
{
	if(Weapon == None) return;
	if(Weapon.IsA('ImpactHammer')) {
		Weapon.Destroy();
		Weapon = None;
		return;
	}

	Super.TossWeapon();
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn currentEnemy;

	if ( (Other == Self) || (Health <= 0) )
		return;
	
	if(EventInstigator == none) {
		SetEnemy(currentEnemy);
		return;
	}
	
	if ( bHateWhenTriggered )
	{
		if ( EventInstigator.bIsPlayer)
			AttitudeToPlayer = ATTITUDE_Hate;
		else
			Hated = EventInstigator;
	}
	currentEnemy = Enemy;
	SetEnemy(EventInstigator);
	if (Enemy != currentEnemy)
	{	
		PlayAcquisitionSound();
		GotoState('Attacking');
	}
}

simulated event Destroyed()
{
	local Inventory Inv;
	local Pawn OtherPawn;

	if ( Shadow != None )
		Shadow.Destroy();
	if ( Role < ROLE_Authority )
		return;

	RemovePawn();

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )   
		Inv.Destroy();
	Weapon = None;
	Inventory = None;
	
	// Don't destroy the PRI, it has to be moved to another monster
	PlayerReplicationInfo = none;

	//if ( bIsPlayer && (Level.Game != None) )
	//	Level.Game.logout(self);
	
	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed(None, self, '');
	Super(Actor).Destroyed();
}


function bool SetEnemy( Pawn NewEnemy )
{
	local bool result;
	local eAttitude newAttitude, oldAttitude;
	local bool noOldEnemy;
	local float newStrength;

	if ( !bCanWalk && !bCanFly && !NewEnemy.FootRegion.Zone.bWaterZone )
		return false;
	if ( (NewEnemy == Self) || (NewEnemy == None) || (NewEnemy.Health <= 0) )
		return false;
	if ( (PlayerPawn(NewEnemy) == None) && (ScriptedPawn(NewEnemy) == None) &&
		 (Bot(NewEnemy) == None))
		return false;

	noOldEnemy = (Enemy == None);
	result = false;
	newAttitude = AttitudeTo(NewEnemy);
	//log ("Attitude to potential enemy is "$newAttitude);
	if ( !noOldEnemy )
	{
		if (Enemy == NewEnemy)
			return true;
		else if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
		} 
		else if ( newAttitude == ATTITUDE_Friendly )
		{
			if ( bIgnoreFriends )
				return false;
			if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) ) 
			{
				if ( NewEnemy.Enemy.bIsPlayer && (NewEnemy.AttitudeToPlayer < AttitudeToPlayer) )
					AttitudeToPlayer = NewEnemy.AttitudeToPlayer;
				if ( AttitudeTo(NewEnemy.Enemy) < AttitudeTo(Enemy) )
				{
					OldEnemy = Enemy;
					Enemy = NewEnemy.Enemy;
					result = true;
				}
			}
		}
		else 
		{
			oldAttitude = AttitudeTo(Enemy);
			if ( (newAttitude < oldAttitude) || 
				( (newAttitude == oldAttitude) 
					&& ((VSize(NewEnemy.Location - Location) < VSize(Enemy.Location - Location)) 
						|| !LineOfSightTo(Enemy)) ) ) 
			{
				if ( bIsPlayer && Enemy.IsA('PlayerPawn') && !NewEnemy.IsA('PlayerPawn') )
				{
					newStrength = relativeStrength(NewEnemy);
					if ( (newStrength < 0.2) && (relativeStrength(Enemy) < FMin(0, newStrength))  
						&& (IsInState('Hunting')) && (Level.TimeSeconds - HuntStartTime < 5) )
						result = false;
					else
					{
						result = true;
						OldEnemy = Enemy;
						Enemy = NewEnemy;
					}
				} 
				else
				{
					result = true;
					OldEnemy = Enemy;
					Enemy = NewEnemy;
				}
			}
		}
	}
	else if ( newAttitude < ATTITUDE_Ignore )
	{
		result = true;
		Enemy = NewEnemy;
	}
	else if ( newAttitude == ATTITUDE_Friendly ) //your enemy is my enemy
	{
		//log("noticed a friend");
		if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
		{
			Enemy = NewEnemy;
			result = true;
		} 
		if (bIgnoreFriends)
			return false;

		if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) ) 
		{
			result = true;
			//log("his enemy is my enemy");
			Enemy = NewEnemy.Enemy;
			if (Enemy.bIsPlayer)
				AttitudeToPlayer = ScriptedPawn(NewEnemy).AttitudeToPlayer;
			else if ( (ScriptedPawn(NewEnemy) != None) && (ScriptedPawn(NewEnemy).Hated == Enemy) )
				Hated = Enemy;
		}
	}

	if ( result )
	{
		//log(class$" has new enemy - "$enemy.class);
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Location;
		EnemyAcquired();
		if ( !bFirstHatePlayer && Enemy.bIsPlayer && (FirstHatePlayerEvent != '') )
			TriggerFirstHate();
	}
	else if ( NewEnemy.bIsPlayer && (NewAttitude < ATTITUDE_Threaten) )
		OldEnemy = NewEnemy;
				
	return result;
}


State Patroling
{

	function Trigger( actor Other, pawn EventInstigator )
	{
		if(EventInstigator != none && bDelayedPatrol) {
			if (bHateWhenTriggered) {
				if (EventInstigator.bIsPlayer)
					AttitudeToPlayer = ATTITUDE_Hate;
				else
					Hated = EventInstigator;
			}
			GotoState('Patroling', 'Patrol');
		}
		else
			Global.Trigger(Other, EventInstigator);
	}

}

state Threatening
{
ignores falling, landed;

	function Trigger( actor Other, pawn EventInstigator )
	{
		if (EventInstigator != None && EventInstigator.bIsPlayer)
		{
			Enemy = EventInstigator;
			AttitudeToPlayer = ATTITUDE_Hate;
			GotoState('Attacking');
		}
	}
}

state GameEnded
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer;

	function BeginState()
	{
		SetPhysics(PHYS_None);
		PlayWaiting();
		bHidden = false;
	}
}

defaultproperties
{
     bAlwaysRelevant=True
}
