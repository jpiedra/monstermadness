//=============================================================================
// MercCarcass.
//=============================================================================
class MMMercCarcass extends MMCreatureCarcass;



















































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Mercenary');
}

static simulated function bool AllowChunk(int N, name A)
{
	if ( (A == 'Dead5') && (N == 5) )
		return false;

	return true;
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealI.MercLeg'
     bodyparts(1)=LodMesh'UnrealI.MercPart'
     bodyparts(2)=LodMesh'UnrealI.MercGun'
     bodyparts(3)=LodMesh'UnrealI.MercPart'
     bodyparts(4)=LodMesh'UnrealI.MercLeg'
     bodyparts(5)=LodMesh'UnrealI.MercHead'
     ZOffset(1)=0.000000
     ZOffset(4)=-0.500000
     ZOffset(5)=-0.500000
     bGreenBlood=True
     LandedSound=Sound'UnrealI.Mercenary.thumpmr'
     AnimSequence=Death
     Mesh=LodMesh'UnrealI.Merc'
     CollisionRadius=35.000000
     CollisionHeight=48.000000
     Mass=150.000000
     Buoyancy=140.000000
}
