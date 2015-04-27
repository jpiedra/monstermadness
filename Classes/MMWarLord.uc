//=============================================================================
// Warlord.
//=============================================================================
class MMWarlord extends MMScriptedPawn;

//FIXME - use TakeOff animation (maybe for falling start)

var() byte	StrikeDamage;
var() bool	bTeleportWhenHurt;
var float	LastDuckTime;

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	MinHitWall = -0.6;
	bCanOpenDoors = true;
	bCanDoSpecial = true;
	bCanDuck = true;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	if ( bTeleportWhenHurt )
	{
		Health = 1000;
		PlayAnim('Teleport');
		GotoState('Teleporting');
	}
	else
		Super.Died(Killer, damageType, HitLocation);
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local bool duckLeft, bSuccess;
	local actor HitActor;
	local float decision;

	//log("duck");
	if ( Level.TimeSeconds - LastDuckTime < 0.6 - 0.1 * skill )
		return;	
				
	duckLeft = !bReversed;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;

	if ( (Physics != PHYS_Flying) && (FRand() < 0.4) ) // try to duck up
	{
		HitActor = Trace(HitLocation, HitNormal, Location + vect(0,0,300), Location, false, Extent);
		if ( HitActor == None )
		{
			if ( FRand() < 0.7 )
				PlayAnim('Fly', 1.6, 0.1);
			else
				PlayAnim('FDodgeUp');
			SetPhysics(PHYS_Flying);
			Destination = Location  + vect(0,0,300);
			Velocity = AirSpeed * vect(0,0,1);
			LastDuckTime = Level.TimeSeconds;
			GotoState('TacticalMove', 'DoMove');				
			return;
		}
	}		
		
	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	bSuccess = ( HitActor == None );
	if ( !bSuccess )
	{
		duckLeft = !duckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
		bSuccess = ( HitActor == None );
	}
	if ( !bSuccess )
		return;
	
	LastDuckTime = Level.TimeSeconds;
	if ( FRand() < 0.7 )
		PlayAnim('Fly', 1.6, 0.1);
	else if ( duckLeft )
		PlayAnim('FDodgeL');
	else
		PlayAnim('FDodgeR');

	SetPhysics(PHYS_Flying);
	Destination = Location + 200 * duckDir;
	Velocity = AirSpeed * duckDir;
	GotoState('TacticalMove', 'DoMove');
}	

event Landed(vector HitNormal)
{
	SetPhysics(PHYS_Walking);
	if ( !IsAnimating() )
		PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
	bJustLanded = true;
}

function Step()
{
	PlaySound(sound'step1t', SLOT_Interact);
}

function Flap()
{
	PlaySound(sound'fly1WL', SLOT_Interact);
}

function SetMovementPhysics()
{
	if (Enemy != None)
	{
		if (Physics == PHYS_None)
			SetPhysics(PHYS_Walking);
		else if ( Region.Zone.bWaterZone || (Physics != PHYS_Walking) )
			SetPhysics(PHYS_Flying);
	} 
	else if (Physics != PHYS_Falling)
		SetPhysics(PHYS_Walking);
}

singular function Falling()
{
	SetPhysics(PHYS_Flying);
}

function PlayWaiting()
{
	local float decision;

	if (AnimSequence == 'Land')
	{
		TweenAnim('Breath', 0.3);
		return;
	}

	PlaySound(sound'breath1WL', SLOT_Interact);
	if (FRand() < 0.9)
		LoopAnim('Breath', 0.2 + 0.7 * FRand());
	else
		LoopAnim('Twirl', 0.5 + 0.5 * FRand());
}

function PlayPatrolStop()
{
	if (Physics == PHYS_Flying)
		LoopAnim('Fly', 0.7);
	else
		PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	if (Physics == PHYS_Flying)
		PlayAnim('Fly', 0.7, 0.1);
	else if ( FRand() < 0.5 )
	{
		PlaySound(sound'laugh1WL', SLOT_Talk);
		PlayAnim('Laugh', 0.7, 0.1);
	}
	else
		PlayAnim('Point', 0.7, 0.1);
}

function TweenToFighter(float tweentime)
{
	if (Physics == PHYS_Flying)
		TweenAnim('Fly', tweentime);
	else
		TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( IsAnimating() && ((AnimSequence == 'WalkFire') || (AnimSequence == 'FlyFire')) )
		return;
	if (Physics == PHYS_Flying)
	{
		if ( (GetAnimGroup(AnimSequence) != 'Dodge') && ((AnimSequence != 'Fly') || !bAnimLoop) )
			TweenAnim('Fly', tweentime);
	}
	else if ( (AnimSequence != 'Run') || !bAnimLoop )
		TweenAnim('Run', tweentime);

}

function TweenToWalking(float tweentime)
{
	if (Physics == PHYS_Flying)
		TweenAnim('Fly', tweentime);
	else
		TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	PlayAnim('Land', 0.2 + 0.8 * FRand());
	SetPhysics(PHYS_Falling);
}

function TweenToPatrolStop(float tweentime)
{
	if (Physics == PHYS_Flying)
	{
		if (FRand() < 0.3)
		{
			SetPhysics(PHYS_Falling);
			PlayAnim('Land', 0.7);
		}
		else
			TweenAnim('Fly', tweentime);
	}
	else
		TweenAnim('Breath', tweentime);

}

function PlayRunning()
{
	if (Physics == PHYS_Walking)
		LoopAnim('Run', -1.0/GroundSpeed,, 0.4);
	else
		LoopAnim('Fly', -1.0/AirSpeed,, 0.4);
}

function PlayWalking()
{
	if (Physics == PHYS_Walking)
		LoopAnim('Walk', -1.4/GroundSpeed,, 0.4);
	else
		LoopAnim('Fly', -1.7/AirSpeed,, 0.4);
}

function PlayThreatening()
{
	if (Physics == PHYS_Walking)
		TweenAnim('Fighter', 0.3);
	else
		LoopAnim('Fly', 0.6);
}

function PlayTurning()
{
	if (Physics == PHYS_Walking)
		TweenAnim('Walk', 0.3);
	else
		LoopAnim('Fly');
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk);
	if ( Physics == PHYS_Flying )
		PlayAnim('Dead2A', 0.7, 0.12);
	else
		PlayAnim('Dead1', 0.7, 0.12);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	TweenAnim('TakeHit', tweentime);
}

function TweenToFalling()
{
	TweenAnim('Fly', 0.2);
}

function PlayInAir()
{
	LoopAnim('Fly');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Land');
}

function PlayVictoryDance()
{
	PlayAnim('Strike', 0.6, 0.1);
}
	
function PlayMeleeAttack()
{
	if (Physics == PHYS_Flying)
	{
		PlayRangedAttack();
		return;
	}
	PlayAnim('Strike');
	if ( MeleeDamageTarget(StrikeDamage, (StrikeDamage * 1000.0 * Normal(Target.Location - Location))) )
		PlaySound(Threaten, SLOT_Talk); 
}


function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
	local actor HitActor;
	local rotator EnemyRot;
	local float EnemyDist;
		
	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.9);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}
	
	GetAxes(Rotation,X,Y,Z);
	projStart = Location - 0.5 * CollisionRadius * Y;
	HitActor = Trace(HitLocation, HitNormal, 
				projStart + EnemyDir + EnemyUp,
				projStart , true);

	if ( (HitActor == None) || (HitActor == Enemy) 
			|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart , true);

	return ( (HitActor == None) || (HitActor == Enemy) 
			|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) );
}

function PlayRangedAttack()
{
	local vector X,Y,Z, projStart;
	local rotator projRotation;
	if (Physics == PHYS_Flying)
		PlayAnim('FlyFire');
	else
		PlayAnim('Fire');
	 
	GetAxes(Rotation,X,Y,Z);
	projStart = Location - 0.5 * CollisionRadius * Y;
	projRotation = AdjustAim(ProjectileSpeed, projStart, 0, bLeadTarget, bWarnTarget); 
	spawn(RangedProjectile ,self,'',projStart,projRotation);
}

function PlayMovingAttack()
{
	local vector X,Y,Z, projStart;
	local rotator projRotation;
	if (Physics == PHYS_Flying)
		PlayAnim('FlyFire');
	else
	{
		DesiredSpeed = 0.4;
		PlayAnim('WalkFire');
	}
	GetAxes(Rotation,X,Y,Z);
	projStart = Location - 0.5 * CollisionHeight * Y;
	projRotation = AdjustAim(ProjectileSpeed, projStart, 600, bLeadTarget, bWarnTarget); 
	if ( FRand() < 0.5 )
	{
		if (FRand() < 0.5)
			projRotation.Yaw += 3072; 
		else
			projRotation.Yaw -= 3072; 
	}
	spawn(RangedProjectile ,self,'',projStart,projRotation);
}

State Charging
{
	function HitWall(vector HitNormal, actor Wall)
	{
		if ( (Physics == PHYS_Flying) && (HitNormal.Z > 0.7) )
		{
			SetPhysics(PHYS_Walking);
			return;
		}
		Super.HitWall(HitNormal, Wall);
	}

	function BeginState()
	{
		local vector HitLocation, HitNormal;
		local actor HitActor;

		if ( (Enemy.Location.Z > Location.Z + MaxStepHeight) || (FRand() < 0.3) )
		{
			Velocity.Z = 400;
			SetPhysics(PHYS_Flying);
		}
		else if ( !Region.Zone.bWaterZone )
		{	
			HitActor = Trace(HitLocation, HitNormal, Location - 2 * CollisionHeight * vect(0,0,1), Location, true);
			if (HitActor == Level)
				SetPhysics(PHYS_Falling);
		}				
		Super.BeginState();
	}
}

State TacticalMove
{
	function HitWall(vector HitNormal, actor Wall)
	{
		if (HitNormal.Z > 0.7)
		{
			SetPhysics(PHYS_Walking);
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('TacticalMove', 'AdjustFromWall');
		else
		{
			DesiredRotation = Rotator(Enemy.Location - location);
			GotoState('Attacking');
		}
	}

	function BeginState()
	{
		local vector HitLocation, HitNormal;
		local actor HitActor;

		if ( (FRand() < 0.3) || 
				(Enemy.Location.Z - Location.Z) > MaxStepHeight + 2 * (CollisionHeight - Enemy.CollisionHeight) )
		{
			Velocity.Z = 400;
			SetPhysics(PHYS_Flying);
		}
		else if ( !Region.Zone.bWaterZone )
		{	
			HitActor = Trace(HitLocation, HitNormal, Location - 2 * CollisionHeight * vect(0,0,1), Location, true);
			if (HitActor == Level)
				SetPhysics(PHYS_Falling);
		}				
		Super.BeginState();
	}

}

State Teleporting
{
ignores TakeDamage, SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died;

	function Tick(float DeltaTime)
	{
		local Actor A;

		ScaleGlow -= 3 * DeltaTime;
		if ( ScaleGlow < 0.3 )
		{
			PlaySound(sound'Teleport2',, 8.0);
			if ( Event != '' )
				ForEach AllActors( class'Actor', A, Event )
					A.Trigger( Self, Enemy );
			Destroy();
		}
	}

	function BeginState()
	{
		bStasis = false;
		SetPhysics(PHYS_None);
		Disable('Tick');
	}
		
Begin:
	FinishAnim();
	Style = STY_Translucent;
	bUnlit = true;
	ScaleGlow = 2.0;
	Enable('Tick');
}

state Mutilating
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
	}

	function Bump(actor Other)
	{
		if ( Other.IsA('Pawn') && Pawn(Other).bIsPlayer )
			GotoState('Mutilating', 'FinalSequence');
	}
	
	function EnemyAcquired()
	{
		GotoState('Mutilating', 'FinalSequence');
	}
	
	function AnimEnd()
	{
		local float decision;

		decision = FRand();
		if ( AnimSequence == 'Grab' )
			PlayAnim('Munch', 0.3 + 0.7 * FRand());
		else if ( decision < 0.2 )
			PlayAnim('GKick1', 0.3 + 0.7 * FRand());
		else if ( decision < 0.4 )
			PlayAnim('GKick2', 0.3 + 0.7 * FRand());
		else if ( decision < 0.6 )
			PlayAnim('GPunch1', 0.3 + 0.7 * FRand());
		else if ( decision < 0.8 )
			PlayAnim('GPunch2', 0.3 + 0.7 * FRand());
		else
			PlayAnim('Grab', 0.3 + 0.7 * FRand());
	}
 
	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		Enemy = None;
		Acceleration = vect(0,0,0);
		SetAlertness(0.0);
		Health = 100000;
	}

FinalSequence:
	Disable('AnimEnd');
	PlayTurning();
	TurnToward(Enemy);
	PlayAnim('Point', 0.7, 0.15);
	FinishAnim();
	PlaySound(sound'laugh1WL', SLOT_Talk);
	PlayAnim('Laugh', 0.7);
	FinishAnim();
	GotoState('Attacking');
Begin:
	TweenToWaiting(0.2);
	bReadyToAttack = false;
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
	SetRotation(DesiredRotation);
	if (Physics != PHYS_Falling) 
		SetPhysics(PHYS_None);
}

defaultproperties
{
     StrikeDamage=40
     CarcassType=Class'monstermadness.MMWarlordCarcass'
     Aggressiveness=0.500000
     RefireRate=0.700000
     WalkingSpeed=0.250000
     bHasRangedAttack=True
     bMovingRangedAttack=True
     bIsBoss=True
     RangedProjectile=Class'UnrealI.WarlordRocket'
     Acquire=Sound'UnrealI.WarLord.acquire1WL'
     Fear=Sound'UnrealI.WarLord.threat1WL'
     Roam=Sound'UnrealI.WarLord.roam1WL'
     Threaten=Sound'UnrealI.WarLord.threat1WL'
     bCanStrafe=True
     MeleeRange=70.000000
     GroundSpeed=440.000000
     AirSpeed=440.000000
     AccelRate=1500.000000
     SightRadius=3000.000000
     Health=1100
     ReducedDamageType=exploded
     Intelligence=BRAINS_HUMAN
     HitSound1=Sound'UnrealI.WarLord.injur1WL'
     HitSound2=Sound'UnrealI.WarLord.injur2WL'
     Die=Sound'UnrealI.WarLord.DeathCry1WL'
     CombatStyle=0.500000
     NameArticle=" the "
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.WarlordM'
     TransientSoundVolume=12.000000
     CollisionRadius=52.000000
     CollisionHeight=78.000000
     Mass=1000.000000
}
