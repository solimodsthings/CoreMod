// [Core Mod for Himeko Sutori (2021)]

// This mutator class is meant for other mods to extend
// as their mutator so they can register their Plugins with
// OnLoad().
class ModStart extends RPGTacMutator
	dependson(AbstractPlugin);

var string ModName;        // To be populated by classes extending ModStart. Used for mod info journal
var array<class> Plugins;  // To be populated by classes extending ModStart
var bool IsPluginsLoaded;

// Deprecated, but still supported for backwards compatibility.
// Only supports base campaign plugins. The preferred way is for
// mutators that extend ModStart to populate the Plugins array of
// classes through DefaultProperties.
function OnStart(CorePlayerController Core){}

// This gets called multiple times after a savefile is loaded.
// The player controller is not guaranteed to exist on the first call
// so we check repeatedly until it does.
function bool CheckReplacement(Actor Other)
{	
	if(!IsPluginsLoaded)
	{
		TryLoadPlugins();	
	}

	return super.CheckReplacement(Other);
}

// Mod plugins cannot be loaded until a player controller
// exists. Once it exists, a plugin can only be successfully
// loaded if it is compatible with the current game type.
private function TryLoadPlugins()
{
	local PlayerController Controller;
	
	if(!IsPluginsLoaded)
	{
		Controller = WorldInfo.Game.GetALocalPlayerController();

		if(Controller != none && CorePlayerController(Controller) != none)
		{
			IsPluginsLoaded = true; // Important for this to be first or there can be a race condition
			LoadModPluginsForBaseCampaign(CorePlayerController(Controller));
		}

		// TODO: Once SRVPlayerController becomes available call
		// if(Controller != none && CoreExpansionPlayerController(Controller) != none)
		// {
		//	  PlayerControllerExists = true;
		//	  LoadModPluginsForExpansionCampaign(CoreExpansionPlayerController(Controller));
		// }

	}
}

private function LoadModPluginsForBaseCampaign(CorePlayerController Core)
{
	local PluginCollection Collection;
	local Plugin Plugin;
	local ExpansionPlugin ExpansionPlugin;
	local AbstractPlugin AbstractPlugin;
	local array<AbstractPlugin> IncompatiblePlugins;
	local Class TargetClass;

	// This implicitly sorts plugins by compatibility
	Collection = new class'PluginCollection';

	foreach Plugins(TargetClass)
	{
		AbstractPlugin = AbstractPlugin(new TargetClass);
		TryPopulateModName(AbstractPlugin);
		Collection.Add(AbstractPlugin);
	}

	//OnLoad(Plugins); // Allow mod to add both base campaign and expansion plugins to collection

	// Only load base campaign plugins if the mod has strictly said it is compatible
	// or if no compatibility was declared
	if(IsCompatibleWithBaseCampaign())
	{
		foreach Collection.BaseCampaignPlugins(Plugin)
		{
			Core.AddPlugin(Plugin);
		}

		// For backwards compatiblity only as OnStart() is deprecated
		// Duplicates  will be gracefully ignored by CorePlayerController
		OnStart(Core); 
	}
	else
	{
		foreach Collection.BaseCampaignPlugins(Plugin)
		{
			IncompatiblePlugins.AddItem(Plugin);
		}
	}
	
	foreach Collection.ExpansionPlugins(ExpansionPlugin)
	{
		IncompatiblePlugins.AddItem(ExpansionPlugin);
	}

	foreach IncompatiblePlugins(AbstractPlugin)
	{
		TryPopulateModName(AbstractPlugin);

		if(AbstractPlugin.ModName == "")
		{
			AbstractPlugin.ModName = "Unnamed Mod";
		}

		// PluginId = AbstractPlugin.Id;

		if(AbstractPlugin.Id == "")
		{
			AbstractPlugin.Id = "Unidentified Plugin";
		}

		// IncompatibleModName = AbstractPlugin.ModName $ ": '" $ PluginId $ "'";

		// Core.IncompatibleModPluginNames.AddItem(IncompatibleModName);

		Core.IncompatiblePlugins.AddItem(AbstractPlugin);

	}
}

// Tries to set the plugin's ModName variable to match
// this mutator's ModName variable. Only works if the plugin's
// ModName is empty and its parent mutator isn't.
private function TryPopulateModName(AbstractPlugin Plugin)
{
	if(Plugin.ModName == "" && ModName != "")
	{
		Plugin.ModName = ModName;
	}
}

// Returns true if this mod declared itself compatible with the
// base campaign (which is RPGTacGame) or did not specify any compatibility.
// If no compatibility was declared, we will still be able to load the correct
// plugins via class type as a safety net.
private function bool IsCompatibleWithBaseCampaign()
{
	return IntendedGameTypes.Length == 0 || HasGameType("RPGTacGame.RPGTacGame");
}

// Returns true if the specified game type is an item
// in array self.IntendedGameTypes
private function bool HasGameType(string TargetGameType)
{
	local string GameType;
	foreach IntendedGameTypes(GameType)
	{
		if(GameType == TargetGameType)
		{
			return true;
		}
	}

	return false;
}

DefaultProperties
{
    IsPluginsLoaded = false
}