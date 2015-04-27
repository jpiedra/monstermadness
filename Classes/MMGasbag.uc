//=============================================================================
// Gasbag.
//=============================================================================
class MMGasbag extends MMScriptedPawn;

//-----------------------------------------------------------------------------
// Gasbag variables.

// Attack damage.
var() byte
	PunchDamage,	// Basic damage done by each punch.
	PoundDamage;	// Basic damage done by pound.

var(Sounds)	sound Punch;
var(Sounds) sound Pound;
var(Sounds) sound PunchHit;
var GasBag ParentBag;
var int numChildren;

//-----------------------------------------------------------------------------
// Gasbag functions.

function string GetHumanName() {
	return "Gasbag";
}

function Destroyed()
{
	if ( ParentBag != None )
		ParentBag.numChildren--;
	Super.Destroyed();
}

function PreSetMovement()
{
	bCanJump = true;
	bCanWalk = true;
	bCanSwim = false;
	bCanFly = true;
	bCanDuck = true;
	MinHitWall = -0.6;
	if (Intelligence > BRAINS_Reptile)
		bCanOpenDoors = true;
	if (Intelligence == BRAINS_Human)
		bCanDoSpecial = true;
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;

	//log("duck");			
	duckDir.Z = 0;
	if ( (Skill == 0) && (FRand() < 0.5) )
		DuckDir *= -1;	

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 100 * duckDir, Location, false, Extent);
	if (HitActor != None)
	{
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 100 * duckDir, Location, false, Extent);
	}
	if (HitActor != None)
		return;

	//log("good duck");
	Destination = Location + 150 * duckDir;
	Velocity = 400 * duckDir;
	AirSpeed *= 2.5;
	GotoState('TacticalMove', 'DoMove');
}	

function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying); 
}

singular function Falling()
{
	SetPhysics(PHYS_Flying);
}

function PlayWaiting()
	{
	local float decision;
	local float animspeed;
	animspeed = 0.3 + 0.5 * FRand(); 

	decision = FRand();
	if (!bool(NextAnim)) //pick first waiting animation
		NextAnim = 'Float';
		
	LoopAnim(NextAnim, animspeed);
	////log("Next brute waiting anim is "$nextanim);
	if (NextAnim == 'Float')
		{
		if (decision < 0.15)
			NextAnim = 'Fiddle';			
		}
	else if (NextAnim == 'Fiddle')
		{
		if (decision < 0.5)
			NextAnim = 'Float';
		else if (decision < 0.65)
			NextAnim = 'Grab';
 		}
 	else
 		NextAnim = 'Float';
	}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence == 'Belch') && IsAnimating() )
		return;
	if ( (AnimSequence != 'Float') || !bAnimLoop )
		TweenAnim('Float', tweentime);
}

function TweenToWalking(float tweentime)
{
	if ( (AnimSequence != 'Float') || !bAnimLoop )
		TweenAnim('Float', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Float', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Float', tweentime);
}

function PlayRunning()
{
	if ( AnimSequence == 'Belch' )
		LoopAnim('Float', -1.0/AirSpeed, 0.5, 0.4);
	else
		LoopAnim('Float', -1.0/AirSpeed,, 0.4);
}

function PlayWalking()
{
	LoopAnim('Float', -1.0/AirSpeed,, 0.4);
}


function PlayThreatening()
{
	local float decision;

	decision = FRand();
	
	if ( decision < 0.7 )
		PlayAnim('Float', 0.4, 0.4);
	else if ( decision < 0.8 )
		PlayAnim('ThreatBelch', 0.4, 0.25);
	else
	{
		PlayThreateningSound();
		TweenAnim('Fighter', 0.3);
	}
}

function PlayTurning()
{
	LoopAnim('Float');
}
function PlayDying(name DamageType, vector HitLocation)
{
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
	if ( FRand() < 0.5 )
		PlayAnim('Deflate', 0.7, 0.1);
	else
		PlayAnim('Dead2', 0.7, 0.1);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	if ( FRand() < 0.6 )
		TweenAnim('TakeHit', tweentime);
	else
		TweenAnim('Hit2', 1.5 * tweentime);
}

function TweenToFalling()
{
	TweenAnim('Float', 0.2);
}

function PlayInAir()
{
	LoopAnim('Float');
}

function PlayLanded(float impactVel)
{
	PlayAnim('Float');
}


function PlayVictoryDance()
{
	PlayAnim('Pound', 0.6, 0.1);
	PlaySound(PunchHit, SLOT_Interact);		
}
	
function PlayMeleeAttack()
{
	local vector adjust;
	adjust = vect(0,0,0);
	adjust.Z = Target.CollisionHeight;
	Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
	if (FRand() < 0.5)
	{
		PlaySound(Punch, SLOT_Interact);
		PlayAnim('TwoPunch');
	}
	else
	{
		PlaySound(Pound, SLOT_Interact);
		PlayAnim('Pound');
	};
}

function PlayRangedAttack()
{
	local vector adjust;
	adjust = vect(0,0,0);
	adjust.Z = Target.CollisionHeight + 20;
	Acceleration = AccelRate * Normal(Target.Location - Location + adjust);
	PlayAnim('Belch');
}

function SpawnBelch()
{
	spawn(RangedProjectile ,self,'',Location,AdjustAim(ProjectileSpeed, Location, 400, bLeadTarget, bWarnTarget));
}

function PunchDamageTarget()
{
	if (MeleeDamageTarget(PunchDamage, (PunchDamage * 1300 * Normal(Target.Location - Location))))
		PlaySound(PunchHit, SLOT_Interact);
}

function PoundDamageTarget()
{
	if (MeleeDamageTarget(PoundDamage, (PoundDamage * 800 * Normal(Target.Location - Location))))
		PlaySound(PunchHit, SLOT_Interact);
}

function PlayMovingAttack()
{
	if ( AnimSequence == 'Float' )
		PlayAnim('Belch', 1.0, 0.2);
	else
		PlayAnim('Belch');
}

State TacticalMove
{
ignores SeePlayer, HearNoise;

	function EndState()
	{
		AirSpeed = Default.AirSpeed;
		Super.EndState();
	}
}

defaultproperties
{
     PunchDamage=12
     PoundDamage=25
     Punch=Sound'UnrealI.Gasbag.twopunch1g'
     Pound=Sound'UnrealI.Gasbag.twopunch1g'
     PunchHit=Sound'UnrealI.Gasbag.hit1g'
     CarcassType=Class'monstermadness.MMGassiusCarcass'
     Aggressiveness=0.700000
     RefireRate=0.500000
     bHasRangedAttack=True
     bMovingRangedAttack=True
     RangedProjectile=Class'UnrealI.GasBagBelch'
     ProjectileSpeed=600.000000
     Acquire=Sound'UnrealI.Gasbag.yell2g'
     Fear=Sound'UnrealI.Gasbag.injur2g'
     Roam=Sound'UnrealI.Gasbag.nearby1g'
     Threaten=Sound'UnrealI.Gasbag.yell3g'
     bCanStrafe=True
     MeleeRange=50.000000
     AirSpeed=200.000000
     JumpZ=10.000000
     SightRadius=2000.000000
     FovAngle=120.000000
     Health=200
     HitSound1=Sound'UnrealI.Gasbag.injur1g'
     HitSound2=Sound'UnrealI.Gasbag.injur2g'
     Die=Sound'UnrealI.Gasbag.death1g'
     CombatStyle=0.400000
     AmbientSound=Sound'UnrealI.Gasbag.amb2g'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.GasBagM'
     CollisionRadius=56.000000
     CollisionHeight=36.000000
     Mass=120.000000
     RotationRate=(Pitch=8192,Yaw=65000,Roll=2048)
}
