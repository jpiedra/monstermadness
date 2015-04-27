//=============================================================================
// Skaarj.
//=============================================================================
class MMSkaarjWarrior extends MMSkaarj;
	
//-----------------------------------------------------------------------------
// SkaarjWarrior variables.

var(Sounds) sound Blade;

//=========================================================================================

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( skill == 3 )
	{
		SpinDamage = 20;
		ClawDamage = 17;
	}
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local bool duckLeft, bSuccess;
	local actor HitActor;
	local float decision;

	//log("duck");
				
	duckDir.Z = 0;
	duckLeft = !bReversed;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	if ( !bSuccess )
	{
		duckLeft = !duckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	}
	if ( !bSuccess )
		return;
	
	if ( HitActor == None )
		HitLocation = Location + 200 * duckDir;
	HitActor = Trace(HitLocation, HitNormal, HitLocation - MaxStepHeight * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return;
		
	//log("good duck");

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
	local actor HitActor1, HitActor2;
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
	projStart = Location + 0.9 * CollisionRadius * X + CollisionRadius * Y + 0.4 * CollisionHeight * Z;
	HitActor1 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);
	if ( (HitActor1 != Enemy) && (Pawn(HitActor1) != None) 
		&& (AttitudeTo(Pawn(HitActor1)) > ATTITUDE_Ignore) )
		return false;
		 
	projStart = Location + 0.9 * CollisionRadius * X - CollisionRadius * Y + 0.4 * CollisionHeight * Z;
	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( (HitActor2 != Enemy) && (Pawn(HitActor2) != None) 
		&& (AttitudeTo(Pawn(HitActor2)) > ATTITUDE_Ignore) )
		return false;

	if ( (HitActor2 == None) || (HitActor2 == Enemy) || (HitActor1 == None) || (HitActor1 == Enemy) 
		|| (Pawn(HitActor2) != None) || (Pawn(HitActor1) != None) )
		return true;

	HitActor2 = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart , true);

	return ( (HitActor2 == None) || (HitActor2 == Enemy) 
			|| ((Pawn(HitActor2) != None) && (AttitudeTo(Pawn(HitActor2)) <= ATTITUDE_Ignore)) );
}

function PlayCock()
{
	PlaySound(Blade, SLOT_Interact,,,800);
}

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

	decision = FRand();
	if (decision < 0.05)
		{
		SetAlertness(-0.5);
		PlaySound(HairFlip, SLOT_Talk);
		PlayAnim('HairFlip', 0.4 + 0.3 * FRand());
		}
	else 
		{
		SetAlertness(0.2);	
		LoopAnim('Breath', 0.3 + 0.6 * FRand());
		}
	}

function PlayChallenge()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
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

	DesiredSpeed = MaxDesiredSpeed;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	if (Focus == Destination)
	{
		LoopAnim('Jog', -1.0/GroundSpeed,, 0.5);
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

	if (Region.Zone.bWaterZone)
	{
		LoopAnim('SwimFire', -1.0/WaterSpeed,, 0.4); 
		return;
	}
	DesiredSpeed = MaxDesiredSpeed;

	if (Focus == Destination)
	{
		LoopAnim('JogFire', -1.0/GroundSpeed,, 0.4);
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
	else if ( decision < 0.9 )
	{
		PlayThreateningSound();
		PlayAnim('Fighter', animspeed, 0.3);
	}
	else
	{
		PlaySound(HairFlip, SLOT_Talk);
		PlayAnim('HairFlip', animspeed, 0.3);
	}	 
}

function SpawnTwoShots()
{
	local rotator FireRotation;
	local vector X,Y,Z, projStart;

	GetAxes(Rotation,X,Y,Z);
	MakeNoise(1.0);
	projStart = Location + 0.9 * CollisionRadius * X + 0.9 * CollisionRadius * Y + 0.4 * CollisionHeight * Z;
	FireRotation = AdjustAim(ProjectileSpeed, projStart, 400, bLeadTarget, bWarnTarget);  
	spawn(RangedProjectile,self,'',projStart, FireRotation);
		
	projStart = projStart - 1.8 * CollisionRadius * Y;
	FireRotation.Yaw += 400;
	spawn(RangedProjectile,self,'',projStart, FireRotation);
}

function PlayRangedAttack()
{
	if (Region.Zone.bWaterZone)
	{
		LoopAnim('SwimFire', -1.0/WaterSpeed,, 0.4); 
		return;
	}
	PlayAnim('Firing', 1.5); 
}

function PlayVictoryDance()
{
	PlaySound(HairFlip, SLOT_Talk);
	PlayAnim('HairFlip', 0.6, 0.1);
}

defaultproperties
{
     Blade=Sound'UnrealShare.Skaarj.blade1s'
     SpinDamage=16
     ClawDamage=14
     CombatStyle=0.600000
     Mesh=LodMesh'UnrealShare.Skaarjw'
}
