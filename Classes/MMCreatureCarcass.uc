//=============================================================================
// MMCreatureCarcass.
//=============================================================================
class MMCreatureCarcass extends CreatureCarcass config(MonsterMadness);

var() bool bSolidCarcasses;

function PostBeginPlay() {
	Super.PostBeginPlay();
	if(bSolidCarcasses && Physics == PHYS_None)
		setPhysics(PHYS_Falling);
}

function Destroyed() {
	if ( !bDecorative )
		DeathZone.NumCarcasses--;
	Super.Destroyed();
}

function Landed(vector HitNormal) {
	super.Landed(HitNormal);
	if(bSolidCarcasses) setCollision(true, true, true);
}

function ReduceCylinder() {
	super.ReduceCylinder();
	if(bSolidCarcasses) setCollision(true, true, true);
}
	

defaultproperties
{
     flies=20
}
