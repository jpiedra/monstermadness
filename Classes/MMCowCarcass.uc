//=============================================================================
// CowCarcass.
//=============================================================================
class MMCowCarcass extends MMCreatureCarcass;



































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Cow');
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.CowHead'
     bodyparts(1)=LodMesh'UnrealShare.CowBody2'
     bodyparts(2)=LodMesh'UnrealShare.CowBody1'
     bodyparts(3)=LodMesh'UnrealShare.CowLeg'
     bodyparts(4)=LodMesh'UnrealShare.CowTail'
     bodyparts(5)=LodMesh'UnrealShare.CowFoot'
     LandedSound=Sound'UnrealShare.Cow.thumpC'
     Mesh=LodMesh'UnrealShare.NaliCow'
     CollisionRadius=48.000000
     CollisionHeight=32.000000
     Mass=120.000000
}
