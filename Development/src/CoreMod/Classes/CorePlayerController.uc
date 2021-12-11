// [Core Mod for Himeko Sutori (2021)]

// This controller is the same as the base game's
// RPGTacPlayerController except it maintains a list
// of Plugins and notifies them when certain
// game events occur (player entering new area, character
// level ups, battle victories, etc.)
//
// Warning: Class name cannot change without breaking save files.
// If the class name needs to change, create a class with the old name
// that extends the class with the new name.
//
class CorePlayerController extends RPGTacPlayerController;

struct PawnSnapshot
{
    var RPGTacPawn Character;
    var int CharacterLevelSnapshot;
};

var CoreModJournalPlugin ModInformation;
var array<PawnSnapshot> PawnSnapshots;
var array<Plugin> Plugins;
var array<string> IncompatibleModPluginNames;
var bool FirstMapLoaded;
var bool PostBeginPlayOccurred;
var WorldInfo World;
var RPGTacGame Game;

var string BaseControllerName;
var string BaseControllerClass;
var bool SaveAsBaseController;

var bool IsFirstBattleTurn;

// Used by other mods to add their plugins
// to the game. Only plugins added through
// this function are notified when specific
// game events occur.
function AddPlugin(Plugin Plugin)
{
    if(!PluginExists(Plugin))
    {
        Plugins.AddItem(Plugin);
        // `log("Added mod plugin: " $ Plugin.Id);  // DEBUG

        // Handle late additions
        if(PostBeginPlayOccurred)
        {
            // `log("Added plugin, but PostBeginPlay already occurred");
            InitializePlugin(Plugin);
        }

        if(ModInformation != none)
        {
            ModInformation.UpdateJournal();
        }
    }
    else
    {
        `log("Cannot add mod plugin: " $ Plugin.Id $ " (it already exists)");
    }

}

private function bool PluginExists(Plugin Plugin)
{
    local Plugin ExistingPlugin;

    foreach Plugins(ExistingPlugin)
    {
        if(ExistingPlugin == Plugin || ExistingPlugin.Id == Plugin.Id)
        {
            return true;
        }
    }

    return false;
}

// Override to add new logic. This is the closest thing
// to a constructor or initializer function. We override
// so we can tell other mods/plugins to initialize as
// well.
simulated event PostBeginPlay()
{   
    local Plugin Plugin;

    super.PostBeginPlay();
    PostBeginPlayOccurred = true;

    // This is a special mod plugin that comes with CoreMod
    // whose only purpose is to display loaded mod information in-game.
    ModInformation = new class'CoreModJournalPlugin';
    self.AddPlugin(ModInformation);
    // ModInformation.UpdateJournal(); // Uncomment if journal not updating enough at initialization

    foreach Plugins(Plugin)
    {
        InitializePlugin(Plugin);
    }

    self.World = WorldInfo;
	self.Game = RPGTacGame(WorldInfo.Game);

    // I don't know why these values remain blank when set in DefaultProperties.
    // PostBeginPlay() is the next best place to put this.
    BaseControllerName = "main_base.TheWorld:PersistentLevel.RPGTacPlayerController_1";
    BaseControllerClass = "RPGTacGame.Default__RPGTacPlayerController";
    SaveAsBaseController = false; // False by default or else mods won't see calls to Deserialize() 
}

private function InitializePlugin(Plugin Plugin)
{
    if(!Plugin.IsInitialized)
    {
        Plugin.IsInitialized = true;
        Plugin.Core = self;
        Plugin.OnInitialization();
        LogLoadedMod(Plugin);
    }
}

private function LogLoadedMod(Plugin Plugin)
{
    if(Plugin.Id != "")
    {
        `log("Initialized mod plugin: " $ Plugin.Id);
    }
    else
    {
        `log("Initialized mod plugin: Undefined ID");
    }
}

// Override to notified plugins when inventory is updated.
function NewAddEquipment(EquipmentInventory ReceivedEquipment)
{
    local Plugin Plugin;

    foreach Plugins(Plugin)
    {
        Plugin.OnEquipmentInventoryItemUpdate(ReceivedEquipment);
    }

    super.NewAddEquipment(ReceivedEquipment);
}

// Override. Hooking into this function as it seems to be only called once after
// a SaveState is loaded so there should minimal performance impact.
// Mods that want to work with untouched SaveStates will want to know 
// about know when this occurs.
function ReloadPawnIndex()
{
    local Plugin Plugin;

    super.ReloadPawnIndex();

    foreach Plugins(Plugin)
    {
        Plugin.OnPawnsInitialized(Army);
        Plugin.OnEquipmentInventoryInitialized(NewEquipmentInventory);
    }

    TakePawnSnapshots();    // Initialize snapshot of character levels

}

// Override.
function bool AddPawn(RPGTacPawn NewPawn)
{
    local Plugin Plugin; 
    local PawnSnapshot Snapshot;
    local bool SuccessfullyAdded;

    Snapshot.Character = NewPawn;
    Snapshot.CharacterLevelSnapshot = NewPawn.CharacterLevel;
    PawnSnapshots.AddItem(Snapshot);

    SuccessfullyAdded = super.AddPawn(NewPawn);

    if(SuccessfullyAdded)
    {
        foreach Plugins(Plugin)
        {
            // `log("Calling OnPawnAdded() on plugin '" $ Plugin.Id $ "'");
            Plugin.OnPawnAdded(NewPawn);
        }
    }

    return SuccessfullyAdded;
}

// Checks for level up events
private function TakePawnSnapshots()
{
    local Plugin Plugin; 
    local PawnSnapshot Snapshot;
    local RPGTacPawn ArmyPawn;
    // local bool ExistsInarmy;
    local int i;
    
    //foreach self.PawnSnapshots(Snapshot)
    for(i = PawnSnapshots.Length - 1; i >= 0; i--)
    {
        
        if(PawnSnapshots[i].Character.CharacterLevel > PawnSnapshots[i].CharacterLevelSnapshot)
        {
            // PawnSnapshots[i].CharacterLevelSnapshot = PawnSnapshots[i].Character.CharacterLevel;

            foreach Plugins(Plugin)
            {
                Plugin.OnPawnLevelUp(PawnSnapshots[i].Character);
            }
        }

    }    

    PawnSnapshots.Length = 0; // Clear the array
    foreach Army(ArmyPawn)
    {
        Snapshot.Character = ArmyPawn;
        Snapshot.CharacterLevelSnapshot = ArmyPawn.CharacterLevel;
        PawnSnapshots.AddItem(Snapshot);
    }

}

// Override. This gets called any time the shop inventory is refreshed
// so I worry about performance impact. But this is the only hook
// I can find into the shop menu from PlayerController.
function int GetNumberOfEquipmentTypeInInventory(RPGTacEquipment EquipmentType)
{
    local Plugin Plugin;

    // `log(EquipmentType);

    foreach Plugins(Plugin)
    {
        Plugin.OnShopInventoryItemUpdate(EquipmentType);
    }

	return super.GetNumberOfEquipmentTypeInInventory(EquipmentType);
}

// Override
function PlayVictory(bool PawnsCelebrate)
{
    local Plugin Plugin;
    foreach Plugins(Plugin)
    {
        Plugin.OnBattleVictory(PawnsCelebrate);
    }

    TakePawnSnapshots();

    super.PlayVictory(PawnsCelebrate);
}

//Override
function WithdrawSquad(bool Withdraw)
{
    local Plugin Plugin;
    
    super.WithdrawSquad(Withdraw);
    
    if(DeployedSquads.Length == 0)
    {
        foreach Plugins(Plugin)
        {
            Plugin.OnBattleRetreatAll();
        }
    }
    
}

// Override
function StartResting(int NewHoursToRest) 
{
    local Plugin Plugin;
    
    super.StartResting(NewHoursToRest);
    
    foreach Plugins(Plugin)
    {
        Plugin.OnStartResting(NewHoursToRest);
    }
    
}

// Override. Let plugins know which pawns have been
// defeated, but only if permadeath is still enabled.
// Permadeath is enabled by default unless the
// player turns it off via console command.
function ClearDeadPawns()
{
    local RPGTacPawn DeadPawn;
    local Plugin Plugin;

    if(CurrentMenu != none && CurrentMenu.OptionsLoader != none && !CurrentMenu.OptionsLoader.DisablePermadeath)
    {
        foreach DeadPawns(DeadPawn)
        {
            if(DeadPawn.CurrentHitPoints <= 0) // Check hp or we could get duplicates
            {
                foreach Plugins(Plugin)
                {
                    Plugin.OnPawnDefeated(DeadPawn, DeadPawn.ArmyController == self);
                }
            }
        }

	}
    
    super.ClearDeadPawns();
}

// Override to make sure we catch levelups
// that occur as a result of a player using this
// console command.
exec function GiveXP(int XP)
{
	super.GiveXP(XP);
    TakePawnSnapshots();
}

// Override.
exec function ChangeModes(int NewMode)
{
    local Plugin Plugin;

    super.ChangeModes(NewMode);

    if(NewMode == 9)
    {
        // Next turn will be the first turn
        IsFirstBattleTurn = true;
    }

    foreach Plugins(Plugin)
    {
        if(NewMode == 2)
        {
            Plugin.OnEnterArea();
        }
        else if(NewMode == 10)
        {
            Plugin.OnEnterWorldMap();
        }
        else if(NewMode == 9)
        {
            Plugin.OnBattleStart();
            // TakePawnSnapshots();
        }
    }

}

// Override
function StartTurn()
{
    local Plugin Plugin;
    super.StartTurn();

    if(IsFirstBattleTurn)
    {
        IsFirstBattleTurn = false;

        foreach Plugins(Plugin)
        {
            Plugin.OnBattleFirstTurnStart();
        }
    }

    foreach Plugins(Plugin)
    {
        Plugin.OnBattleTurnStart();
    }

}

// Override
function EndTurn()
{
    local Plugin Plugin;
    super.EndTurn();

    foreach Plugins(Plugin)
    {
        Plugin.OnBattleTurnEnd();
    }
}

// Override
function CauseEvent(optional Name n)
{
    local Plugin Plugin;

    super.CauseEvent(n);

    foreach Plugins(Plugin)
    {
        Plugin.OnCauseEvent(n);
    }
}

// Override to give plugins a chance to also save their own information
// in save files. Mods/plugins are not permitted to touch information
// that the base game or other mods/plugins try to save.
function String Serialize() 
{
    local JSonObject Data;
    local JsonObject PluginData;
    local Plugin Plugin;

    foreach Plugins(Plugin)
    {
        Plugin.PreSerialize();
    }

    Data = class'JSonObject'.static.DecodeJson(super.Serialize());

    if(SaveAsBaseController)
    {
        // If allowed, we make sure that this player controller is recorded as a
        // RPGTacPlayerController in the save file. This will let players remove Events Mod
        // without bricking their save file.
        Data.SetStringValue("Name", BaseControllerName); 
        Data.SetStringValue("ObjectArchetype", BaseControllerClass);
    }
    
    // Give all plugins/mods a chance to include their own data in the save file
    foreach Plugins(Plugin)
    {
        if(Plugin.Id != "")
        {
            PluginData = Plugin.Serialize();
            if(PluginData != none)
            {
                Data.SetObject("Mod_" $ Plugin.Id, PluginData);
            }
        }
    }

    foreach Plugins(Plugin)
    {
        Plugin.PostSerialize();
    }

    return class'JSonObject'.static.EncodeJson(Data);
}

// Override to permit mods/plugins to load information
// they might have previously saved in save files. 
function Deserialize(JSonObject Data)
{
    local JsonObject PluginData;
    local Plugin Plugin;

    super.Deserialize(Data);

    foreach Plugins(Plugin)
    {
        if(Plugin.Id != "")
        {
            PluginData = Data.GetObject("Mod_" $ Plugin.Id);
            if(PluginData != none)
            {
                Plugin.Deserialize(PluginData);
            }
        }
    }

}

// Override to permit mods to respond to mouse events.
function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
    local Plugin Plugin;

    super.HandleMouseInput(MouseEvent, InputEvent);

    foreach Plugins(Plugin)
    {
        Plugin.OnHandleMouseInput(MouseEvent, InputEvent);
    }
}

// Override to permit mods to draw to screen.
function DrawHUD(HUD Hud)
{
    local Plugin Plugin;
    
    super.DrawHUD(Hud);
    
    foreach Plugins(Plugin)
    {
        Plugin.OnDrawHUD(Hud);
    }
}

// New command. Lists all plugins of currently loaded
// mods. Mods should ensure they set their ID to something unique.
exec function ListMods()
{
    local Plugin Plugin;

    foreach Plugins(Plugin)
    {
       LogLoadedMod(Plugin); 
    }
}

// New console command. Sends a command or message to the a mod with
// the specified ID. This is necessary as mods cannot create their
// own console command.
exec function TellMod(string ModId, string Message)
{
    local Plugin Plugin;
    foreach Plugins(Plugin)
    {
        if(ModId != "" && Locs(ModId) == Locs(Plugin.Id))
        {
            Plugin.OnReceiveMessage(Message); 
        }
    }
}

// New console command. An alias for Tellmod.
exec function Mod(string ModId, string Message)
{
    TellMod(ModId, Message);
}

// New console command. Used when a player has a modded campaign and wants
// to remove EventsMod without bricking their save file.
//
// The player needs to call 'UseBaseControllerWhenSaving True' and then
// save their campaign once before removing EventsMod.
exec function UseBaseControllerWhenSaving(bool Option)
{
    SaveAsBaseController = Option;
}

DefaultProperties{
    FirstMapLoaded = false
    PostBeginPlayOccurred = false
}
