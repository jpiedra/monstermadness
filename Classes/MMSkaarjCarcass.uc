//=============================================================================
// SkaarjCarcass.
//=============================================================================
class MMSkaarjCarcass extends MMCreatureCarcass;









































function ForceMeshToExist()
{
	//never called
	Spawn(class 'Skaarjwarrior');
}

static simulated function bool AllowChunk(int N, name A)
{
	if ( (A == 'Death5') && (N == 7) )
		return false;

	return true;
}

function CreateReplacement()
{
	local CreatureChunks carc;
	
	if (bHidden)
		return;
	carc = Spawn(class'SkaarjMasterChunk'); 
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
     bodyparts(0)=LodMesh'UnrealShare.SkaarjTail'
     bodyparts(1)=LodMesh'UnrealShare.SkaarjBody'
     bodyparts(2)=LodMesh'UnrealShare.SkaarjHand'
     bodyparts(3)=LodMesh'UnrealShare.SkaarjBody'
     bodyparts(4)=LodMesh'UnrealShare.SkaarjLeg'
     bodyparts(5)=LodMesh'UnrealShare.SkaarjLeg'
     bodyparts(6)=LodMesh'UnrealShare.CowBody1'
     bodyparts(7)=LodMesh'UnrealShare.SkaarjHead'
     ZOffset(1)=0.000000
     ZOffset(3)=0.300000
     ZOffset(4)=-0.500000
     ZOffset(5)=-0.500000
     AnimSequence=Death
     Mesh=LodMesh'UnrealShare.Skaarjw'
     CollisionRadius=35.000000
     CollisionHeight=46.000000
     Mass=150.000000
     Buoyancy=140.000000
}
