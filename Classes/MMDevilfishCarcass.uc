//=============================================================================
// DevilfishCarcass.
//=============================================================================
class MMDevilfishCarcass extends MMCreatureCarcass;

























function ForceMeshToExist()
{
	//never called
	Spawn(class 'DevilFish');
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.FishHead'
     bodyparts(1)=LodMesh'UnrealShare.FishPart'
     bodyparts(2)=LodMesh'UnrealShare.FishPart'
     bodyparts(3)=LodMesh'UnrealShare.FishTail'
     bodyparts(4)=None
     Mesh=LodMesh'UnrealShare.fish'
     CollisionRadius=22.000000
     CollisionHeight=10.000000
     Buoyancy=0.000000
}
