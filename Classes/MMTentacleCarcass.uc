//=============================================================================
// TentacleCarcass.
//=============================================================================
class MMTentacleCarcass extends MMCreatureCarcass;

































function Drop(vector newVel)
{
	//implemented in TentacleCarcass
	Velocity.X = 0;
	Velocity.Y = 0;
	SetPhysics(PHYS_Falling);
}


function Landed(vector HitNormal)
{
	if ( AnimSequence == 'Dead1')
		PlayAnim('Dead1Land', 1.5);
	SetPhysics(PHYS_None);
	LieStill();
}

defaultproperties
{
     bodyparts(0)=LodMesh'UnrealShare.TentBody'
     bodyparts(1)=LodMesh'UnrealShare.TentPart'
     bodyparts(2)=LodMesh'UnrealShare.TentPart'
     bodyparts(3)=LodMesh'UnrealShare.TentArm'
     bodyparts(4)=LodMesh'UnrealShare.TentArm'
     bodyparts(5)=LodMesh'UnrealShare.TentHead'
     bodyparts(6)=LodMesh'UnrealShare.TentArm'
     AnimSequence=Dead1Land
     Mesh=LodMesh'UnrealShare.Tentacle1'
     CollisionRadius=28.000000
     CollisionHeight=36.000000
     Mass=200.000000
     Buoyancy=190.000000
}
