//=============================================================================
// TitanCarcass.
//=============================================================================
class MMTitanCarcass extends MMCreatureCarcass;

















function ForceMeshToExist()
{
	//never called
	Spawn(class 'Titan');
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.BigChunk1'
     bodyparts(1)=LodMesh'UnrealShare.BigChunk1'
     bodyparts(2)=LodMesh'UnrealShare.bigchunk2'
     bodyparts(3)=LodMesh'UnrealShare.bigchunk2'
     bodyparts(4)=LodMesh'UnrealShare.BigChunk1'
     bodyparts(5)=LodMesh'UnrealShare.bigchunk2'
     bodyparts(6)=LodMesh'UnrealShare.BigChunk1'
     bodyparts(7)=LodMesh'UnrealShare.bigchunk2'
     ZOffset(0)=0.600000
     ZOffset(1)=0.500000
     ZOffset(3)=0.200000
     ZOffset(4)=-0.200000
     ZOffset(5)=-0.500000
     bPermanent=True
     AnimSequence=TDeat001
     Mesh=LodMesh'UnrealI.Titan1'
     CollisionRadius=115.000000
     CollisionHeight=110.000000
     Mass=2000.000000
}
