// ============================================================
// MonsterMadness.DelayedSpawner: Tries to spawn a new Unreal SP
//        monster every X seconds. Destroys itself after a
//        successful spawn
//
// (C) 2000 by MeltDown - meltdown@thirdtower.com
//
// You may NOT modify this code without written permission from
// the author. You are free to use and distribute this code,
// as long as there is no money charged for it.
// ============================================================

class DelayedSpawner expands Actor;

var() int MaxTimesRetriggered;

var class<Actor> MonsterType;
var MonsterList MonsterItem;
var float RetriggerTime;
var int TimesRetriggered;

function Go(float TimeOut) {
  MonsterItem.bDelayedSpawning = true;
  RetriggerTime    = TimeOut;
  TimesRetriggered = 0;
  SetTimer(1.0, false);
}

event Timer() {
	local MMScriptedPawn NewMonster;

	// Don't try to spawn monsters when the game hasn't started yet.
	if(!Level.bBegunPlay) {
		SetTimer(RetriggerTime, false);
		return;
	}

	NewMonster = MMScriptedPawn(MonsterItem.SpawnTheMonster(string(MonsterType)));
	if(NewMonster == None) {
		if(MaxTimesRetriggered==0 || TimesRetriggered<MaxTimesRetriggered) {
			// Try to spawn later
			TimesRetriggered++;
			SetTimer(RetriggerTime, false);
		} else {
			// Give up respawning
			Log("Tried to respawn a"@string(MonsterType)@MaxTimesRetriggered@"times. Giving up.",Class.Name);
			BroadcastMessage("Tried to respawn a"@string(MonsterType)@MaxTimesRetriggered@"times. Giving up.");
			MonsterItem.bDelayedSpawning=false;
			MonsterItem.Monster = none;
			Destroy();
		}
		return;
	}

	//Log("Timer(): Setting NewMonster.monsterListItem to MonsterItem", Class.Name);
	//NewMonster.monsterListItem = MonsterItem;
	MonsterItem.Monster = NewMonster;
	MonsterItem.bDelayedSpawning = false;

	Destroy();
}

defaultproperties
{
     MaxTimesRetriggered=50
     bHidden=True
}
