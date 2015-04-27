// ===============================================================
// MonsterMadness.MMRadarHUD: Part of the MonsterMadness mod
// Created by MeltDown - (C) 2000-2002 by meltdown@unrealtower.org
// ===============================================================

class MMRadarHUD expands Mutator config(MonsterMadness);

#exec Texture Import File=Textures\MMRadar.pcx Name=T_MMRadar Mips=Off Flags=2
#exec Texture Import File=Textures\RadarBlip.pcx Name=T_RadarBlip Mips=Off Flags=2
#exec Texture Import File=Textures\RadarIcon.pcx Name=T_RadarIcon GROUP="Icons" MIPS=OFF

var PlayerPawn Player;				// The owner of the HUD

var() config int scale;
var texture tex;
var bool bActive;
var bool bDebug;					// If true, shows monster info
var GameReplicationInfo GRI;

var() config enum ES_Position {		// Position of the window
	RADAR_TopLeft,
	RADAR_TopMiddle,
	RADAR_TopRight,
	RADAR_MiddleLeft,
	RADAR_MiddleRight,
	RADAR_BottomLeft,
	RADAR_BottomMiddle,
	RADAR_BottomRight
} Position;


replication {
	reliable if (Role==Role_Authority) Player, scale, bActive;
}


function postBeginPlay() {
	Log("I'm spawned for "$Owner.GetHumanName(), Class.Name);
	super.postBeginPlay();
	bActive = true;
}

simulated function bool getGRI() {
	if(GRI == None) {
		foreach AllActors(class'GameReplicationInfo', GRI) break;
	}
	return (GRI != None);
}

// Returns 'true' if the game has actually started.
// The radar won't be shown if this returns false.
simulated function bool begunPlay() {
	local int timeLimit;
	local int timeRemaining;
	
	if(!getGRI()) {
		//Log("Unable to find GRI", Class.Name);
		return true;
	}
	
	if(GRI.IsA('TournamentGameReplicationInfo')) {
		timeLimit     = TournamentGameReplicationInfo(GRI).TimeLimit * 60;
		timeRemaining = GRI.RemainingTime;
		if(timeRemaining < timeLimit) return true;
	}

	if(GRI.ElapsedTime > 0) return true;

	return false;
}

// Called whenever a new frame is rendered
simulated function PostRender(canvas Canvas) {
	if(bActive && begunPlay()) DrawRadar(Canvas);
	if(bDebug) DrawInfo(Canvas);

	if(NextHUDMutator != None) { 
		NextHUDMutator.PostRender(Canvas);
	}
}

// This function draws the radar on the HUD
simulated function drawRadar(canvas Canvas) {
	local MonsterList monsterItem;
	local MMScriptedPawn monster;
	local int index, radius;
	local int originX, originY;

	if(!Owner.IsA('PlayerPawn')) {
		Log("My owner ("$Owner$") doesn't love me any more!", Class.Name);
		return;
	}

	Canvas.Reset();
	
	radius = Canvas.sizeY/16;

	// Calculate the position
	switch(Position) {
	case RADAR_TopLeft:
		originX = 10;
		originY = 10;
		break;
	case RADAR_TopMiddle:
		originX = Canvas.SizeX/2 - radius;
		originY = 10;
		break;
	case RADAR_TopRight:
		originX = Canvas.SizeX - radius*2 - 10;
		originY = 10;
		break;
	case RADAR_MiddleLeft:
		originX = 10;
		originY = Canvas.SizeY/2 - radius;
		break;
	case RADAR_MiddleRight:
		originX = Canvas.SizeX - radius - 10;
		originY = Canvas.SizeY/2 - radius;
		break;
	case RADAR_BottomLeft:
		originX = 10;
		originY = Canvas.SizeY - radius*2 - 10;
		break;
	case RADAR_BottomMiddle:
		originX = Canvas.SizeX/2 - radius;
		originY = Canvas.SizeY - radius*2 - 10;
		break;
	case RADAR_BottomRight:
		originX = Canvas.SizeX - radius*2 - 10;
		originY = Canvas.SizeY - radius*2 - 10;
		break;
	}


	// Set the color to red, to draw the radar
	Canvas.DrawColor.R = 128;
	Canvas.DrawColor.G = 0;
	Canvas.DrawColor.B = 0;

	// Draw the radar on the canvas
	Canvas.SetPos(originX, originY);
	Canvas.DrawTile(tex, radius*2, radius*2, 0, 0, 128, 128);

	Canvas.Font = Canvas.SmallFont;

	// Draw the text
	Canvas.setPos(originX-10, originY-10);
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
	Canvas.DrawText(scale);
	
	foreach AllActors(class'MMScriptedPawn', Monster) {
		if(!bDebug && Monster.Health <= 0) continue;
		drawBlip(Monster, Canvas, originX, originY, radius);
	}
}

simulated function drawBlip(Pawn other, canvas Canvas, int originX, int originY, int radius) {
	local rotator myRotation, monsterRotation, blipRotation;
	local int x, y, monsterDistance;
	local Vector point, myLocation, monsterLocation;
	local Weapon weapon;
	local PlayerPawn pOwner;

	if(other.Health <= 0) {
		// Set the color to green, to display phantoms on the radar
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	} else {
		// Set the color to yellow, to draw the scale
		// and the yellow blips on the canvas.
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}

	if(Owner == none) {
		Log("drawBlip(...): I don't have an owner!", Class.Name);
		return;
	}

	pOwner = PlayerPawn(Owner);
	if(pOwner == none) {
		Log("drawBlip(...): pOwner is null!", Class.Name);
		return;
	}
	
	if(Canvas == none || other == none) {
		Log("drawBlip(...): Canvas: "$Canvas$", other: "$other, Class.Name);
		return;
	}

	weapon = pOwner.Weapon;
	if(Weapon != none && Weapon.IsA('WarheadLauncher') &&
	   WarheadLauncher(Weapon).bGuiding &&
	   WarheadLauncher(Weapon).GuidedShell != none) {
		myLocation = WarheadLauncher(Weapon).GuidedShell.Location;
	} else {
		myLocation = Owner.Location;
	}
	myLocation.z = 0;

	myRotation = pOwner.ViewRotation;
	myRotation.Yaw  += 16384;
	myRotation.Pitch = 0;
	myRotation.Roll  = 0;

	monsterLocation   = other.Location;
	monsterLocation.z = 0;

	// point is the vector from the player to the monster
	point = myLocation - monsterLocation;

	monsterDistance = VSize(point);
	monsterRotation = rotator(point);
	monsterRotation.Pitch = 0;
	monsterRotation.Roll  = 0;

	blipRotation = myRotation - monsterRotation;

	point = monsterDistance * vector(blipRotation);

	if(VSize(point) < radius*scale) {
		// Translate to screen coordinates
		point.x = -point.x / scale + radius + originX;
		point.y = point.y / scale + radius + originY;

		// Draw the blip on the radar
		Canvas.SetPos(point.x, point.y);
		Canvas.DrawTile(Texture'MonsterMadness.T_RadarBlip', 1, 1, 0, 0, 1, 1);
	}
}

// Sets the scale in a safe manner
function setScale(int value) {
	if(value < 1) value = 1;
	scale = value;
}

// Use "mutate" commands to control the radar.
// Possible commands (case insensitive):
//
// mutate MMRadar Toggle
// mutate MMRadar On
// mutate MMRadar Off
// mutate MMRadar ZoomIn
// mutate MMRadar ZoomOut
function Mutate(string MutateString, PlayerPawn Sender) {
	if(MutateString~="MMRadar Toggle") {
		Sender.ClientMessage("Toggling usage of the Monster Radar");
		bActive = !bActive;
    }

	if(MutateString~="MMRadar On") {
		Sender.ClientMessage("Turning the Monster Radar on");
		Sender.ConsoleCommand("set monstermadness.mmradarhud bActive true");
		bActive = true;
    }

	if(MutateString~="MMRadar Off") {
		Sender.ClientMessage("Turning the Monster Radar off");
		Sender.ConsoleCommand("set monstermadness.mmradarhud bActive false");
		bActive = false;
    }

	if(MutateString~="MMRadar ZoomIn") {
		setScale(scale/2);
    }

	if(MutateString~="MMRadar ZoomOut") {
		setScale(scale*2);
    }

	if(MutateString ~= "MMRadar Debug") {
		if(bDebug) {
			Sender.ClientMessage("Radar is in normal mode");
			Sender.ConsoleCommand("set monstermadness.mmradarhud bdebug false");
		} else {
			Sender.ClientMessage("Radar is in debug mode");
			Sender.ConsoleCommand("set monstermadness.mmradarhud bdebug true");
		}
	}

	if(NextMutator != None)
		NextMutator.Mutate(MutateString, Sender);
}

simulated function DrawInfo(canvas Canvas) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;
	local rotator AdjustedAim;

	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation,X,Y,Z);

	StartTrace  = Owner.Location + PawnOwner.Eyeheight * Z; 
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 0, False, False);	
	X           = vector(AdjustedAim);
	EndTrace    = StartTrace + 10000 * X; 
	Other       = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

	ProcessTrace(Canvas, Other);
}

simulated function ProcessTrace(canvas Canvas, Actor Other) {
	local int originX, originY;
	local Pawn pawnOther;

	originX   = Canvas.SizeX / 2 - 100;
	originY   = Canvas.SizeY / 2 + 100;

	if(Other == none || !Other.IsA('MMScriptedPawn')) return;
	
	Canvas.Reset();

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.Font        = Canvas.smallFont;

	pawnOther = Pawn(Other);

	Canvas.setPos(originX, originY);
	Canvas.drawText("Name: " $ pawnOther.getHumanName());
	Canvas.setPos(originX, originY+10);
	Canvas.drawText("Heath: " $ pawnOther.Health);
}

defaultproperties
{
     Scale=100
     Tex=Texture'monstermadness.T_MMRadar'
     Position=RADAR_TopRight
}
