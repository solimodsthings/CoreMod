![Banner](https://i.imgur.com/912nCk0.png)

# Overview
Core Mod is a utility mod for [Himeko Sutori](https://himekosutori.com/). It does not add new content to the game, but is a dependency for some other mods to function. It's main purpose is to detect when specific in-game events occur (level ups, battle victories, etc.) and then notify other mods what has happened.

Core Mod replaces the game's ```RPGTacPlayerController``` instance with a ```CorePlayerController``` instance. ```CorePlayerController``` behaves identically to ```RPGTacPlayerController``` except it supports mod ```Plugins``` and notifies those ```Plugins``` whenver certain game events occur. It is possible to make mods without knowing the internal workings of the game this way and it also allows compatibility between multiple mods that need to modify ```RPGTacPlayerController``` in some way. 

Core Mod is available in the Steam Workshop. Simply subscribe to the mod if it is required for another mod you're looking to use.

# Information for Developers

## How does this work?
When creating a new mod, create a subclass of ```Plugin``` and override the functions you wish to act on. You only need to override the functions you want to use.

The ```Plugin``` class currently has the following callback functions available for mods:

## Functions for modifying characters
```UnrealScript
// Called once it is "safe" to parse through all pawns in the game
function OnPawnsInitialized(Array<RPGTacPawn> Pawns) {}

// Called when a character levels up. If a character levels up
// during battle, this function isn't called until you win.
function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) {}

// Called after any pawn is defeated in combat. This will also be called
// when enemies are defeated so remember to check the IsAlly flag.
// This function never gets called if permadeaths are disabled by player.
function OnPawnDefeated(RPGTacPawn DefeatedPawn, bool IsAlly) {}
```

## Functions for modifying equipment and inventories
```UnrealScript
// Called once it is "safe" to parse through inventory
function OnEquipmentInventoryInitialized(Array<EquipmentInventory> EquimentInventory) {}

// Called whenever an item is added to the player inventory
function OnEquipmentInventoryItemUpdate(EquipmentInventory InventoryItem) {}

// Called whenever a shop inventory is refreshed (note: it is refreshed multiple times a second it seems if the shop menu is open)
function OnShopInventoryItemUpdate(RPGTacEquipment EquipmentType) {}
```

## Functions for detecting game events
```UnrealScript
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
```

## Functions for saving and loading mod data
```UnrealScript
// For any prep work just before data serialization occurs.
function PreSerialize() {}

// Called when the game is creating a save file to write
// to disk. If you need information stored in the save
// file, override this function and return a JsonObject
// containing data you want saved.
function JSonObject Serialize() {return none;}

// For any clean up work after serialization occurs.
function PostSerialize() {}

// Called when the game is loading a save file from disk
// and information previously serialized by this listener
// neds to be deserialized.
function Deserialize(JSonObject ListenerData) {}
```

## Utility Functions
```UnrealScript
// Called once an instance of a PlayerController in the game is created
function OnInitialization() {}

// This function is called when a player uses command
// 'tellmod' in the console to send this listener a message.
function OnReceiveMessage(string Message) {}

// Used to handle mouse events.
function OnHandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent) {}

// Used to draw directly to screen.
function OnDrawHUD(HUD Hud) {}
```

## Example
For example, here is a simple mod that outputs a message to the console whenever a pawn levels up:

```UnrealScript
class LevelUpPlugin extends Plugin;

function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) 
{
  `log(LevelledUpPawn.CharacterName $ " just levelled up!");
}
```

## How do I get my mod loaded into my game?
You'll need to also create a [mutator](https://docs.unrealengine.com/udk/Three/UT3Mods.html#Mutators) to take advantage of the game's mutator loader. Have your mutator be a subclass of ```ModStart``` and then use the ```OnStart()``` function to register your custom ```Plugin``` to the ```CorePlayerController```. Here is an example of what that would look like:

```UnrealScript
class MyCustomStart extends ModStart;

function OnStart(CorePlayerController Core)
{
  Core.AddPlugin(new class'LevelUpPlugin');
}
```

You then need to add the CoreMod's mutator and your own mutator to your ```RPGTacMods.ini``` file like so:
```
[rpgtacgame.RPGTacMutatorLoader]
MutatorsLoaded=CoreMod.CoreStart,MyCustomMod.MyCustomStart
```
You can also subscribe to Core Mod in the Steam Workshop and use the HS Mod Loader now bundled with Himeko Sutori to enable it. CoreMod needs to be first in the list so it is loaded first.

For a fuller example, check out the [More Classes Mod](https://github.com/solimodsthings/MoreClassesMod).


