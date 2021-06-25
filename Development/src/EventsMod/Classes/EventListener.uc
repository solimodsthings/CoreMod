// [Events Mod for Himeko Sutori (2021)]

// Other mods should extend EventListener and override
// these functions as necessary. EventListeners can be
// added to an EventManager through OnEventManagerCreated()
// in an EventMutator.
class EventListener extends Object;

// Called once an instance of a PlayerController in the game is created
function OnInitialization(EventManager Manager) {}

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
//
// Events Mod doesn't have any direct hooks into RPGTacPawn
// and relies on periodically taking snapshots of character levels
// and checking whether they go up or not. OnPawnLevelUp() events
// are checked after you win a battle or if you use the givexp console
// command.
//
// This function doesn't get called if you level up through Magic Rab.
// But it will eventually be called the next time you win a battle regardless
// if you level up again or not in that battle.
//
// If you want to force Events Mod to check for level ups without winning
// a battle you can run command "givexp 0" while a character is selected in the 
// lance setup menu. This command gives that character 0 experience points, but
// gets Events Mod to check all snapshots of character levels.
function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) {}

// Called after any pawn is defeated in combat. This will also be called
// when enemies are defeated so remember to check the IsAlly flag.
// This function never gets called if permadeaths are disabled by player.
function OnPawnDefeated(RPGTacPawn DefeatedPawn, bool IsAlly) {}

// Called whenever the player enters the world map
function OnEnterWorldMap() {}

// Called whenever the player enters an area that is not a world map
function OnEnterArea() {}

// Called when a battle begins
function OnBattleStart() {}

// Called when a battle ends and you won
function OnBattleVictory(bool PawnsCelebrate) {}

// Called when the player starts resting on the world map
function OnStartResting(int HoursToRest) {}

function OnCauseEvent(optional Name event){}
