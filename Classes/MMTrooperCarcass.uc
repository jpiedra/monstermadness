//=============================================================================
// TrooperCarcass.
//=============================================================================
class MMTrooperCarcass extends MMCreatureCarcass;

























function ForceMeshToExist()
{
	//never called
	Spawn(class 'SkaarjTrooper');
}

function CreateReplacement()
{
	local CreatureChunks carc;
	
	if (bHidden)
		return;
	carc = Spawn(class'TrooperMasterChunk'); 
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
     bodyparts(0)=LodMesh'UnrealShare.SkaarjBody'
     bodyparts(1)=LodMesh'UnrealShare.SkaarjHead'
     bodyparts(2)=LodMesh'UnrealShare.SkaarjBody'
     bodyparts(3)=LodMesh'UnrealShare.SkaarjLeg'
     bodyparts(4)=LodMesh'UnrealShare.SkaarjLeg'
     bodyparts(5)=LodMesh'UnrealShare.CowBody1'
     bodyparts(6)=LodMesh'UnrealShare.CowBody2'
     AnimSequence=Death
     Mesh=LodMesh'UnrealI.sktrooper'
     CollisionRadius=32.000000
     CollisionHeight=42.000000
     Mass=130.000000
}
