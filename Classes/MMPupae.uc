//=============================================================================
// Pupae.
//=============================================================================
class MMPupae extends MMScriptedPawn;

//-----------------------------------------------------------------------------
// Pupae variables.

// Attack damage.
var() byte BiteDamage;		// Basic damage done by bite.
var() byte LungeDamage;		// Basic damage done by bite.
var(Sounds) sound bite;
var(Sounds) sound stab;
var(Sounds) sound lunge;
var(Sounds) sound chew;
var(Sounds) sound tear;
 
//-----------------------------------------------------------------------------
// Pupae functions.

function PostBeginPlay()
{
	Super.PostBeginPlay();
	MaxDesiredSpeed = 0.7 + 0.1 * skill;
}

function JumpOffPawn()
{
	Super.JumpOffPawn();
	PlayAnim('crawl', 1.0, 0.2);
}

function SetMovementPhysics()
{
	SetPhysics(PHYS_Falling); 
}

function PlayWaiting()
	{
	local float decision;
	local float animspeed;
	animspeed = 0.4 + 0.6 * FRand(); 
	decision = FRand();
	if ( !bool(NextAnim) || (decision < 0.4) ) //pick first waiting animation
	{
		if ( !bQuiet )
			PlaySound(Chew, SLOT_Talk, 0.7,,800);
		NextAnim = 'Munch';
	}
	else if (decision < 0.55)
		NextAnim = 'Pick';
	else if (decision < 0.7)
	{
		if ( !bQuiet )
			PlaySound(Stab, SLOT_Talk, 0.7,,800);
		NextAnim = 'Stab';
	}
	else if (decision < 0.7)
		NextAnim = 'Bite';
	else 
		NextAnim = 'Tear';
		
	LoopAnim(NextAnim, animspeed);
	}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayChallenge()
{
	if ( FRand() < 0.3 )
		PlayWaiting();
	else
		PlayAnim('Fighter');
}

function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if (AnimSequence != 'Crawl' || !bAnimLoop)
		TweenAnim('Crawl', tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('Crawl', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Munch', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Munch', tweentime);
}

function PlayRunning()
{
	PlaySound(sound'scuttle1pp', SLOT_Interact);
	LoopAnim('Crawl', -4.0/GroundSpeed,,0.4);
}

function PlayWalking()
{
	PlaySound(sound'scuttle1pp', SLOT_Interact);
	LoopAnim('Crawl', -4.0/GroundSpeed,,0.4);
}

function PlayThreatening()
{
	PlayWaiting();
}

function PlayTurning()
{
	TweenAnim('Crawl', 0.3);
}

function PlayDying(name DamageType, vector HitLocation)
{
	local carcass carc;

	PlaySound(Die, SLOT_Talk, 3.5 * TransientSoundVolume);
	if ( FRand() < 0.35 )
		PlayAnim('Dead', 0.7, 0.1);
	else if ( FRand() < 0.5 )
	{
		carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Mesh = mesh'PupaeHead';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim('Dead2', 0.7, 0.1);
	}
	else
	{
		carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Mesh = mesh'PupaeBody';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim('Dead3', 0.7, 0.1);
	}
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	PlayAnim('TakeHit');
}

function PlayVictoryDance()
{
	PlayAnim('Stab', 1.0, 0.1);
}

function PlayMeleeAttack()
{
	local float dist, decision;

	decision = FRand();
	dist = VSize(Target.Location - Location);
	if (dist > CollisionRadius + Target.CollisionRadius + 45)
		decision = 0.0;

	if (Physics == PHYS_Falling)
		decision = 1.0;
	if (Target == None)
		decision = 1.0;

	if (decision < 0.15)
	{
		PlaySound(Lunge, SLOT_Interact);
		Enable('Bump');
		PlayAnim('Lunge');
		Velocity = 450 * Normal(Target.Location + Target.CollisionHeight * vect(0,0,0.75) - Location);
		if (dist > CollisionRadius + Target.CollisionRadius + 35)
			Velocity.Z += 0.7 * dist;
		SetPhysics(PHYS_Falling);
	}
  	else
  	{
  		PlaySound(Stab, SLOT_Interact);
  		PlayAnim('Stab');
		MeleeRange = 50;
		MeleeDamageTarget(BiteDamage, vect(0,0,0));
		MeleeRange = Default.MeleeRange;
	}  		
}

state MeleeAttack
{
ignores SeePlayer, HearNoise;

	singular function Bump(actor Other)
	{
		Disable('Bump');
		if ( (Other == Target) && (AnimSequence == 'Lunge') )
			if (MeleeDamageTarget(LungeDamage, vect(0,0,0)))
			{
				if (FRand() < 0.5)
					PlaySound(Tear, SLOT_Interact);
				else
					PlaySound(Bite, SLOT_Interact);
			}
	}
}		

auto state StartUp
{
	function SetMovementPhysics()
	{
		SetPhysics(PHYS_None); // don't fall at start
	}
}


state Waiting
{
TurnFromWall:
	if ( NearWall(70) )
	{
		PlayTurning();
		TurnTo(Focus);
	}
Begin:
	TweenToWaiting(0.4);
	bReadyToAttack = false;
	if (Physics != PHYS_Falling) 
		SetPhysics(PHYS_None);
KeepWaiting:
	NextAnim = '';
}

defaultproperties
{
     BiteDamage=10
     LungeDamage=20
     Bite=Sound'UnrealI.Pupae.bite1pp'
     Stab=Sound'UnrealI.Pupae.hiss1pp'
     lunge=Sound'UnrealI.Pupae.hiss2pp'
     Chew=Sound'UnrealI.Pupae.munch1p'
     Tear=Sound'UnrealI.Pupae.tear1pp'
     CarcassType=Class'monstermadness.MMPupaeCarcass'
     Aggressiveness=10.000000
     Acquire=Sound'UnrealI.Pupae.hiss2pp'
     Fear=Sound'UnrealI.Pupae.hiss1pp'
     Roam=Sound'UnrealI.Pupae.roam1pp'
     Threaten=Sound'UnrealI.Pupae.hiss3pp'
     bCanStrafe=True
     MeleeRange=280.000000
     GroundSpeed=260.000000
     WaterSpeed=100.000000
     JumpZ=340.000000
     Visibility=100
     SightRadius=3000.000000
     PeripheralVision=-0.400000
     Health=65
     Intelligence=BRAINS_NONE
     HitSound1=Sound'UnrealI.Pupae.injur1pp'
     HitSound2=Sound'UnrealI.Pupae.injur2pp'
     Die=Sound'UnrealI.Pupae.death1pp'
     CombatStyle=1.000000
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.Pupae1'
     CollisionRadius=28.000000
     CollisionHeight=9.000000
     Mass=80.000000
     RotationRate=(Pitch=3072,Yaw=65000,Roll=0)
}
