//=============================================================================
// KrallCarcass.
//=============================================================================
class MMKrallCarcass extends MMCreatureCarcass;










































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Krall');
}

static simulated function bool AllowChunk(int N, name A)
{
	if ( (A == 'Dead5') && (N == 4) )
		return false;
	if ( (A == 'LeglessDeath') && (N == 2) )
		return false;

	return true;
}

function InitFor(actor Other)
{
	Super.InitFor(Other);
	if ( AnimSequence == 'LeglessDeath' )
		SetCollision(true, false, false);
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealI.KrallWeapon'
     bodyparts(1)=LodMesh'UnrealI.KrallHand'
     bodyparts(2)=LodMesh'UnrealI.KrallFoot'
     bodyparts(3)=LodMesh'UnrealI.KrallPiece'
     bodyparts(4)=LodMesh'UnrealI.KrallHead'
     Mesh=LodMesh'UnrealI.KrallM'
     Mass=140.000000
     Buoyancy=130.000000
}
