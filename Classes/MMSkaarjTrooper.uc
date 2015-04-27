//=============================================================================
// SkaarjTrooper.
//=============================================================================
class MMSkaarjTrooper extends MMSkaarj;
 	
//-----------------------------------------------------------------------------
// SkaarjTrooper variables.

var() class<weapon> WeaponType;
var	  Weapon myWeapon;
var   float  duckTime;

//=========================================================================================


function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( TimeBetweenAttacks == Default.TimeBetweenAttacks )
		TimeBetweenAttacks = TimeBetweenAttacks + (3 - Skill) * 0.3;
	bHasRangedAttack = false;
	bMovingRangedAttack = false;
}

function ChangedWeapon()
{
	Super.ChangedWeapon();
	//bIsPlayer = false;
	bMovingRangedAttack = true;
	bHasRangedAttack = true;
	Weapon.AimError += 200;
	Weapon.FireOffset = Weapon.FireOffset * 1.5 * DrawScale;
	Weapon.PlayerViewOffset = Weapon.PlayerViewOffset * 1.5 * DrawScale; 
	//Weapon.SetHand(0);
}

function TossWeapon()
{
	if ( Weapon == None )
		return;
	Weapon.FireOffset = Weapon.Default.FireOffset;
	Weapon.PlayerViewOffset = Weapon.Default.PlayerViewOffset; 
	Super.TossWeapon();
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	//bIsPlayer = false;
	Super.Died(Killer, damageType, HitLocation);
}

function PlayTakeHit(float tweentime, vector HitLoc, int damage)
{
	if ( GetAnimGroup(AnimSequence) == 'Shielded' )
		TweenAnim('ShldLand', 0.5);
	else
		Super.PlayTakeHit(tweentime, HitLoc, damage);
}

auto state Startup
{
	function BeginState()
	{
		Super.BeginState();
		//bIsPlayer = true; // temporarily, till have weapon
		if ( WeaponType != None )
		{
			//bIsPlayer = true;
			myWeapon = Spawn(WeaponType);
			if ( myWeapon != None )
				myWeapon.ReSpawnTime = 0.0;
		}
	}

	function SetHome()
	{
		Super.SetHome();
		if ( myWeapon != None )
			myWeapon.Touch(self);
	}
}

function Shield()
{
	bFire = 0;
	bAltFire = 0;
	PlayAnim('ShldUp', 2.0, 0.1);
	GotoState('RangedAttack', 'Shieldup');
}

function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	local float MaxSpeed, enemyDist;
	local eAttitude att;
	local vector X,Y,Z, enemyDir;

	att = AttitudeTo(shooter);
	if ( (att == ATTITUDE_Ignore) || (att == ATTITUDE_Threaten) )
	{
		if ( intelligence >= BRAINS_Mammal )
			damageAttitudeTo(shooter);
		if (att == ATTITUDE_Ignore)
			return;	
	}
	
	// AI controlled creatures may duck if not falling
	if ( (Enemy == None) || (Physics == PHYS_Falling) || (FRand() > 0.4 + 0.2 * skill) )
		return;

	// and projectile time is long enough
	enemyDist = VSize(shooter.Location - Location);
	duckTime = enemyDist/projSpeed;
	if (duckTime < 0.1 + 0.15 * FRand()) //FIXME - pick right value
		return;
					
	// only if tight FOV
	GetAxes(Rotation,X,Y,Z);
	enemyDir = (shooter.Location - Location)/enemyDist;
	if ((enemyDir Dot X) < 0.8)
		return;

	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local bool duckLeft;
	local actor HitActor;
	local float decision;

	if ( (FRand() < 0.4) || (VSize(Velocity) < 50) )
	{
		Shield();
		return;
	}
				
	duckDir.Z = 0;
	duckLeft = !bReversed;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	if (HitActor != None)
	{
		duckLeft = !duckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	}
	if (HitActor != None)
	{
		Shield();
		return;
	}

	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir - MaxStepHeight * vect(0,0,1), Location + 200 * duckDir, false, Extent);
	if (HitActor == None)
	{
		Shield();
		return;
	}

	SetFall();
	if ( duckLeft )
		PlayAnim('LeftDodge', 1.35);
	else
		PlayAnim('RightDodge', 1.35);
	Velocity = duckDir * GroundSpeed;
	Velocity.Z = 200;
	SetPhysics(PHYS_Falling);
	GotoState('FallingState','Ducking');
}	

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
	local actor HitActor;
	local float EnemyDist;
		
	EnemyDir = Enemy.Location - Location;
	EnemyDist = VSize(EnemyDir);
	EnemyUp = Enemy.CollisionHeight * vect(0,0,0.8);
	if ( EnemyDist > 300 )
	{
		EnemyDir = 300 * EnemyDir/EnemyDist;
		EnemyUp = 300 * EnemyUp/EnemyDist;
	}
	
	if ( Weapon == None )
		return false;
	
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X * X + 1.2 * Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
	if ( Weapon.IsA('ASMD') || Weapon.IsA('Minigun') || Weapon.IsA('Rifle') ) //instant hit
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location + EnemyUp, projStart, true);
	else
		HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( HitActor == Enemy )
		return true;
	if ( (HitActor != None) && (VSize(HitLocation - Location) < 200) )
		return false;
	if ( (Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) > ATTITUDE_Ignore) )
		return false;

	return true;
}

function PlayCock()
{
	if ( Weapon != None )
	{
		if ( Weapon.CockingSound != None )
			PlaySound(Weapon.CockingSound, SLOT_Interact,,,700);
		else if ( Weapon.SelectSound != None )
			PlaySound(Weapon.CockingSound, SLOT_Interact,,,700);
	}
}

//Skaarj animations
function PlayPatrolStop()
{
	local float decision;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	if ( bButtonPusher )
	{
		PushButtons();
		return;
	}

	SetAlertness(0.2);	
	LoopAnim('Breath', 0.3 + 0.6 * FRand());
}

function PlayChallenge()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	if ( TryToCrouch() )
	{
		TweenAnim('Duck', 0.12);
		return;
	}	
	PlayThreateningSound();
	PlayAnim('Fighter', 0.8 + 0.5 * FRand(), 0.1);
}

function PlayRunning()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;

	bFire = 0;
	bAltFire = 0;
	DesiredSpeed = MaxDesiredSpeed;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	if (Focus == Destination)
	{
		LoopAnim('Jog', -0.9/GroundSpeed,, 0.5);
		return;
	}	
	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	lookDir = Normal(Focus2D - Loc2D);
	moveDir = Normal(Dest2D - Loc2D);
	strafeMag = lookDir dot moveDir;
	if (strafeMag > 0.8)
		LoopAnim('Jog', -1.0/GroundSpeed,, 0.5);
	else if (strafeMag < -0.8)
		LoopAnim('Jog', -1.0/GroundSpeed,, 0.5);
	else
	{
		Y = (lookDir Cross vect(0,0,1));
		if ((Y Dot (Dest2D - Loc2D)) > 0)
		{
			if ( (AnimSequence == 'StrafeRight') || (AnimSequence == 'StrafeRightFr') ) 
				LoopAnim('StrafeRight', -2.5/GroundSpeed,, 1.0);
			else 
				LoopAnim('StrafeRight', -2.5/GroundSpeed,0.1, 1.0);
		}
		else
		{
			if ( (AnimSequence == 'StrafeLeft') || (AnimSequence == 'StrafeLeftFr') ) 
				LoopAnim('StrafeLeft', -2.5/GroundSpeed,, 1.0);
			else
				LoopAnim('StrafeLeft', -2.5/GroundSpeed,0.1, 1.0);
		}
	}
}

function PlayMovingAttack()
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;
	local int bUseAltMode;

	if (Weapon != None)
	{
		if ( Weapon.AmmoType != None )
			Weapon.AmmoType.AmmoAmount = Weapon.AmmoType.Default.AmmoAmount;
		Weapon.RateSelf(bUseAltMode);
		ViewRotation = Rotation;
		if ( bUseAltMode == 0 ) 
		{
			bFire = 1;
			bAltFire = 0;
			Weapon.Fire(1.0);
		}
		else
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
	}
	else
	{
		PlayRunning();
		return;
	}

	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	DesiredSpeed = MaxDesiredSpeed;

	if (Focus == Destination)
	{
		LoopAnim('JogFire', -0.9/GroundSpeed,, 0.4);
		return;
	}	
	Focus2D = Focus;
	Focus2D.Z = 0;
	Loc2D = Location;
	Loc2D.Z = 0;
	Dest2D = Destination;
	Dest2D.Z = 0;
	lookDir = Normal(Focus2D - Loc2D);
	moveDir = Normal(Dest2D - Loc2D);
	strafeMag = lookDir dot moveDir;
	if (strafeMag > 0.8)
		LoopAnim('JogFire', -1.0/GroundSpeed,, 0.4);
	else if (strafeMag < -0.8)
		LoopAnim('JogFire', -1.0/GroundSpeed,, 0.4);
	else
	{
		MoveTimer += 0.2;
		DesiredSpeed = 0.6;
		Y = (lookDir Cross vect(0,0,1));
		if ((Y Dot (Dest2D - Loc2D)) > 0) 
		{
			if ( (AnimSequence == 'StrafeRight') || (AnimSequence == 'StrafeRightFr') ) 
				LoopAnim('StrafeRightFr', -2.5/GroundSpeed,, 1.0); 
			else
				LoopAnim('StrafeRightFr', -2.5/GroundSpeed,0.1, 1.0); 
		}
		else
		{
			if ( (AnimSequence == 'StrafeLeft') || (AnimSequence == 'StrafeLeftFr') ) 
				LoopAnim('StrafeLeftFr', -2.5/GroundSpeed,, 1.0);
			else
				LoopAnim('StrafeLeftFr', -2.5/GroundSpeed,0.1, 1.0);
		}
	}
}

function PlayThreatening()
{
	local float decision, animspeed;

	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	decision = FRand();
	animspeed = 0.4 + 0.6 * FRand(); 
	
	if ( decision < 0.7 )
		PlayAnim('Breath2', animspeed, 0.3);
	else
	{
		PlayThreateningSound();
		PlayAnim('Fighter', animspeed, 0.3);
	}
}

function PlayRangedAttack()
{
	PlayFiring();
}

function PlayFiring()
{
	TweenAnim('Firing', 0.2);
	if ( (Weapon != None) && (Weapon.AmmoType != None) )
		Weapon.AmmoType.AmmoAmount = Weapon.AmmoType.Default.AmmoAmount;
}

function PlayVictoryDance()
{
	PlayAnim('Shield', 0.6, 0.1);
}

function PlayLanded(float impactVel)
{
	if ( GetAnimGroup(AnimSequence) == 'Shielded' )
		TweenAnim('ShldLand', 0.1);
	else if (impactVel > 1.7 * JumpZ)
		PlayAnim('Landed',1.0,0.1);
	else
		TweenAnim('Land', 0.1);
}

state TakeHit 
{
ignores seeplayer, hearnoise, bump, hitwall;

	function BeginState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.BeginState();
	}
}

state Retreating
{
ignores SeePlayer, EnemyNotVisible, HearNoise;

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}
}

state Charging
{
ignores SeePlayer, HearNoise;

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}
}

state TacticalMove
{
ignores SeePlayer, HearNoise;

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}
}

state Hunting
{
ignores EnemyNotVisible; 

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		if ( !Region.Zone.bWaterZone )
			bCanSwim = false;
		Super.EndState();
	}
}

state MeleeAttack
{
ignores SeePlayer, HearNoise, Bump;

ShieldDown:
	DesiredRotation = Rotator(Enemy.Location - Location);
	FinishAnim();
	Goto('Begin');
}


state RangedAttack
{
ignores SeePlayer, HearNoise;
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		if ( (GetAnimGroup(AnimSequence) == 'Shielded') && (AnimSequence != 'ShldFire')
			&& ((Vector(Rotation) Dot Momentum) < -0.6) )
			Damage *= 0.2; 

		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

	function Bump (Actor Other)
	{
		if ( (GetAnimGroup(AnimSequence) == 'Shielded') && (Other == Enemy) )
		{
			PlayAnim('ShldDown');
			GotoState('MeleeAttack', 'ShieldDown');
			return;
		}
		if ( AttackSuccess || (AnimSequence != 'Lunge') )
		{
			Disable('Bump');
			return;
		}
		else		
			LungeDamageTarget();

		if (!AttackSuccess && Pawn(Other) != None) //always add momentum
			Pawn(Other).AddVelocity((60000.0 * (Normal(Other.Location - Location)))/Other.Mass);
	}
	
	function PlayRangedAttack()
	{
		local float dist;

		if ( GetAnimGroup(AnimSequence) == 'Shielded' )
		{
			TweenAnim('ShldFire', 0.05);
			FireWeapon();
			return;
		}

		dist = VSize(Target.Location - Location + vect(0,0,1) * (CollisionHeight - Target.CollisionHeight));
		if ( (FRand() < 0.2) && (dist < 150 + CollisionRadius + Target.CollisionRadius) && (Region.Zone.bWaterZone || !Target.Region.Zone.bWaterZone) )
		{
			PlaySound(Lunge, SLOT_Interact);
	 		Velocity = 500 * (Target.Location - Location)/dist; //instant acceleration in that direction 
	 		Velocity.Z += 1.5 * dist;
	 		if (Physics != PHYS_Swimming)
	 			SetPhysics(PHYS_Falling);
	 		Enable('Bump');
	 		PlayAnim('Lunge');
	 	}
		else
		{
			Disable('Bump');
			FireWeapon();
		}
	}

	function TryToDuck(vector duckDir, bool bReversed)
	{
		if ( FRand() < 0.5 )
			return;
			
		bFire = 0;
		bAltFire = 0;
		if ( AnimSequence == 'ShldFire' )
		{
			TweenAnim('HoldShield', 0.15);
			GotoState('RangedAttack', 'Shieldup');
			return;
		}
		if ( GetAnimGroup(AnimSequence) == 'Shielded' )
		{
			if (FRand() < 0.75)
				GotoState('RangedAttack', 'ShieldUp');
			return;
		}

		Shield();
	}

	function KeepAttacking()
	{
		if ( bFiringPaused )
			return;
		if ( (FRand() > ReFireRate) || (Enemy == None) || (Enemy.Health <= 0) || !CanFireAtEnemy() ) 
		{
			if ( GetAnimGroup(AnimSequence) == 'Shielded' )
			{
				PlayAnim('ShldDown');
				GotoState('RangedAttack', 'ShieldDown');
			}
			else
				GotoState('Attacking');
		}
	}


	function AnimEnd()
	{
		if ( (AnimSequence == 'Lunge') || (FRand() < 0.5) || ((bFire == 0) && (bAltFire == 0)) )
			GotoState('RangedAttack', 'DoneFiring');
		else
			TweenAnim('Firing', 0.5);
	}

	function EndState()
	{
		bFire = 0;
		bAltFire = 0;
		Super.EndState();
	}

ShieldDown:
	Disable('AnimEnd');
	FinishAnim();
	GotoState('Attacking');

Challenge:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayChallenge();
	FinishAnim();
	TweenToFighter(0.1);
	Goto('FaceTarget');

ShieldUp:
	Disable('AnimEnd');
	Acceleration = vect(0,0,0); //stop
	FinishAnim();
	TweenAnim('HoldShield', 0.1);
	DesiredRotation = Rotator(Enemy.Location - Location);
	Sleep(duckTime + FRand());
	if (NeedToTurn(Enemy.Location))
		TurnToward(Enemy);
	Goto('CheckDist');

Begin:
	Acceleration = vect(0,0,0); //stop
	DesiredRotation = Rotator(Enemy.Location - Location);
	TweenToFighter(0.15);
	
FaceTarget:
	Disable('AnimEnd');
	if (NeedToTurn(Enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
		TweenToFighter(0.1);
	}
	FinishAnim();

CheckDist:
	if (VSize(Location - Enemy.Location) < 0.9 * MeleeRange + CollisionRadius + Enemy.CollisionRadius)
		GotoState('MeleeAttack', 'ReadyToAttack'); 

ReadyToAttack:
	if (!bHasRangedAttack)
		GotoState('Attacking');
	DesiredRotation = Rotator(Enemy.Location - Location);
	PlayRangedAttack();
	Enable('AnimEnd');
Firing:
	TurnToward(Enemy);
	Goto('Firing');
DoneFiring:
	Disable('AnimEnd');
	KeepAttacking();  
	Goto('FaceTarget');
}

// WeaponType=Class'UnrealShare.DispersionPistol'

defaultproperties
{
     WeaponType=Class'Botpack.ShockRifle'
     LungeDamage=20
     SpinDamage=15
     ClawDamage=10
     bMayPickupWeapon=True
     CarcassType=Class'monstermadness.MMTrooperCarcass'
     RangedProjectile=None
     GroundSpeed=400.000000
     Health=170
     CombatStyle=0.300000
     Skin=Texture'UnrealI.Skins.sktrooper1'
     Mesh=LodMesh'UnrealI.sktrooper'
     CollisionRadius=32.000000
     CollisionHeight=42.000000
     Mass=125.000000
     Buoyancy=125.000000
}
