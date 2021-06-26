![](https://i.imgur.com/s1qm4Ak.png)

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
function OnPawnDefeated(RPGTacPawn DefeatedPawn, bool IsAlly) {}
function OnEnterWorldMap() {}
function OnEnterArea() {}
function OnBattleStart() {}
function OnBattleVictory(bool PawnsCelebrate) {}
function OnStartResting(int HoursToRest) {}
function OnCauseEvent(optional Name event){}
function JSonObject Serialize() {return none;}
function Deserialize(JSonObject ListenerData) {}
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
You'll need to also create a [mutator](https://docs.unrealengine.com/udk/Three/UT3Mods.html#Mutators) to take advantage of the game's mutator loader. Create a subclass of EventMutator and use the OnEventManagerCreated() function to register your custom EventListener to the EventManager. Here is an example of what that would look like:

```UnrealScript
class MyCustomMutator extends EventMutator;

function OnEventManagerCreated(EventManager Manager)
{
  Manager.AddListener(new class'LevelUpListener');
}
```

You then need to add the Events Mod's mutator and your own mutator to your RPGTacMods.ini file like so:
```
[rpgtacgame.RPGTacMutatorLoader]
MutatorsLoaded=EventsMod.EventsModStart,MyCustomMod.MyCustomMutator
```
Events Mod needs to be first in the list so it is loaded first. Also, there can be no spaces between items in the list as whitespaces are not trimmed.

For a fuller example, check out the [More Classes Mod](https://github.com/solimodsthings/MoreClassesMod).

