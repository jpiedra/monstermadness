//=============================================================================
// BruteCarcass.
//=============================================================================
class MMBruteCarcass extends MMCreatureCarcass;

function ForceMeshToExist()
{
	//never called
	Spawn(class 'Brute');
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.BruteHead'
     bodyparts(1)=LodMesh'UnrealShare.BruteFoot'
     bodyparts(2)=LodMesh'UnrealShare.BruteHand'
     bodyparts(3)=LodMesh'UnrealShare.BigChunk1'
     bodyparts(4)=LodMesh'UnrealShare.BrutePiece'
     bodyparts(5)=LodMesh'UnrealShare.BrutePiece'
     bodyparts(6)=LodMesh'UnrealShare.BruteHand'
     bodyparts(7)=LodMesh'UnrealShare.bigchunk2'
     ZOffset(0)=0.600000
     ZOffset(1)=0.500000
     ZOffset(3)=0.200000
     ZOffset(4)=-0.200000
     ZOffset(5)=-0.500000
     AnimSequence=Dead1
     Mesh=LodMesh'UnrealShare.Brute1'
     CollisionRadius=52.000000
     CollisionHeight=52.000000
     Mass=400.000000
     Buoyancy=390.000000
}
