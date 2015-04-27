//=============================================================================
// WarlordCarcass.
//=============================================================================
class MMWarlordCarcass extends MMCreatureCarcass;

























































function AnimEnd()
{
	if ( AnimSequence == 'Dead2A' )
	{
		if ( Physics == PHYS_None )
		{
			LieStill();
			PlayAnim('Dead2B', 0.7, 0.07);
		}
		else
			LoopAnim('Fall');
	} 
	else if ( Physics == PHYS_None )
		LieStill();
}

function Landed(vector HitNormal)
{
	if ( AnimSequence == 'Fall' )
	{
		LieStill();
		PlayAnim('Dead2B', 0.7, 0.07);
	}
	SetPhysics(PHYS_None);
}

state Dead 
{
	function BeginState()
	{
	}
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealI.WarlordWing'
     bodyparts(1)=LodMesh'UnrealI.WarlordHead'
     bodyparts(2)=LodMesh'UnrealI.WarlordLeg'
     bodyparts(3)=LodMesh'UnrealI.WarlordArm'
     bodyparts(4)=LodMesh'UnrealI.WarlordLeg'
     bodyparts(5)=LodMesh'UnrealI.WarlordGun'
     bodyparts(6)=LodMesh'UnrealI.WarlordFoot'
     bodyparts(7)=LodMesh'UnrealI.WarlordHand'
     ZOffset(1)=0.500000
     ZOffset(2)=-0.500000
     ZOffset(4)=-0.500000
     ZOffset(6)=-0.700000
     LifeSpan=0.000000
}
