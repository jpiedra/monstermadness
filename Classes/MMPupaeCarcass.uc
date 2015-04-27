//=============================================================================
// PupaeCarcass.
//=============================================================================
class MMPupaeCarcass extends MMCreatureCarcass;











































static simulated function bool AllowChunk(int N, name A)
{
	if ( (A == 'Dead2') && (N == 4) )
		return false;
	if ( (A == 'Dead3') && (N == 3) )
		return false;

	return true;
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealI.PupaeBody'
     bodyparts(1)=LodMesh'UnrealI.PupaeLeg3'
     bodyparts(2)=LodMesh'UnrealI.PupaeLeg1'
     bodyparts(3)=LodMesh'UnrealI.PupaeLeg2'
     bodyparts(4)=LodMesh'UnrealI.PupaeHead'
     bodyparts(5)=None
     ZOffset(0)=0.000000
     ZOffset(1)=0.000000
     LandedSound=Sound'UnrealI.Pupae.thumppp'
     Mesh=LodMesh'UnrealI.Pupae1'
     CollisionRadius=28.000000
     CollisionHeight=9.000000
     Mass=80.000000
}
