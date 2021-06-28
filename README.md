![](https://i.imgur.com/s1qm4Ak.png)

# Overview
This is a utility mod for [Himeko Sutori](https://himekosutori.com/) that makes it much easier to build other mods. It operates like a standard [mutator](https://docs.unrealengine.com/udk/Three/UT3Mods.html#Mutators) and is loaded through the game's own [mutator loader](https://store.steampowered.com/news/app/669500/view/3043849366300043709).

Events Mod functions by swapping out the game's base PlayerController class with an identical one called EventManager that supports EventListeners. EventManager basically acts like the base PlayerController except it notifies EventListeners when certain game events occur. This makes it easier to build mods with less code.

# How does this work?
When creating a new mod, first create a subclass of EventListener and override the functions you wish to observe and act on. You only need to override the ones you need.

The EventListener class currently has the following callback functions available:
| Function | Description |
|:--|:--|
| ```OnInitialization()``` | Called once an instance of a PlayerController in the game is created |
| ```OnPawnsInitialized(Array<RPGTacPawn> Pawns)``` | Called once it is "safe" to parse through all pawns in the game |
| ```OnEquipmentInventoryInitialized(Array<EquipmentInventory> EquimentInventory)``` | Called once it is "safe" to parse through inventory |
| ```OnEquipmentInventoryItemUpdate(EquipmentInventory InventoryItem)``` | Called whenever an item is added to the player inventory |
| ```OnShopInventoryItemUpdate(RPGTacEquipment EquipmentType)``` | Called whenever a shop inventory is refreshe |
| ```OnPawnLevelUp(RPGTacPawn LevelledUpPawn)``` | Called when a character levels up |
| ```OnPawnDefeated(RPGTacPawn DefeatedPawn, bool IsAlly)``` | Called after any pawn is defeated in combat. This will also be called when enemies are defeated so remember to check the IsAlly flag. This function never gets called if permadeaths are disabled by player. |
| ```OnEnterWorldMap()``` | Called whenever the player enters the world map |
| ```OnEnterArea()``` | Called whenever the player enters an area that is not the world map |
| ```OnBattleStart()``` | Called when a battle begins |
| ```OnBattleVictory(bool PawnsCelebrate)``` | Called when a battle ends and you won |
| ```OnStartResting(int HoursToRest)``` | Called when the player starts resting on the world map |
| ```OnCauseEvent(optional Name event)```| This is primarily used to detect when kismet events are triggered |
| ```JSonObject Serialize()``` | Called when the game is creating a save file to write to disk |
| ```Deserialize(JSonObject ListenerData)``` | Called when the game is loading a save file from disk and information previously serialized by this listener neds to be deserialized |

For example, here is a simple listener that outputs a message to the console whenever a pawn levels up:

```UnrealScript
class LevelUpListener extends EventListener;

function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) 
{
  `log(RPGTacPawn.CharacterName $ " just levelled up!");
}
```

# How do I get my mod to load?
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

