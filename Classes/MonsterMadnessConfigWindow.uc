// ============================================================
// MonsterMadness.MonsterMadnessConfigWindow
//
// This class is part of the Monster Madness mutator
// Created by MeltDown - meltdown@thirdtower.com
// For the latest version, go to:
// http://www.planetunreal.com/unrealtower
// ============================================================

class MonsterMadnessConfigWindow expands UWindowFramedWindow;

function Created() {
  Super.Created();
  SetSize(500, 305);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
}

defaultproperties
{
     ClientClass=Class'monstermadness.MonsterMadnessClientWindow'
     WindowTitle="Monster Madness 3 Configuration!"
     bSizable=True
}
