//=============================================================================
// NaliCarcass.
//=============================================================================
class MMNaliCarcass extends MMCreatureCarcass;



















































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Nali');
}

static simulated function bool AllowChunk(int N, name A)
{
	if ( (A == 'Dead3') && (N == 6) )
		return false;

	return true;
}

function CreateReplacement()
{
	local CreatureChunks carc;
	
	if (bHidden)
		return;
	carc = Spawn(class'NaliMasterChunk'); 
	if (carc != None)
	{
		carc.bMasterChunk = true;
		carc.Initfor(self);
		carc.Bugs = Bugs;
		if ( Bugs != None )
			Bugs.SetBase(carc);
		Bugs = None;
	}
	else if ( Bugs != None )
		Bugs.Destroy();
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.NaliPart'
     bodyparts(1)=LodMesh'UnrealShare.NaliLeg'
     bodyparts(2)=LodMesh'UnrealShare.NaliPart'
     bodyparts(3)=LodMesh'UnrealShare.NaliFoot'
     bodyparts(4)=LodMesh'UnrealShare.NaliHand1'
     bodyparts(5)=LodMesh'UnrealShare.NaliHand2'
     bodyparts(6)=LodMesh'UnrealShare.NaliHead'
     ZOffset(0)=0.000000
     ZOffset(3)=-0.500000
     ZOffset(6)=0.500000
     LandedSound=Sound'UnrealShare.Nali.thumpn'
     Mesh=LodMesh'UnrealShare.Nali1'
     CollisionRadius=24.000000
     CollisionHeight=48.000000
     Mass=100.000000
     Buoyancy=96.000000
}
