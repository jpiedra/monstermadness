//=============================================================================
// SlithCarcass.
//=============================================================================
class MMSlithCarcass extends MMCreatureCarcass;









































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Slith');
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.SlithPart'
     bodyparts(1)=LodMesh'UnrealShare.SlithPart'
     bodyparts(2)=LodMesh'UnrealShare.SlithHand'
     bodyparts(3)=LodMesh'UnrealShare.SlithHead'
     bodyparts(4)=LodMesh'UnrealShare.SlithArm'
     bodyparts(5)=LodMesh'UnrealShare.SlithArm'
     bodyparts(6)=LodMesh'UnrealShare.CowBody1'
     bodyparts(7)=LodMesh'UnrealShare.SlithTail'
     ZOffset(0)=0.000000
     ZOffset(1)=0.000000
     AnimSequence=Dead1
     Mesh=LodMesh'UnrealShare.Slith1'
     CollisionRadius=48.000000
     CollisionHeight=44.000000
     Mass=200.000000
     Buoyancy=190.000000
}
