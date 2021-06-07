# Overview
This is a utility mod for [Himeko Sutori](https://himekosutori.com/). It's only purpose is to swap out the game's base PlayerController class with an identical one that is observable. The observable PlayerController acts like the original except it notifies a list of EventListeners when certain game events occur. 

# How does this work?
Events Mod is meant for other mods to leverage. When creating a new mod, create a subclass of EventListener and override the callback functions you wish to observe and act on.

The EventListener class currently has the following callback functions available:

```UnrealScript
function OnInitialization(EventManager Manager) {}
function OnPawnsInitialized(Array<RPGTacPawn> Pawns) {}
function OnEquipmentInventoryInitialized(Array<EquipmentInventory> EquimentInventory) {}
function OnEquipmentInventoryItemUpdate(EquipmentInventory InventoryItem) {}
function OnShopInventoryItemUpdate(RPGTacEquipment EquipmentType) {}
function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) {}
function OnEnterWorldMap() {}
function OnEnterArea() {}
function OnBattleStart() {}
function OnBattleVictory(bool PawnsCelebrate) {}
function OnStartResting(int HoursToRest) {}
```
For example, here is a simple listener that outputs a message to the console whenever a pawn levels up:

```UnrealScript
class LevelUpListener extends EventListener;

function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) 
{
  `log(RPGTacPawn.CharacterName $ " just levelled up!");
}
```

# How does I get my mod to load?
You'll need to also create a mutator to take advantage of the game's mutator loader. Create a subclass of EventMutator and use the OnEventManagerCreated() function to register your custom EventListener to the EventManager. Here is an example of what that would look like:

```UnrealScript
class MyCustomMutator extends EventMutator;

function OnEventManagerCreated(EventManager Manager)
{
  Manager.AddListener(new class'LevelUpListener');
}
```

Then you need to add it to your RPGTacMods.ini file like so:
```
[rpgtacgame.RPGTacMutatorLoader]
MutatorsLoaded=MyCustomMod.MyCustomMutator
```

For a fuller example, check out the [More Classes Mod](https://github.com/solimodsthings/MoreClassesMod).

