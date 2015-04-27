//=============================================================================
// Queen.
//=============================================================================
class MMQueen extends MMScriptedPawn;

//Queen variables;
var() int ClawDamage,
	StabDamage;
var() name ScreamEvent;

var byte row;
var(Sounds) sound footstepSound;
var(Sounds) sound ScreamSound;
var(Sounds) sound stab;
var(Sounds) sound shoot;
var(Sounds) sound claw;

var bool	bJustScreamed;
var bool	bEndFootStep;
var QueenShield Shield;
var vector TelepDest;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	ProjectileSpeed = 1200 + 100 * Skill;
	GroundSpeed = GroundSpeed * (1 + 0.1 * Skill);
}

event bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	return false;
}

function TryToDuck(vector duckDir, bool bReversed)
{
	if ( (Shield != None) || (AnimSequence == 'Shield') )
		return;

	PlayAnim('Shield', 1.0, 0.1);
	bCrouching = true;
	GotoState('RangedAttack', 'Challenge');
}

function SpawnShield()
{
	Shield = Spawn(class'QueenShield',,,Location + 150 * Vector(Rotation)); 
	Shield.SetBase(self);
}

function ThrowOther(Pawn Other)
{
	local float dist, shake;
	local PlayerPawn aPlayer;
	local vector Momentum;

	if ( Other.mass > 500 )
		return;

	aPlayer = PlayerPawn(Other);				
	if (aPlayer == None)
	{	
		if (Other.Physics != PHYS_Walking)
			return;
		dist = VSize(Location - Other.Location);
		if (dist > 500)
			return;
	}
	else
	{
		dist = VSize(Location - Other.Location);
		shake = FMax(500, 1500 - dist);
		if ( dist > 1500 )
			return;
		aPlayer.ShakeView( FMax(0, 0.35 - dist/20000), shake, 0.015 * shake);
		if ( (Other.Physics != PHYS_Walking) || (dist > 1500) )
			return;
	}
	
	Momentum = -0.5 * Other.Velocity + 100 * Normal(Other.Location - Location);
	Momentum.Z =  7000000.0/((0.5 * dist + 500) * Other.Mass);
	Other.AddVelocity(Momentum);
}

function FootStep()
{
	bEndFootstep = false;
	PlaySound(FootstepSound, SLOT_Interact, 8);
}

function Scream()
{
	local actor A;
	local pawn Thrown;

	if (ScreamEvent != '')
		foreach AllActors( class 'Actor', A, ScreamEvent )
			A.Trigger( Self, Instigator );

	PlaySound(ScreamSound, SLOT_Talk, 2 * TransientSoundVolume);
	PlaySound(ScreamSound, SLOT_None, 2 * TransientSoundVolume);
	PlaySound(ScreamSound, SLOT_None, 2 * TransientSoundVolume);
	PlaySound(ScreamSound, SLOT_None, 2 * TransientSoundVolume);
	PlayAnim('Scream');
	bJustScreamed = true;
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;
	
	if (bEndFootStep)
		FootStep();
	decision = FRand();
	animspeed = 0.2 + 0.5 * FRand();
	LoopAnim('Meditate', animspeed);
}

function PlayChallenge()
{
	if (bEndFootStep)
		FootStep();
	if ( IsAnimating() && (AnimSequence == 'Shield') )
		return;
	Scream();
}

function TweenToFighter(float tweentime)
{
	bEndFootStep = ( ((AnimSequence == 'Walk') || (AnimSequence == 'Run')) && (AnimFrame > 0.1) );   
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	if ( (AnimSequence != 'Run') || !bAnimLoop )
		TweenAnim('Run', tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Meditate', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	TweenAnim('Meditate', tweentime);
}

function PlayRunning()
{
	LoopAnim('Run', -1.0/GroundSpeed,, 0.8);
}

function PlayWalking()
{
	LoopAnim('Walk', -1.0/GroundSpeed,, 0.8);
}

function PlayThreatening()
{
	DesiredSpeed = 0.0;

	if ( FRand() < 0.75)
		PlayAnim('Meditate', 0.4 + 0.6 * FRand(), 0.3);
	else 
	{
		TweenAnim('Fighter', 0.3);
		PlayThreateningSound();
	}
}

function PlayTurning()
{
	if (bEndFootStep)
		FootStep();
	DesiredSpeed = 0.0;
	TweenAnim('Run', 0.4);
}

function PlayDying(name DamageType, vector HitLocation)
{
	PlayAnim('OutCold', 0.7, 0.1);
	PlaySound(Die, SLOT_Talk);	
}

function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
{
	TweenAnim('TakeHit', tweentime);
}

function SpawnShot()
{
	local vector X,Y,Z, projStart;

	GetAxes(Rotation,X,Y,Z);
	
	if (row == 0)
		MakeNoise(1.0);
	
	projStart = Location + 1 * CollisionRadius * X + ( 0.7 - 0.2 * row) * CollisionHeight * Z + 0.2 * CollisionRadius * Y;
	spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, 400 * (4 - row)/(3.5-skill), false, bWarnTarget));

	projStart = Location + 1 * CollisionRadius * X + ( 0.7 - 0.2 * row) * CollisionHeight * Z - 0.2 * CollisionRadius * Y;
	spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, 400 * (4 - row)/(3.5-skill), true, bWarnTarget));
	row++;
}

function PlayVictoryDance()
{
	if (bEndFootStep)
		FootStep();
	DesiredSpeed = 0.0;
	PlayAnim('ThreeHit', 0.7, 0.15); //gib the enemy here!
	PlaySound(Threaten, SLOT_Talk);		
}

function ClawDamageTarget()
{
	if ( MeleeDamageTarget(ClawDamage, (50000.0 * (Normal(Target.Location - Location)))) )
		PlaySound(Claw, SLOT_Interact);
}

function StabDamageTarget()
{
	local vector X,Y,Z;
	GetAxes(Rotation,X,Y,Z);
	
	if ( MeleeDamageTarget(StabDamage, (15000.0 * ( Y + vect(0,0,1)))) )
		PlaySound(Stab, SLOT_Interact);
}

function PlayMeleeAttack()
{
	local float decision;

	if (bEndFootStep)
		FootStep();
	decision = FRand();
	if (decision < 0.4)
	{
		PlaySound(Stab, SLOT_Interact);
 		PlayAnim('Stab');
 	}
	else if (decision < 0.7)
	{
		PlaySound(Claw, SLOT_Interact);
		PlayAnim('Claw');
	} 
	else 
	{
		PlaySound(Claw, SLOT_Interact);
		PlayAnim('Gouge');
	}
}

function TweenToFalling()
{
	TweenAnim('Jump', 0.2);
}

function PlayInAir()
{
	TweenAnim('Jump', 0.5);
}

function PlayLanded(float impactVel)
{
	local Pawn Thrown;

	TweenAnim('Land', 0.1);

	//throw all nearby creatures, and play sound
	Thrown = Level.PawnList;
	While ( Thrown != None )
	{
		ThrowOther(Thrown);
		Thrown = Thrown.nextPawn;
	}
}

function PlayRangedAttack()
{
	if (bEndFootStep)
		FootStep();

	if ( !bJustScreamed && (FRand() < 0.15) )
		Scream();
	else if ( (Shield != None) && (FRand() < 0.5)
		&& (((Enemy.Location - Location) Dot (Shield.Location - Location)) > 0) )
		Scream();
	else
	{
		if ( Shield != None )
			Shield.Destroy();
		row = 0;
		bJustScreamed = false;
		PlayAnim('Shoot1'); 
		PlaySound(Shoot, SLOT_Interact);			
	}
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function PickDestination(bool bNoCharge)
	{
		if ( FRand() < 0.26 )
			GotoState('Teleporting');
		else
			Super.PickDestination(bNoCharge);
	}
}		
		
state Hunting
{
ignores EnemyNotVisible; 

	function PickDestination()
	{
		GotoState('Teleporting');
	}
}


State Teleporting
{
ignores TakeDamage, SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died;

	function Tick(float DeltaTime)
	{
		local int NewFatness; 
		local rotator EnemyRot;

		if ( Style == STY_Translucent )
		{
			ScaleGlow -= 3 * DeltaTime;
			if ( ScaleGlow < 0.3 )
			{
				Spawn(class'QueenTeleportEffect',,, TelepDest);
				Spawn(class'QueenTeleportLight',,, TelepDest);
				EnemyRot = rotator(Enemy.Location - Location);
				EnemyRot.Pitch = 0;
				SetLocation(TelepDest);
				setRotation(EnemyRot);
				PlaySound(sound'Teleport1', SLOT_Interface);
				GotoState('Attacking');
			}
			return;
		}
		else
		{
			NewFatness = fatness - 100 * DeltaTime;
			if ( NewFatness < 80 )
			{
				bUnlit = true;
				ScaleGlow = 2.0;
				Style = STY_Translucent;
			}
		}

		fatness = Clamp(NewFatness, 0, 255);
	}

	function ChooseDestination()
	{
		local QueenDest N;
		local vector ViewPoint, HitLocation, HitNormal, Best;
		local actor HitActor;
		local float rating, newrating;

		Best = Location;
		rating = 0;

		foreach AllActors(class'QueenDest', N) {
				newrating = 0;
				if ( Best == Location )
					Best = N.Location;
				ViewPoint = N.Location + EyeHeight * vect(0,0,1);
				HitActor = Trace(HitLocation, HitNormal, Enemy.Location, ViewPoint, false);
				if ( HitActor == None )
					newrating = 20000;

				newrating = newrating - VSize(N.Location - Enemy.Location) + 1000 * FRand()
							+ 4 * VSize(N.Location - Location);
				if ( N.Location.Z > Enemy.Location.Z )
					newrating += 1000;
				
				if ( newrating > rating )
				{
					rating = newrating;
					Best = N.Location;
				}
		}

		TelepDest = Best;
	}

	function BeginState()
	{
		Acceleration = Vect(0,0,0);
		ChooseDestination();
	}

	function EndState()
	{
		bUnlit = false;
		Style = STY_Normal;
		ScaleGlow = 1.0;
		fatness = Default.fatness;
	}
}

	

defaultproperties
{
     ClawDamage=50
     StabDamage=80
     FootstepSound=Sound'UnrealI.Titan.step1t'
     ScreamSound=Sound'UnrealI.Queen.yell3Q'
     Stab=Sound'UnrealI.Queen.stab1Q'
     Shoot=Sound'UnrealI.Queen.shoot1Q'
     claw=Sound'UnrealI.Queen.claw1Q'
     Aggressiveness=5.000000
     RefireRate=0.400000
     bHasRangedAttack=True
     bCanDuck=True
     bIsBoss=True
     RangedProjectile=Class'UnrealI.QueenProjectile'
     Acquire=Sound'UnrealI.Queen.yell1Q'
     Fear=Sound'UnrealI.Queen.yell2Q'
     Roam=Sound'UnrealI.Queen.nearby2Q'
     Threaten=Sound'UnrealI.Queen.yell2Q'
     MeleeRange=100.000000
     GroundSpeed=400.000000
     AccelRate=1500.000000
     JumpZ=800.000000
     Visibility=250
     SightRadius=3000.000000
     Health=1500
     ReducedDamageType='
     ReducedDamagePct=0.500000
     Intelligence=BRAINS_HUMAN
     HitSound1=Sound'UnrealI.Queen.yell2Q'
     HitSound2=Sound'UnrealI.Queen.yell2Q'
     Die=Sound'UnrealI.Queen.outcoldQ'
     CombatStyle=0.950000
     NameArticle=" the "
     AmbientSound=Sound'UnrealI.Queen.amb1Q'
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.SkQueen'
     SoundRadius=32
     TransientSoundVolume=16.000000
     CollisionRadius=90.199997
     CollisionHeight=106.699997
     Mass=1000.000000
     RotationRate=(Pitch=6000)
}
