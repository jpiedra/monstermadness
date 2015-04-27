//=============================================================================
// GassiusCarcass.
//=============================================================================
class MMGassiusCarcass extends MMCreatureCarcass;










































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Gasbag');
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealI.GasHead'
     bodyparts(1)=LodMesh'UnrealI.GasArm1'
     bodyparts(2)=LodMesh'UnrealI.GasArm2'
     bodyparts(3)=LodMesh'UnrealI.GasHand'
     bodyparts(4)=LodMesh'UnrealI.GasPart'
     bodyparts(5)=LodMesh'UnrealI.GasPart'
     ZOffset(0)=0.700000
     ZOffset(1)=0.000000
     ZOffset(2)=0.350000
     ZOffset(3)=-0.300000
     ZOffset(4)=-0.500000
     ZOffset(5)=-0.700000
     AnimSequence=Deflate
     Mesh=LodMesh'UnrealI.GasBagM'
     Mass=120.000000
}
