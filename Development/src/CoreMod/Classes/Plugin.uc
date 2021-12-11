// [Core Mod for Himeko Sutori (2021)]

// This class is for base campaign mods to use.
//
// Extend this class in your own mods and override
// the functions as necessary. Plugins should be
// added to the CorePlayerController through the OnStart()
// function in ModStart.
class Plugin extends AbstractPlugin;

// This needs to be defined by a listener via DefaultProperties
// especially if there is a need to use Serialize() and Deserialize() later.
// This property is used to form the keyname for serialized listener data and
// also used as the name of mod when the ListMods command is used.
// var string Id;

// This property is set automatically when CorePlayerController 
// initializes all Plugins. It is not safe to use
// this property until OnInitialization() is called.
var CorePlayerController Core;

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
//
// Core Mod doesn't have any direct hooks into RPGTacPawn
// and relies on periodically taking snapshots of character levels
// and checking whether they go up or not. OnPawnLevelUp() events
// are checked after you win a battle or if you use the givexp console
// command.
//
// This function doesn't get called if you level up through Magic Rab.
// But it will eventually be called the next time you win a battle regardless
// if you level up again or not in that battle.
//
// If you want to force Core Mod to check for level ups without winning
// a battle you can run command "givexp 0" while a character is selected in the 
// lance setup menu. This command gives that character 0 experience points, but
// gets Core Mod to check all snapshots of character levels.
function OnPawnLevelUp(RPGTacPawn LevelledUpPawn) {}

// Called after any pawn is defeated in combat. This will also be called
// when enemies are defeated so remember to check the IsAlly flag.
// This function never gets called if permadeaths are disabled by player.
function OnPawnDefeated(RPGTacPawn DefeatedPawn, bool IsAlly) {}

// Called when the game (successfully) adds a new pawn to the army.
// This is a good function to use when you need to act on new recruits.
function OnPawnAdded(RPGTacPawn AddedPawn) {}

// Called whenever the player enters the world map
function OnEnterWorldMap() {}

// Called whenever the player enters an area that is not the world map
function OnEnterArea() {}

// Called when a battle begins
function OnBattleStart() {}

// Only called when the first battle turn starts
// Useful for applying buffs to deployed pawns only
function OnBattleFirstTurnStart() {}

// Called when any battle turn starts,
// including the first battle turn
function OnBattleTurnStart() {}

// Called when a battle turn ends
function OnBattleTurnEnd() {}

// Called when a battle ends and you won
function OnBattleVictory(bool PawnsCelebrate) {}

// Called when a battle ends because all squads retreated
function OnBattleRetreatAll() {}

// Called when the player starts resting on the world map
function OnStartResting(int HoursToRest) {}

// This is primarily used to detect when kismet events are triggered
function OnCauseEvent(optional Name event){}

function PreSerialize() {}

// Called when the game is creating a save file to write
// to disk. If you need information stored in the save
// file, override this function and return a JsonObject
// containing data you want saved.
//
// Ensure your listener's Id property is set to something
// unique to your mod. The Id will be used to construct the
// keyname for the JSonObject you return. If Id is an empty
// string, any JSonObject you return here will be ignored.
function JSonObject Serialize() {return none;}

function PostSerialize() {}

// Called when the game is loading a save file from disk
// and information previously serialized by this listener
// neds to be deserialized.
//
// You only need to override this function if you need to 
// get information from save files that you stored previously
// through the Serialize() function.
function Deserialize(JSonObject ListenerData) {}

// This function is called when a player uses command
// 'tellmod' in the console to send this listener a message.
function OnReceiveMessage(string Message) {}

// Used to handle mouse events.
function OnHandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent) {}

// Used to draw directly to screen.
function OnDrawHUD(HUD Hud) {}
