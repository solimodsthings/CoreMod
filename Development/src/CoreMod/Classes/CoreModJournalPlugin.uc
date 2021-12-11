
// Inserts a custom journal entry into the
// in-game journal that displays mod information.
// This plugin only works for the base campaign.
class CoreModJournalPlugin extends Plugin;

var RPGTacJournalEntry CustomEntry;

// Override. Instantiate the custom journal entry we'll
// be working with.
function OnInitialization()
{
    if(CustomEntry == none)
    {
        CustomEntry = Core.Spawn(class'RPGTacJournalEntry',,,,,,true);
        CustomEntry.EntryName = "Mod Information";
        CustomEntry.Category = EJournal_GameConcepts;
        Core.AddJournalEntry(CustomEntry);
    }
}

function UpdateJournal()
{
    local Plugin Plugin;
    local RPGTacMutator Mutator;
    local class<RPGTacMutator> MutatorClass;
    local array<string> MutatorNames;
    local string MutatorName;    
    local array<string> CompatibleMutatorNames;
    local array<string> IncompatibleMutatorNames;
    local string IncompatiblePluginName;
    local array<string> UndeclaredMutatorNames;

    CustomEntry.EntryInfo = "";
    MutatorNames = GetMutators();

    // `log("DEBUG: " $ self $ " UpdateJournal() called");

    foreach MutatorNames(MutatorName)
    {
        MutatorClass = class<RPGTacMutator>(DynamicLoadObject(MutatorName, class'Class'));
        Mutator = Core.Spawn(MutatorClass,,,,,,true);

        if(Mutator != none)
        {
            if(Mutator.IntendedGameTypes.Length == 0)
            {
                UndeclaredMutatorNames.AddItem(MutatorName);    
            }
            else if(HasGameType(Mutator.IntendedGameTypes, "RPGTacGame.RPGTacGame"))
            {
                CompatibleMutatorNames.AddItem(MutatorName);
            }
            else
            {
                IncompatibleMutatorNames.AddItem(MutatorName);
            }
        }
        else
        {
            // Not an RPGTacMutator
            UndeclaredMutatorNames.AddItem(MutatorName);
        }

        Mutator.Destroy();
    }

    CustomEntry.EntryInfo $= "[Mutators Compatible with Campaign]\n";
    foreach CompatibleMutatorNames(MutatorName)
    {
        CustomEntry.EntryInfo $= " + " $ GetFittedMutatorName(MutatorName) $ "\n";
    }

    if(CompatibleMutatorNames.Length == 0){ CustomEntry.EntryInfo $= "None\n"; }

    CustomEntry.EntryInfo $= "\n";
    CustomEntry.EntryInfo $= "[Mutators Incompatible with Campaign]\n";
    foreach IncompatibleMutatorNames(MutatorName)
    {
        CustomEntry.EntryInfo $= " + " $ GetFittedMutatorName(MutatorName) $ "\n";
    }

    if(IncompatibleMutatorNames.Length == 0){ CustomEntry.EntryInfo $= "None\n"; }

    CustomEntry.EntryInfo $= "\n";
    CustomEntry.EntryInfo $= "[Mutators with Undeclared Compatibility]\n";
    foreach UndeclaredMutatorNames(MutatorName)
    {
        CustomEntry.EntryInfo $= " + " $ GetFittedMutatorName(MutatorName) $ "\n";
    }

    if(UndeclaredMutatorNames.Length == 0){ CustomEntry.EntryInfo $= "None\n"; }

    if(MutatorNames.Length == 0)
    {
        CustomEntry.EntryInfo $= "None";
    }

    CustomEntry.EntryInfo $= "\n";
    CustomEntry.EntryInfo $= "[Plugins Active in Current Campaign]\n";
    foreach Core.Plugins(Plugin)
    {
        CustomEntry.EntryInfo $= " + " $ Plugin.Id $ "\n";
    }

    if(Core.Plugins.Length == 0)
    {
        CustomEntry.EntryInfo $= "None";
    }

    CustomEntry.EntryInfo $= "\n";
    CustomEntry.EntryInfo $= "[Plugins Incompatible with Current Campaign]\n";
    foreach Core.IncompatibleModPluginNames(IncompatiblePluginName)
    {
        CustomEntry.EntryInfo $= " + " $ IncompatiblePluginName;
    }

    if(Core.IncompatibleModPluginNames.Length == 0)
    {
        CustomEntry.EntryInfo $= "None";
    }
}

// Override. Temporarily remove the custom entry
// from the main journal entries array so it doesn't get
// recorded in the save file.
function PreSerialize()
{
    Core.JournalEntries.RemoveItem(CustomEntry);
}

// Override. Return the custom journal entry
// back into the main journal entries array.
function PostSerialize()
{
    Core.AddJournalEntry(CustomEntry);
}

private function string GetFittedMutatorName(string mutatorName)
{
    if(Len(mutatorName) < 40)
    {
        return mutatorName;
    }
    else
    {
        return Repl(mutatorName,".","\n     .");
    }
}

private function array<string> GetMutators()
{
    local RPGTacMutatorLoader MutatorLoader;
    local string MutatorString;
    local array<string> Tokens;
    local string Token;
    local array<string> Result;

    MutatorLoader = new class'RPGTacMutatorLoader';

    if(MutatorLoader != none)
    {
        foreach MutatorLoader.MutatorsLoaded(MutatorString)
        {
            Tokens = SplitString(MutatorString,",");
            foreach Tokens(Token)
            {
                Result.AddItem(Token);
            }
        }
    }
    
    return Result;
}

// Returns true if the specified game type is an item
// in array self.IntendedGameTypes
private function bool HasGameType(array<string> intendedGameTypes, string targetGameType)
{
	local string GameType;
	foreach intendedGameTypes(GameType)
	{
		if(GameType == targetGameType)
		{
			return true;
		}
	}

	return false;
}

DefaultProperties
{
    Id = "CoreMod.InfoJournal"
}