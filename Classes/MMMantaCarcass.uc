//=============================================================================
// MantaCarcass.
//=============================================================================
class MMMantaCarcass extends MMCreatureCarcass;











































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Manta');
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.MantaPart'
     bodyparts(1)=LodMesh'UnrealShare.MantaPart'
     bodyparts(2)=LodMesh'UnrealShare.MantaHead'
     bodyparts(3)=LodMesh'UnrealShare.MantaTail'
     bodyparts(4)=LodMesh'UnrealShare.MantaWing1'
     bodyparts(5)=LodMesh'UnrealShare.MantaWing2'
     ZOffset(0)=0.000000
     ZOffset(1)=0.000000
     LandedSound=Sound'UnrealShare.Manta.thumpmt'
     AnimSequence=Death
     AnimFrame=0.960000
     Mesh=LodMesh'UnrealShare.Manta1'
     CollisionRadius=27.000000
     CollisionHeight=12.000000
     Mass=80.000000
}
