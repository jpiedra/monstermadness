// ============================================================
// MonsterMadness.MonsterList: Maintains a list of Unreal SP
//        monsters, used by MonsterMadness.MonsterMadness.
//
// (C) 2000 by MeltDown - meltdown@thirdtower.com
//
// You may NOT modify this code without written permission from
// the author. You are free to use and distribute this code,
// as long as there is no money charged for it.
// ============================================================

class MonsterList expands Actor config(MonsterMadness);

var MonsterList NextMonster;
var MonsterList PrevMonster;
var ScriptedPawn Monster;
var bool bDelayedSpawning;
var PlayerReplicationInfo MonsterPRI;

var() config int MonsterSkill;

replication {
	reliable if(Role == ROLE_Authority) NextMonster, Monster, MonsterPRI;
}

function ScriptedPawn AddMonster(string MonsterClass) {
	local MonsterList LastMonster;
	local MonsterList NewMonster;
	local MMRadarHUD hud;
	
	NewMonster=CreateNewMonster(MonsterClass);
	if(NewMonster==None) return None;
  
	if(NewMonster!=self) {
		if(NextMonster!=None) {
			for(LastMonster=self; LastMonster.NextMonster!=None;LastMonster=LastMonster.NextMonster);
		} else {
			LastMonster=Self;
		}

		LastMonster.NextMonster=NewMonster;
		NewMonster.PrevMonster=LastMonster;
		NewMonster.NextMonster=None;
	}

	return NewMonster.Monster;
}

// Tries to spawn a new monster using SpawnTheMonster(...)
// If it fails, it spawns a DelayedSpawner.
function MonsterList CreateNewMonster(string MonsterClass) {
	local MonsterList NewItem;
	local DelayedSpawner Spawner;
	local class<ScriptedPawn> MClass;

	if(PrevMonster==None && NextMonster==None && Monster==None && !bDelayedSpawning) {
		NewItem=self;
	} else {
		NewItem=spawn(class'MonsterList');
		if(NewItem==None) {
			Log("Unable to spawn new MonsterList item",Class.Name);
			BroadcastMessage("MonsterMadness: Unable to spawn new MonsterList item");
			return None;
		}
	}

	NewItem.Monster=NewItem.SpawnTheMonster(MonsterClass);
	if(NewItem.Monster==None) {
		Spawner=Spawn(class'DelayedSpawner');
		if(Spawner==None) {
			Log("Failed to spawn a DelayedSpawner!",Class.Name);
			BroadcastMessage("Failed to spawn a DelayedSpawner!");
			return None;
		}

		MClass=class<ScriptedPawn>(DynamicLoadObject(MonsterClass,class'Class'));
		if(MClass==None) {
			Log("Unable to set Spawner.MonsterType ("$MonsterClass$")!",Class.Name);
			BroadcastMessage("Unable to set Spawner.MonsterType ("$MonsterClass$")!");
			return None;
		}

		Spawner.MonsterType=MClass;
		Spawner.MonsterItem=NewItem;
		Spawner.Go(1.0);
	}

	return NewItem;
}


// Spawn a monster with a given class
// Also sets initial health, state, and other properties
function ScriptedPawn SpawnTheMonster(string MonsterClassString) {
	local ScriptedPawn NewMonster;
	local vector StartingLocation;
	local class<ScriptedPawn> MonsterClass;

	// Refuses spawning a monster when the game hasn't started yet.
	// MOVED TO: monstermadness.monstermadness
	/*
	if(!begunPlay()) {
		broadcastMessage("Not spawning monster "$MonsterClassString$" when game hasn't started yet");
		return none;
	}
	*/

	StartingLocation=GetStartingLocation();

	MonsterClass=class<ScriptedPawn>(DynamicLoadObject(MonsterClassString,class'Class'));
	if(MonsterClass==None) {
		Log("Unable to spawn None ("$MonsterClassString$")!",Class.Name);
		return None;
	}

	NewMonster=Spawn(MonsterClass,self,,StartingLocation);
	if(NewMonster==None) return None;

	Spawn(class'UTTeleEffect', self, , StartingLocation);

	MMScriptedPawn(NewMonster).monsterListItem = self;
	NewMonster.Health = NewMonster.default.Health * class'MonsterMadness'.default.HealthMultiplier;
	NewMonster.bHunting=true;
	NewMonster.bHateWhenTriggered=true;
	NewMonster.Skill=MonsterSkill;
	NewMonster.Intelligence=BRAINS_Human;
	NewMonster.bIsPlayer=true; // Otherwise BaseMutator.ScoreKill() won't be called!
	NewMonster.SetEnemy(GetRandomPlayer());
	NewMonster.GotoState('Attacking');
	NewMonster.Trigger(NewMonster.Enemy, newMonster.Enemy);
	//NewMonster.MoveToward(NewMonster.Enemy);

	return NewMonster;
}

// Starting location based on team number
// FIXME: A free navigation point close to the PlayerStart
// points belonging to the team should be picked if there
// are no suitable PlayerStarts.
function vector getTeamStartingLocation(int teamNr, out int found) {
	local NavigationPoint N;
	local NavigationPoint Candidate[16];
	local int num;
	local PlayerStart ps;

	for (N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint) {
		if(N!=None && !N.Region.Zone.bWaterZone && N.IsA('PlayerStart')) {
			ps = PlayerStart(N);
			if(ps.TeamNumber == teamNr) {
				if (num<16) Candidate[num] = N;
				else if (Rand(num) < 16) Candidate[Rand(16)] = N;
				num++;
			}
		}
	}

	found = num;

	return Candidate[Rand(Min(16,num))].Location;
}
 
// Random navigation point as starting location.
// When in a team game, it uses getTeamStartingLocation(...)
// first. If that one can't find a suitible starting location,
// a random navigation point is picked anyway.
function vector GetStartingLocation() {
	local NavigationPoint N;
	local NavigationPoint Candidate[16];
	local int num, found;
	local vector vec;
	
	if(Level.Game.bTeamGame) {
	  	vec = getTeamStartingLocation(0, found);
		if(found>0) return vec;
	}
	
	for (N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint) {
		if(N!=None && !N.Region.Zone.bWaterZone) {
			if (num<16) Candidate[num] = N;
			else if (Rand(num) < 16) Candidate[Rand(16)] = N;
			num++;
		}
	}

	return Candidate[Rand(Min(16,num))].Location;
}

function Pawn GetRandomPlayer() {
  local Pawn N;
  local PlayerPawn Dest;
  local Pawn Candidate[16];
  local int num;

  for (N=Level.PawnList; N!=None; N=N.NextPawn) {
    if (N!=None && N.bIsPlayer && 
	N.PlayerReplicationInfo!=None && !N.PlayerReplicationInfo.bIsSpectator) {
      if (num<16) Candidate[num] = N;
      else if (Rand(num) < 16) Candidate[Rand(16)] = N;
      num++;
    }
  }

  if(num==0) return None;
  return Candidate[Rand(Min(16,num))];
}

function MonsterList FindMonster(ScriptedPawn Needle) {
  local MonsterList FoundMonster;

  if(Needle==None) {
    Log("FindMonster: Trying to find None!", Class.Name);
    return None;
  }

  if(PrevMonster!=None) {
    Log("FindMonster: Search not started at first item",Class.Name);
    return PrevMonster.FindMonster(Needle);
  }

  for(FoundMonster=self; FoundMonster!=None; FoundMonster=FoundMonster.NextMonster)
    if(Needle==FoundMonster.Monster) return FoundMonster;

  return None;
}

function bool MonstersAlive() {
  local MonsterList FoundMonster;

  for(FoundMonster=self; FoundMonster!=None; FoundMonster=FoundMonster.NextMonster)
    if(FoundMonster.Monster!=None && FoundMonster.Monster.Health>0) return true;

  return false;
}

defaultproperties
{
     bHidden=True
}
