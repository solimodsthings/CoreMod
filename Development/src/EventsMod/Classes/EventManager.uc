// [Events Mod for Himeko Sutori (2021)]

// This controller is an "observable" version of
// RPGTacPlayerController. It keeps a list of
// EventListeners and relays game events to them.
// This class also tries to guess when certain events
// occur (eg. level ups). 
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
var RPGTacGame Game;

function AddListener(EventListener listener)
{
    Listeners.AddItem(listener);

    // Handle late additions
    if(PostBeginPlayOccurred)
    {
        listener.OnInitialization(self);
    }
}

// Hooks
simulated event PostBeginPlay()
{   
    local EventListener listener;

    PostBeginPlayOccurred = true;

    foreach Listeners(listener)
    {
        listener.OnInitialization(self);
    }

    super.PostBeginPlay();
}

function NewAddEquipment(EquipmentInventory ReceivedEquipment)
{
    local EventListener listener;

    foreach Listeners(listener)
    {
        listener.OnEquipmentInventoryItemUpdate(ReceivedEquipment);
    }

    super.NewAddEquipment(ReceivedEquipment);
}

// Also hooking into this function for now. It seems to be only called once after
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

function bool AddPawn(RPGTacPawn NewPawn)
{
    local PawnSnapshot Snapshot;
    Snapshot.Character = NewPawn;
    Snapshot.CharacterLevelSnapshot = NewPawn.CharacterLevel;
    PawnSnapshots.AddItem(Snapshot);

    // `log("!!!!!!!!! Size of PawnSnapshots is " $ PawnSnapshots.Length);

    return super.AddPawn(NewPawn);
}

// Checks for level up events
function TakePawnSnapshots()
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

    // Is there a better way to clean up snapshots of
    // pawns that are no longer in the army?
    // This method doesn't work:
    /*
    for(i = PawnSnapshots.Length - 1; i >= 0; i--)
    {
        ExistsInArmy = false;
        foreach Army(ArmyPawn)
        {
            if(PawnSnapshots[i].Character == ArmyPawn)
            {
                ExistsInArmy = true;
                break;
            }
        }

        if(!ExistsInArmy)
        {
            `log("Removed pawn snapshot for " $ PawnSnapshots[i].Character.CharacterName);
            PawnSnapshots.Remove(i,1);
        }

    }
    */
    PawnSnapshots.Length = 0; // Clear the array
    foreach Army(ArmyPawn)
    {
        Snapshot.Character = ArmyPawn;
        Snapshot.CharacterLevelSnapshot = ArmyPawn.CharacterLevel;
        PawnSnapshots.AddItem(Snapshot);
    }

    // `log("!!!!!!!!! Size of PawnSnapshots is " $ PawnSnapshots.Length);

}

// This gets called any time the shop inventory is refreshed
// so I worry about performance impact. But this is the only hook
// I can find into the shop menu from PlayerController.
function int GetNumberOfEquipmentTypeInInventory(RPGTacEquipment EquipmentType)
{
    local EventListener Listener;

    foreach Listeners(Listener)
    {
        Listener.OnShopInventoryItemUpdate(EquipmentType);
    }

	return super.GetNumberOfEquipmentTypeInInventory(EquipmentType);
}

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

function StartResting(int NewHoursToRest) 
{
    local EventListener Listener;
    foreach Listeners(Listener)
    {
        Listener.OnStartResting(NewHoursToRest);
    }
    super.StartResting(NewHoursToRest);
}

exec function GiveXP(int XP)
{
	super.GiveXP(XP);
    TakePawnSnapshots();
}

exec function ChangeModes(int NewMode)
{
    local EventListener Listener;
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
    super.ChangeModes(NewMode);
}

// Just a helper function for Modifier classes that can't 
// instantiate actors themselves
function RPGTacCharacterClass SpawnCharacterClassInstance(RPGTacCharacterClass ClassArchetype)
{
    return spawn(class'RPGTacCharacterClass',,,,,ClassArchetype);
}

DefaultProperties{
    FirstMapLoaded = false;
    PostBeginPlayOccurred = false;
}

