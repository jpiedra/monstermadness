// ============================================================
// MonsterMadness.MonsterMadnessMenuItem
//
// This class is part of the Monster Madness mutator
// Created by MeltDown - meltdown@thirdtower.com
// For the latest version, go to:
// http://www.planetunreal.com/unrealtower
// ============================================================

class MonsterMadnessMenuItem expands UMenuModMenuItem;

function Execute() {
  MenuItem.Owner.Root.CreateWindow(class'MonsterMadnessConfigWindow', 10, 10, 150, 100);
}

defaultproperties
{
     MenuCaption="Monster Madness 3..."
     MenuHelp="Configure Monster Madness!"
}
