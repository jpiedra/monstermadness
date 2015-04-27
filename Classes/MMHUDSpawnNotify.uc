// ===============================================================
// MonsterMadness.MMHUDSpawnNotify: Part of the MonsterMadness mod
// Created by MeltDown - (C) 2000-2002 by meltdown@unrealtower.org
// ===============================================================

class MMHUDSpawnNotify expands SpawnNotify;

simulated event PreBeginPlay() {
	Log("I'm spawned, and in PreBeginPlay", Class.Name);
	Super.PreBeginPlay();
}

simulated function SpawnNewHUD(Actor A) {
	local MMRadarHUD NewHUDMut;
	local PlayerPawn P;

	P                        = PlayerPawn(A.Owner);
	NewHUDMut                = spawn(class'MonsterMadness.MMRadarHUD',P);
	NewHUDMut.Player         = P;
	NewHUDMut.NextHUDMutator = HUD(A).HUDMutator;
	HUD(A).HUDMutator        = NewHUDMut;
	NewHUDMut.bHudMutator    = true;

	Log("Found a HUD owned by "$P.GetHumanName()$", gave him/her "$NewHUDMut, Class.Name);

	if(Level.Game!=None) {
		Level.Game.BaseMutator.AddMutator(NewHUDMut);
	} else {
		Log("Not adding a mutator on the client-side",Class.Name);
	}
}

simulated event Actor SpawnNotification( Actor A ) {
	if(A.IsA('HUD') && !A.IsA('MMRadarHUD')) SpawnNewHUD(A);
	return A;
}

defaultproperties
{
}
