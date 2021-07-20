// [Events Mod for Himeko Sutori (2021)]

// This controller is the same as the base game's
// RPGTacPlayerController except it maintains a list
// of EventListeners and notifies them when certain
// game events occur (player entering new area, character
// level ups, battle victories, etc.)
class EventManager extends RPGTacPlayerController;

struct PawnSnapshot
{
    var RPGTacPawn Character;
    var int CharacterLevelSnapshot;
};

var array<PawnSnapshot> PawnSnapshots;
var array<EventListener> Listeners;
var bool FirstMapLoaded;
var bool PostBeginPlayOccurred;
var WorldInfo World;
var RPGTacGame Game;

var string BaseControllerName;
var string BaseControllerClass;
var bool SaveAsBaseController;

// Used by other mods to add their listeners
// to the game. Only listeners added through
// this function are notified when specific
// game events occur.
function AddListener(EventListener listener)
{
    Listeners.AddItem(listener);

    // Handle late additions
    if(PostBeginPlayOccurred)
    {
        listener.Manager = self;
        listener.OnInitialization();
        LogLoadedMod(listener);
    }
}

// Override to add new logic. This is the closest thing
// to a constructor or initializer function. We override
// so we can tell other mods/listeners to initialize as
// well.
simulated event PostBeginPlay()
{   
    local EventListener listener;

    super.PostBeginPlay();
    PostBeginPlayOccurred = true;

    foreach Listeners(listener)
    {
        listener.Manager = self;
        listener.OnInitialization();
        LogLoadedMod(listener);
    }

    self.World = WorldInfo;
	self.Game = RPGTacGame(WorldInfo.Game);

    // I don't know why these values remain blank when set in DefaultProperties.
    // PostBeginPlay() is the next best place to put this.
    BaseControllerName = "main_base.TheWorld:PersistentLevel.RPGTacPlayerController_1";
    BaseControllerClass = "RPGTacGame.Default__RPGTacPlayerController";
    SaveAsBaseController = false; // False by default or else mods won't see calls to Deserialize() 
}

private function LogLoadedMod(EventListener listener)
{
    if(listener.Id != "")
    {
        `log("Mod loaded: " $ listener.Id);
    }
    else
    {
        `log("Mod loaded: Undefined ID");
    }
}

// Override to notified listeners when inventory is updated.
function NewAddEquipment(EquipmentInventory ReceivedEquipment)
{
    local EventListener listener;

    foreach Listeners(listener)
    {
        listener.OnEquipmentInventoryItemUpdate(ReceivedEquipment);
    }

    super.NewAddEquipment(ReceivedEquipment);
}

// Override. Hooking into this function as it seems to be only called once after
// a SaveState is loaded so there should minimal performance impact.
// Mods that want to work with untouched SaveStates will want to know 
// about know when this occurs.
function ReloadPawnIndex()
{
    local EventListener Listener;

    super.ReloadPawnIndex();

    foreach Listeners(Listener)
    {
        Listener.OnPawnsInitialized(Army);
        Listener.OnEquipmentInventoryInitialized(NewEquipmentInventory);
    }

    TakePawnSnapshots();    // Initialize snapshot of character levels

}

// Override.
function bool AddPawn(RPGTacPawn NewPawn)
{
    local EventListener Listener; 
    local PawnSnapshot Snapshot;
    local bool SuccessfullyAdded;

    Snapshot.Character = NewPawn;
    Snapshot.CharacterLevelSnapshot = NewPawn.CharacterLevel;
    PawnSnapshots.AddItem(Snapshot);

    SuccessfullyAdded = super.AddPawn(NewPawn);

    if(SuccessfullyAdded)
    {
        foreach Listeners(Listener)
        {
            Listener.OnPawnAdded(NewPawn);
        }
    }

    return SuccessfullyAdded;
}

// Checks for level up events
private function TakePawnSnapshots()
{
    local EventListener Listener; 
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

            foreach Listeners(Listener)
            {
                Listener.OnPawnLevelUp(PawnSnapshots[i].Character);
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
    local EventListener Listener;

    `log(EquipmentType);

    foreach Listeners(Listener)
    {
        Listener.OnShopInventoryItemUpdate(EquipmentType);
    }

	return super.GetNumberOfEquipmentTypeInInventory(EquipmentType);
}

// Override
function PlayVictory(bool PawnsCelebrate)
{
    local EventListener Listener;
    foreach Listeners(Listener)
    {
        Listener.OnBattleVictory(PawnsCelebrate);
    }

    TakePawnSnapshots();

    super.PlayVictory(PawnsCelebrate);
}

// Override
function StartResting(int NewHoursToRest) 
{
    local EventListener Listener;
    
    super.StartResting(NewHoursToRest);
    
    foreach Listeners(Listener)
    {
        Listener.OnStartResting(NewHoursToRest);
    }
    
}

// Override. Let listeners know which pawns have been
// defeated, but only if permadeath is still enabled.
// Permadeath is enabled by default unless the
// player turns it off via console command.
function ClearDeadPawns()
{
    local RPGTacPawn DeadPawn;
    local EventListener Listener;

    if(CurrentMenu != none && CurrentMenu.OptionsLoader != none && !CurrentMenu.OptionsLoader.DisablePermadeath)
    {
        foreach DeadPawns(DeadPawn)
        {
            if(DeadPawn.CurrentHitPoints <= 0) // Check hp or we could get duplicates
            {
                foreach Listeners(Listener)
                {
                    Listener.OnPawnDefeated(DeadPawn, DeadPawn.ArmyController == self);
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
    local EventListener Listener;

    super.ChangeModes(NewMode);

    foreach Listeners(Listener)
    {
        if(NewMode == 2)
        {
            Listener.OnEnterArea();
        }
        else if(NewMode == 10)
        {
            Listener.OnEnterWorldMap();
        }
        else if(NewMode == 9)
        {
            Listener.OnBattleStart();
            // TakePawnSnapshots();
        }
    }
}

// Override
function CauseEvent(optional Name n)
{
    local EventListener listener;

    super.CauseEvent(n);

    foreach Listeners(listener)
    {
        listener.OnCauseEvent(n);
    }
}

// Override to give listeners a chance to also save their own information
// in save files. Mods/listeners are not permitted to touch information
// that the base game or other mods/listeners try to save.
function String Serialize() 
{
    local JSonObject Data;
    local JsonObject ListenerData;
    local EventListener Listener;

    foreach Listeners(Listener)
    {
        Listener.PreSerialize();
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
    
    // Give all listeners/mods a chance to include their own data in the save file
    foreach Listeners(Listener)
    {
        if(Listener.Id != "")
        {
            ListenerData = Listener.Serialize();
            if(ListenerData != none)
            {
                Data.SetObject("Mod_" $ Listener.Id, ListenerData);
            }
        }
    }

    foreach Listeners(Listener)
    {
        Listener.PostSerialize();
    }

    return class'JSonObject'.static.EncodeJson(Data);
}

// Override to permit mods/listeners to load information
// they might have previously saved in save files. 
function Deserialize(JSonObject Data)
{
    local JsonObject ListenerData;
    local EventListener Listener;

    super.Deserialize(Data);

    foreach Listeners(Listener)
    {
        if(Listener.Id != "")
        {
            ListenerData = Data.GetObject("Mod_" $ Listener.Id);
            if(ListenerData != none)
            {
                Listener.Deserialize(ListenerData);
            }
        }
    }

}

// Potential new hook for mods to use.
function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
    super.HandleMouseInput(MouseEvent, InputEvent);
}

// Potential new hook for mods to use.
function DrawHUD(HUD hud)
{
    super.DrawHUD(hud);
}

// New command. Lists all listeners of currently loaded
// mods. Mods should ensure they set their ID to something unique.
exec function ListMods()
{
    local EventListener Listener;

    `log("Mod loaded: Events Mod"); // Events Mod is not a listener so we need to list it explicitly
    foreach Listeners(Listener)
    {
       LogLoadedMod(Listener); 
    }
}

// New console command. Sends a command or message to the a mod with
// the specified ID. This is necessary as mods cannot create their
// own console command.
exec function TellMod(string ModId, string Message)
{
    local EventListener Listener;
    foreach Listeners(Listener)
    {
        if(ModId != "" && Locs(ModId) == Locs(Listener.Id))
        {
            Listener.OnReceiveMessage(Message); 
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

// Just a helper function for Modifier classes that can't 
// instantiate actors themselves
/*
function RPGTacCharacterClass SpawnCharacterClassInstance(RPGTacCharacterClass ClassArchetype)
{
    return spawn(class'RPGTacCharacterClass',,,,,ClassArchetype);
}


// A helper function
function RPGTacJournalEntry SpawnJournalEntryInstance()
{
    return spawn(class'RPGTacJournalEntry',,,,,,true);
}
 */


DefaultProperties{
    FirstMapLoaded = false
    PostBeginPlayOccurred = false
}
