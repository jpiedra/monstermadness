// ============================================================
// MonsterMadness.MMGiantGasbag: put your comment here
//
// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class MMGiantGasbag expands MMGasbag;

function SpawnBelch() {
  local Gasbag G;
  local vector X,Y,Z, projStart;
  local actor P;
	 
  GetAxes(Rotation,X,Y,Z);
  projStart = Location + 0.5 * CollisionRadius * X - 0.3 * CollisionHeight * Z;
  P = spawn(RangedProjectile ,self,'',projStart,
	    AdjustAim(ProjectileSpeed, projStart, 400, bLeadTarget, bWarnTarget));
  if ( P != None )
    P.DrawScale *= 2;
}

defaultproperties
{
}
