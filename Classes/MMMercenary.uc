//=============================================================================
// Mercenary
//=============================================================================
class MMMercenary extends MMScriptedPawn;


//======================================================================
// Mercenary Functions

var() byte PunchDamage;
var() byte OrdersGiven;
var() bool	bButtonPusher;
var() bool  bTalker;
var() bool	bSquatter;
var   bool	bPatroling;
var() bool	bHasInvulnerableShield;
var() bool	bCanFireWhileInvulnerable;
var	  bool  bIsInvulnerable;
var	  bool	bAlertedTeam;

var(Sounds) sound Punch;
var(Sounds) sound PunchHit;
var(Sounds) sound Flip;
var(Sounds) sound CheckWeapon;
var(Sounds) sound WeaponSpray;
var(Sounds) sound syllable1;
var(Sounds) sound syllable2;
var(Sounds) sound syllable3;
var(Sounds) sound syllable4;
var(Sounds) sound syllable5;
var(Sounds) sound syllable6;
var(Sounds) sound breath;
var(Sounds) sound footstep1;
var 	name phrase;
var		byte phrasesyllable;
var		float	voicePitch;
var		int		sprayoffset;
var		float	invulnerableTime;
var()	float	invulnerableCharge;

//======================================================================
// Mercenary Functions

function PreBeginPlay()
{
	bCanSpeak = true;
	voicePitch = 0.5 + 0.75 * FRand();
	Super.PreBeginPlay();
	if ( bHasInvulnerableShield )
		bHasInvulnerableShield = ( Skill > 2.5 * FRand() - 1 ); 
	bCanDuck = bHasInvulnerableShield;
	if ( bMovingRangedAttack )
		bMovingRangedAttack = ( 0.2 * Skill + 0.3 > FRand() );
}

function ZoneChange(ZoneInfo newZone)
{
	bCanSwim = newZone.bWaterZone; //only when it must
		
	if ( newZone.bWaterZone )
		CombatStyle = 1.0; //always charges when in the water
	else if (Physics == PHYS_Swimming)
		CombatStyle = Default.CombatStyle;

	Super.ZoneChange(newZone);
}

event FootZoneChange(ZoneInfo newFootZone)
{
	local float OldPainTime;

	OldPainTime = PainTime;
	Super.FootZoneChange(newFootZone);
	if ( bIsInvulnerable && (PainTime <= 0) )
		PainTime = FMax(OldPainTime, 0.1);
} 

event HeadZoneChange(ZoneInfo newHeadZone)
{
	local float OldPainTime;

	OldPainTime = PainTime;
	Super.HeadZoneChange(newHeadZone);
	if ( bIsInvulnerable && (PainTime <= 0) )
		PainTime = FMax(OldPainTime, 0.1);
}

function SetMovementPhysics()
{
	if ( Region.Zone.bWaterZone )
		SetPhysics(PHYS_Swimming);
	else if (Physics != PHYS_Walking)
		SetPhysics(PHYS_Walking); 
}

function TryToDuck(vector duckDir, bool bReversed)
{
	BecomeInvulnerable();
}

function BecomeInvulnerable()
{
	if ( bIsInvulnerable )
		return;
	if ( invulnerableTime > 0 )
	{
		InvulnerableCharge += (Level.TimeSeconds - InvulnerableTime)/2;
		InvulnerableTime = Level.TimeSeconds;
	}
	if ( InvulnerableCharge > 4 )
		GotoState('Invulnerable');

}

function BecomeNormal()
{
	AmbientGlow = 0;
	bUnlit = false;
	bMeshEnviroMap = false;
	LightType = LT_None;
	InvulnerableTime = Level.TimeSeconds;
	bIsInvulnerable = false;
	if ( !Region.Zone.bPainZone )
		PainTime = -1.0;
}

function PainTimer()
{
	if ( Health <= 0 )
		return;
	if ( !bIsInvulnerable )
	{
		if ( bHasInvulnerableShield && Region.Zone.bPainZone && (Region.Zone.DamagePerSec > 0) )
			BecomeInvulnerable();
		Super.PainTimer();
		if ( bIsInvulnerable )
			PainTime = 1.0;
		return;
	}
	
	InvulnerableCharge -= 1.0;
	if ( (InvulnerableCharge < 0) || (Level.TimeSeconds - InvulnerableTime > 4 + 5 * FRand()) )
		BecomeNormal();
	else
		PainTime = 1.0;

}
		
function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
{
	if ( !bIsInvulnerable )
		Super.WarnTarget(shooter, projSpeed, FireDir);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	if ( !bIsInvulnerable )
		Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	else if ( Damage > 0 )
	{
		InvulnerableCharge = InvulnerableCharge - Damage/100;
		PainTime = 0.3;
		//change to take-damage invulnerable skin
	}
}


//=========================================================================================
// Speech

function SpeechTimer()
{
	//last syllable expired.  Decide whether to keep the floor or quit
	if (FRand() < 0.3)
	{
		bIsSpeaking = false;
		if (TeamLeader != None)
			TeamLeader.bTeamSpeaking = false;
	}
	else
		Speak();
}

function SpeakOrderTo(ScriptedPawn TeamMember)
{
	phrase = '';
	if ( !TeamMember.bCanSpeak || (FRand() < 0.5) )
		Speak();
	else  
	{
		if (Mercenary(TeamMember) != None)
			Mercenary(TeamMember).phrase = '';
		TeamMember.Speak();
	}
}

function SpeakTo(ScriptedPawn Other)
{
	if (Other.bIsSpeaking || ((TeamLeader != None) && TeamLeader.bTeamSpeaking) )
		return;
	
	phrase = '';
	Speak();
}

function Speak()
{
	local float decision;
	
	//if (phrase != '')
	//	SpeakPhrase();
	bIsSpeaking = true;
	decision = FRand();
	if (TeamLeader != None)	
		TeamLeader.bTeamSpeaking = true;
	if (decision < 0.167)
		PlaySound(Syllable1,SLOT_Talk,0.3 + 2 * FRand(),,, FRand() + voicePitch);
	else if (decision < 0.333)
		PlaySound(Syllable2,SLOT_Talk,0.3 + 2 * FRand(),,, FRand() + voicePitch);
	else if (decision < 0.5)
		PlaySound(Syllable3,SLOT_Talk,0.3 + 2 * FRand(),,, FRand() + voicePitch);
	else if (decision < 0.667)
		PlaySound(Syllable4,SLOT_Talk,0.3 + 2 * FRand(),,, FRand() + voicePitch);
	else if (decision < 0.833)
		PlaySound(Syllable5,SLOT_Talk,0.3 + 2 * FRand(),,, FRand() + voicePitch);
	else 
		PlaySound(Syllable6,SLOT_Talk,0.3 + 2 * FRand(),,, FRand() + voicePitch);

	SpeechTime = 0.1 + 0.3 * FRand();
}

//=========================================================================================
function Step()
{
	PlaySound(footstep1, SLOT_Interact,,,1500);
}

function WalkStep()
{
	PlaySound(footstep1, SLOT_Interact,0.2,,500);
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	animspeed = 0.4 + 0.6 * FRand(); 
	decision = FRand();

	if ( bButtonPusher )
	{
		SetAlertness(-1.0);
		if (decision < 0.3)
			LoopAnim('Breath', animspeed, 1.0);
		else if (decision < 0.4)
			LoopAnim('MButton1', animspeed);
		else if (decision < 0.5)
			LoopAnim('MButton2', animspeed);
		else if (decision < 0.6)
			LoopAnim('MButton3', animspeed);
		else if (decision < 0.7)
			LoopAnim('MButton4', animspeed);
		else if (decision < 0.75)
			LoopAnim('Button1', animspeed);
		else if (decision < 0.80)
			LoopAnim('Button2', animspeed);
		else if (decision < 0.85)
			LoopAnim('Button3', animspeed);
		else if (decision < 0.90)
			LoopAnim('Button4', animspeed);
		else if (decision < 0.95)
			LoopAnim('Button5', animspeed);
		else
			LoopAnim('Button6', animspeed);
		return;
	}
	else if ( bTalker ) 
	{
		SetAlertness(-0.5);
		if ( (TeamLeader == None) || TeamLeader.bTeamSpeaking )
		{
			if ( FRand() < 0.1 )
				LoopAnim('NeckCrak', animspeed, 0.5);
			else
				LoopAnim('Breath', animspeed, 0.5);
			return;
		}
		phrase = '';
		Speak();

		if (decision < 0.5)
			LoopAnim('Talk1', animspeed, 0.5);
		else if (decision < 0.75)
			LoopAnim('Talk2', animspeed, 0.5);
		else
			LoopAnim('Talk3', animspeed, 0.5);
		return;
	}
	else if ( bSquatter )
	{
		SetAlertness(-0.5);
		if ( (TeamLeader == None) || TeamLeader.bTeamSpeaking )
		{
			LoopAnim('Squat3', animspeed);
			return;
		}
		phrase = '';
		Speak();
		if (decision < 0.5)
			LoopAnim('Squat1', animspeed);
		else
			LoopAnim('Squat2', animspeed);
		return;
	}

	SetAlertness(0.0);
	if ( bPatroling )
		decision *= 0.4;
	if ( (AnimSequence == 'Breath') && (decision < 0.15) )
	{
		LoopAnim('Weapon', animspeed);			
		PlaySound(CheckWeapon, SLOT_Interact);			
	}
	else if ( (AnimSequence == 'Breath') && (decision < 0.25) )
		LoopAnim('NeckCrak', animspeed);			
	else 
		LoopAnim('Breath', animspeed);
	bPatroling = false;			
}

function PlayPatrolStop()
{
	bPatroling = true;
	PlayWaiting();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
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
	if ( FRand() < 0.6 )
		PlayAnim('Talk1', 0.7, 0.2);
	else 
		PlayAnim('Talk2', 0.7, 0.2);
}


function PlayDive()
{
	TweenToSwimming(0.2);
}

function TweenToFighter(float tweentime)
{
	bButtonPusher = false;
	bTalker = false;
	bSquatter = false;
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
	bButtonPusher = false;
	bTalker = false;
	bSquatter = false;
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	if (AnimSequence != 'Run' || !bAnimLoop)
		TweenAnim('Run', tweentime);
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	if ( bSquatter )
	{
		TweenAnim('Squat3', tweentime);
		return;
	}
	TweenAnim('Breath', tweentime);
}

function TweenToPatrolStop(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		TweenToSwimming(tweentime);
		return;
	}
	TweenAnim('Breath', tweentime);
}

function PlayRunning()
{
	DesiredSpeed = 1.0;
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}

	if (Focus == Destination)
	{
		LoopAnim('Run', -1.0/GroundSpeed,, 0.4);
		return;
	}	

	LoopAnim('Run', StrafeAdjust(),,0.3);

}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	LoopAnim('Walk', 0.8);
}


function TweenToSwimming(float tweentime)
{
	if (AnimSequence != 'Swim' || !bAnimLoop)
		TweenAnim('Swim', tweentime);
}

function PlaySwimming()
{
	LoopAnim('Swim', -1.0/GroundSpeed,,0.3);
}


function TweenToFalling()
{
	TweenAnim('Jump2', 0.35);
}

function PlayInAir()
{
	TweenAnim('Jump2', 0.2);
}

function PlayOutOfWater()
{
	TweenAnim('Land', 0.8);
}

function PlayLanded(float impactVel)
{
	TweenAnim('Land', 0.1);
}

function PlayMovingAttack()
{
	if ( bIsInvulnerable && !bCanFireWhileInvulnerable )
	{
		if ( Level.TimeSeconds - InvulnerableTime < 4 )
		{
			PlayRunning();
			return;
		}
		else
			BecomeNormal();
	}	
	if (Region.Zone.bWaterZone)
	{
		PlayAnim('SwimFire');
		return;
	}
	DesiredSpeed = 0.4;
	MoveTimer += 0.2;
	if ( FRand() < 0.5 )
	{
		if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
			PlayAnim('WalkFire');
		else
			PlayAnim('WalkFire', 1.0, 0.05);
	}
	else
	{
		sprayoffset = 0;
		PlaySound(WeaponSpray, SLOT_Interact);
		if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
			PlayAnim('WalkSpray');
		else
			PlayAnim('WalkSpray', 1.0, 0.05);
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
	animspeed = 0.6 + 0.4 * FRand(); 

	if ( decision < 0.3 )
		PlayAnim('Breath', animspeed, 0.25);
	else if ( decision < 0.45 )
		PlayAnim('Weapon', animspeed, 0.25);
	else
	{
		PlayThreateningSound();
		if ( decision < 0.65 )
			TweenAnim('Fighter', 0.3);
		else if ( decision < 0.85 )
			PlayAnim('Talk1', animspeed, 0.25);
		else 
			PlayAnim('Talk2', animspeed, 0.25);
	}
}

function PlayTurning()
{
	if (Region.Zone.bWaterZone)
	{
		PlaySwimming();
		return;
	}
	TweenAnim('Walk', 0.3);
}

function PlayBigDeath(name DamageType)
{
	PlayAnim('Dead2',0.7,0.1);
	PlaySound(sound'Death3mr', SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayHeadDeath(name DamageType)
{
	local carcass carc;

	if ( ((DamageType == 'Decapitated') || ((Health < -20) && (FRand() < 0.5)))
		 && !Level.Game.bVeryLowGore )
	{
		carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
			carc.Mesh = mesh'MercHead';
			carc.Initfor(self);
			carc.Velocity = Velocity + VSize(Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
		}
		PlayAnim('Dead5',0.7,0.1);
		SprayOffset = 0;
	}
	else
		PlayAnim('Death',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayLeftDeath(name DamageType)
{
	PlayAnim('Dead4',0.7,0.1);
	PlaySound(sound'Death2mr', SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayRightDeath(name DamageType)
{
	PlayAnim('Death',0.7,0.1);
	PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayGutDeath(name DamageType)
{
	PlayAnim('Dead3',0.7,0.1);
	PlaySound(sound'Death2mr', SLOT_Talk, 4 * TransientSoundVolume);
}

function PlayVictoryDance()
{
	//if ( FRand() < 0.5 )
	//{
		PlaySound(Flip, SLOT_Interact);
		PlayAnim('Jump', 1.0, 0.1);
	//}
	//else
	//	PlayAnim('BigDance', 0.7, 0.25);
}

function PlayMeleeAttack()
{
	local float decision;
	decision = FRand();
	if (AnimSequence == 'Swat')
		decision -= 0.2;

	PlaySound(Punch, SLOT_Interact);
	If (decision < 0.3)
 		PlayAnim('Punch'); 
 	else
  		PlayAnim('Swat');
}

function bool CanFireAtEnemy()
{
	local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
	local actor HitActor;
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
	projStart = Location + 0.9 * CollisionRadius * X - 0.6 * CollisionRadius * Y;
	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

	if ( (HitActor == None) || (HitActor == Enemy) 
		|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) )
		return true;

	HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir, projStart , true);

	return ( (HitActor == None) || (HitActor == Enemy) 
			|| ((Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) <= ATTITUDE_Ignore)) );
}

function SpawnRocket()
{
	FireProjectile( vect(0.9, -0.4, 0), 400);
}

function SprayTarget()
{
	local vector EndTrace, fireDir;
	local vector HitNormal, HitLocation;
	local actor HitActor;
	local rotator AdjRot;
	local vector X,Y,Z;

	if(Target == none) return;

	AdjRot = Rotation;
	if ( AnimSequence == 'Dead5' )
		AdjRot.Yaw += 3000 * (2 - sprayOffset);
	else
		AdjRot.Yaw += 1000 * (3 - sprayOffset);

	sprayoffset++;
	fireDir = vector(AdjRot);
	if(sprayoffset == 1 || sprayoffset==3 || sprayoffset == 5) {
		GetAxes(Rotation,X,Y,Z);
		if ( AnimSequence == 'Spray' )
			spawn(class'MercFlare', self, '', 
				Location + 1.25 * CollisionRadius * X - CollisionRadius * (0.2 * sprayoffset - 0.3) * Y);
		else
			spawn(class'MercFlare', self, '',
				Location + 1.25 * CollisionRadius * X - CollisionRadius * (0.1 * sprayoffset - 0.1) * Y);
	}

	if ( AnimSequence == 'Dead5' )
		sprayoffset++;
		
	EndTrace = Location + 2000 * fireDir; 
	EndTrace.Z = Target.Location.Z + Target.CollisionHeight * 0.6;
	HitActor = TraceShot(HitLocation,HitNormal,EndTrace,Location);
	if (HitActor == Level)   // Hit a wall
	{
		spawn(class'SmallSpark2',,,HitLocation+HitNormal*5,rotator(HitNormal*2+VRand()));
		spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);		
	}
	else if (HitActor != None && HitActor != self && HitActor != Owner)
	{
		HitActor.TakeDamage(10, self, HitLocation, 10000.0*fireDir, 'shot');			
		spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);		
	} 
}


function HitDamageTarget()
{
	if (MeleeDamageTarget(PunchDamage, (PunchDamage * 1000 * Normal(Target.Location - Location))))
		PlaySound(PunchHit, SLOT_Interact);
}

function PlayRangedAttack()
{
	//FIXME - if going to ranged attack need to
	//	TweenAnim('StillFire', 0.2);
	//What I need is a tween into time for the PlayAnim()

	if ( bIsInvulnerable && !bCanFireWhileInvulnerable )
	{
		if ( Level.TimeSeconds - InvulnerableTime > 3 )
			BecomeNormal();	
		else if ( FRand() < 0.75 )
		{
			PlayChallenge();
			return;
		}
	}

	if (Region.Zone.bWaterZone)
	{
		PlayAnim('SwimFire');
		return;
	}

	MakeNoise(1.0);
	if (FRand() < 0.35)
	{
		PlayAnim('Shoot');
		SpawnRocket();
	}
	else
	{
		sprayoffset = 0;
		PlaySound(WeaponSpray, SLOT_Interact);
		PlayAnim('Spray');
	}
}

function ChooseLeaderAttack()
{
	if ( bReadyToAttack && bHasInvulnerableShield && !bIsInvulnerable && (InvulnerableCharge > 0) )
	{
		BecomeInvulnerable();
		if ( IsInState('Invulnerable') )
			return;
	}
	if ( !bAlertedTeam && (OrdersGiven < 2) )
	{
		OrdersGiven = OrdersGiven + 1; 
		GotoState('SpeakOrders');
	}
	else
		GotoState('TacticalMove', 'NoCharge');
}

state SpeakOrders
{
	ignores SeePlayer, HearNoise, Bump;


	function Killed(pawn Killer, pawn Other, name damageType)
	{
		Super.Killed(Killer, Other, damageType);
		if ( (Health > 0) && !bTeamLeader )
			GotoState('Attacking');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
	}
		
	function EnemyNotVisible()
	{
	}
		
Begin:
	bAlertedTeam = true;
	Acceleration = vect(0,0,0);
	if (NeedToTurn(enemy.Location))
	{
		PlayTurning();
		TurnToward(Enemy);
	}
	TweenAnim('Talk2', 0.1);
	FinishAnim();
	phrase = '';
	Speak();
	if (FRand() < 0.5)
		PlayAnim('Talk2', 0.6);
	else
		PlayAnim('Talk3', 0.6);
	FinishAnim();
	if (FRand() < 0.3)
		Goto('Done');	
	if (FRand() < 0.5)
		PlayAnim('Talk2', 0.9);
	else
		PlayAnim('Talk3', 0.9);
	FinishAnim();
Done:
	bReadyToAttack = true;
	GotoState('Attacking');
}

state Invulnerable
{
	ignores SeePlayer, HearNoise, Bump;

	function TryToDuck(vector duckDir, bool bReversed)
	{
	}

	function AnimEnd()
	{
		if (AnimSequence == 'Stealth1')
		{
			bIsInvulnerable = true;
			bMeshEnviroMap = true;
			invulnerableTime = Level.TimeSeconds;
			PainTime = 1.0;
			AmbientGlow = 70;
			bUnlit = true;
			LightType=LT_Pulse;
			PlayAnim('Stealth2');
		}
		else
			GotoState('Attacking');
	}		
		
Begin:
	Acceleration = vect(0,0,0);
	PlayAnim('Stealth1', 1.4, 0.07);
KeepTurning:
	TurnToward(Enemy);
	Sleep(0.0);
	Goto('KeepTurning');
}

state RangedAttack
{
ignores SeePlayer, HearNoise;

	function TryToDuck(vector duckDir, bool bReversed)
	{
		if ( bCanFireWhileInvulnerable || (FRand() < 0.5) )
			BecomeInvulnerable();
	}

	function BeginState()
	{
		Super.BeginState();
		if ( !bIsInvulnerable && bHasInvulnerableShield 
			&& bCanFireWhileInvulnerable && (InvulnerableCharge > 4) && (FRand() > 0.75) )
		{
			bReadyToAttack = true;
			BecomeInvulnerable();
		}
	}
}

defaultproperties
{
     PunchDamage=20
     bHasInvulnerableShield=True
     Punch=Sound'UnrealI.Mercenary.swat1mr'
     PunchHit=Sound'UnrealI.Mercenary.hit1mr'
     Flip=Sound'UnrealI.Mercenary.flip1mr'
     CheckWeapon=Sound'UnrealI.Mercenary.weapon1mr'
     WeaponSpray=Sound'UnrealI.Mercenary.spray1mr'
     syllable1=Sound'UnrealI.Mercenary.syl1mr'
     syllable2=Sound'UnrealI.Mercenary.syl2mr'
     syllable3=Sound'UnrealI.Mercenary.syl3mr'
     syllable4=Sound'UnrealI.Mercenary.syl4mr'
     syllable5=Sound'UnrealI.Mercenary.syl5mr'
     syllable6=Sound'UnrealI.Mercenary.syl6mr'
     Footstep1=Sound'UnrealI.Mercenary.walk2mr'
     invulnerableCharge=9.000000
     CarcassType=Class'monstermadness.MMMercCarcass'
     Aggressiveness=0.500000
     RefireRate=0.500000
     bHasRangedAttack=True
     bMovingRangedAttack=True
     bGreenBlood=True
     RangedProjectile=Class'UnrealI.MercRocket'
     Acquire=Sound'UnrealI.Mercenary.chlng2mr'
     Fear=Sound'UnrealI.Mercenary.chlng3mr'
     Roam=Sound'UnrealI.Mercenary.nearbymr'
     Threaten=Sound'UnrealI.Mercenary.chlng3mr'
     bCanStrafe=True
     MeleeRange=50.000000
     GroundSpeed=280.000000
     AirSpeed=300.000000
     AccelRate=800.000000
     Health=180
     UnderWaterTime=-1.000000
     Intelligence=BRAINS_HUMAN
     HitSound1=Sound'UnrealI.Mercenary.injur2mr'
     HitSound2=Sound'UnrealI.Mercenary.injur3mr'
     Land=Sound'UnrealI.Mercenary.land1mr'
     Die=Sound'UnrealI.Mercenary.death1mr'
     CombatStyle=0.500000
     AmbientSound=Sound'UnrealI.Mercenary.amb1mr'
     DrawType=DT_Mesh
     Texture=Texture'UnrealI.Skins.Silver'
     Mesh=LodMesh'UnrealI.Merc'
     CollisionRadius=35.000000
     CollisionHeight=48.000000
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=96
     LightRadius=12
     Mass=150.000000
     Buoyancy=150.000000
     RotationRate=(Pitch=3072,Yaw=65000,Roll=0)
}
