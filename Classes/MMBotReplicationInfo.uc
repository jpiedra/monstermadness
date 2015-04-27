// ===============================================================
// MonsterMadness.MMPlayerReplicationInfo: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class MMBotReplicationInfo expands BotReplicationInfo;

var bool bIsMonster;
var PlayerPawn ownerPawn;


replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
		bIsMonster, ownerPawn;
}


function PostBeginPlay() {
	if(Owner.IsA('MMScriptedPawn')) bIsMonster = true;
	if(PlayerName == "" && bIsMonster) {
		PlayerName = Owner.GetHumanName();
	}
	ownerPawn = PlayerPawn(Owner);
	Super.PostBeginPlay();
}

defaultproperties
{
}
