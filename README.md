![](https://i.imgur.com/s1qm4Ak.png)

# Overview
This is a utility mod for [Himeko Sutori](https://himekosutori.com/) that makes it easier to build other mods. Events Mod functions by switching out the game's base PlayerController class with one that supports Event Listeners. Whenever certain game events occur, Events Mod notifies all Event Listeners. 

Events Mod functions like a normal [mutator](https://docs.unrealengine.com/udk/Three/UT3Mods.html#Mutators) and is loaded through the game's [mutator loader](https://store.steampowered.com/news/app/669500/view/3043849366300043709).

### Projects Using Events Mod
* [More Classes](https://github.com/solimodsthings/MoreClassesMod)
* [Fallen Allies](https://github.com/solimodsthings/FallenAlliesMod)
* [Passive Experience Bonus](https://github.com/solimodsthings/PassiveExperienceBonus)
* [Find Command](https://github.com/solimodsthings/FindMod)

# How does this work?
When creating a new mod, create a subclass of EventListener and override the functions you wish to act on. You only need to override the functions you want to use.

The EventListener class currently has the following callback functions available for mods:

```UnrealScript
// Called once an instance of a PlayerController in the game is created
function OnInitialization() {}

// Called once it is "safe" to parse through all pawns in the game
function OnPawnsInitialized(Array<RPGTacPawn> Pawns) {}

// Called once it is "safe" to parse through inventory
function OnEquipmentInventoryInitialized(Array<EquipmentInventory> EquimentInventory) {}

// Called whenever an item is added to the player inventory
function OnEquipmentInventoryItemUpdate(EquipmentInventory InventoryItem) {}

// Called whenever a shop inventory is refreshed (note: it is refreshed multiple times a second it seems if the shop menu is open)
function OnShopInventoryItemUpdate(RPGTacEquipment EquipmentType) {}

// Called when a character levels up. If a character levels up
// during battle, this function isn't called until you win.
function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) {}

// Called after any pawn is defeated in combat. This will also be called
// when enemies are defeated so remember to check the IsAlly flag.
// This function never gets called if permadeaths are disabled by player.
function OnPawnDefeated(RPGTacPawn DefeatedPawn, bool IsAlly) {}

// Called whenever the player enters the world map
function OnEnterWorldMap() {}

// Called whenever the player enters an area that is not the world map
function OnEnterArea() {}

// Called when a battle begins
function OnBattleStart() {}

// Called when a battle ends and you won
function OnBattleVictory(bool PawnsCelebrate) {}

// Called when the player starts resting on the world map
function OnStartResting(int HoursToRest) {}

// This is primarily used to detect when kismet events are triggered
function OnCauseEvent(optional Name event){}

// Called when the game is creating a save file to write
// to disk. If you need information stored in the save
// file, override this function and return a JsonObject
// containing data you want saved.
function JSonObject Serialize() {return none;}

// Called when the game is loading a save file from disk
// and information previously serialized by this listener
// neds to be deserialized.
function Deserialize(JSonObject ListenerData) {}

// This function is called when a player uses command
// 'tellmod' in the console to send this listener a message.
function OnReceiveMessage(string Message) {}
```

# Example
For example, here is a simple listener that outputs a message to the console whenever a pawn levels up:

```UnrealScript
class LevelUpListener extends EventListener;

function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) 
{
  `log(RPGTacPawn.CharacterName $ " just levelled up!");
}
```

# How do I get my mod to load?
You'll need to also create a [mutator](https://docs.unrealengine.com/udk/Three/UT3Mods.html#Mutators) to take advantage of the game's mutator loader. Have your mutator be a subclass of EventMutator and then use the OnEventManagerCreated() function to register your custom EventListener to the EventManager. Here is an example of what that would look like:

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


