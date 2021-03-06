//=============================================================================
// SkaarjBerserker.
//=============================================================================
class MMSkaarjBerserker extends MMSkaarjWarrior;

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	local Pawn aPawn;

	aPawn = Level.PawnList;
	while ( aPawn != None )
	{
		if ( (aPawn.IsA('PlayerPawn') || aPawn.IsA('ScriptedPawn'))
			&& (VSize(Location - aPawn.Location) < 500)
			&& CanSee(aPawn) )
		{
			if ( SetEnemy(aPawn) )
			{
				GotoState('Attacking');
				return;
			}
		}
		aPawn = aPawn.nextPawn;
	}
	
	Super.WhatToDoNext(LikelyState, LikelyLabel);
}	

defaultproperties
{
     LungeDamage=40
     SpinDamage=40
     ClawDamage=20
     VoicePitch=0.300000
     Aggressiveness=0.800000
     Health=320
     Skill=1.000000
     CombatStyle=1.000000
     Skin=Texture'UnrealI.Skins.Skaarjw2'
     DrawScale=1.200000
     Fatness=150
     CollisionHeight=56.000000
     Mass=180.000000
     Buoyancy=180.000000
     RotationRate=(Yaw=50000)
}
