// [Core Mod for Himeko Sutori (2021)]

// This mutator class is meant for other mods to extend
// as their mutator so they can register their Plugins with
// OnLoad().
// class ModStart extends Mutator;
class ModStart extends RPGTacMutator
	dependson(AbstractPlugin);

var string ModName;    // Used for mod info journal

var bool IsPluginsLoaded;

// Lets mods add plugins for initialization. Plugins
// can be for the base game or expansion. ModStart will figure
// out the rest. This method replaces OnStart().
function OnLoad(PluginCollection Collection){} 

// Deprecated, but still supported for backwards compatibility.
// Only supports base campaign plugins.
function OnStart(CorePlayerController Core){}

// Overriden to intialize CoreMod. Currently empty,
// but don't want to forget that this exists
function InitMutator(string Options, out string ErrorMessage)
{
    super.InitMutator(Options, ErrorMessage);
}

function bool CheckReplacement(Actor Other)
{	
	TryLoadPlugins();	
	return super.CheckReplacement(Other);
}

// Mod plugins cannot be loaded until a player controller
// exists. Once it exists, a plugin can only be successfully
// loaded if it is compatible with the current game type:
// base campaign or expansion campaign.
private function TryLoadPlugins()
{
	local PlayerController Controller;
	
	if(!IsPluginsLoaded)
	{
		Controller = WorldInfo.Game.GetALocalPlayerController();

		if(Controller != none && CorePlayerController(Controller) != none)
		{
			IsPluginsLoaded = true; // Important for this to be first or there can be a race condition
			LoadModPluginsForBaseCampaign();
		}

		// TODO: Once SRVPlayerController becomes available call
		// if(Controller != none && CoreExpansionPlayerController(Controller) != none)
		// {
		//	  PlayerControllerExists = true;
		//	  OnStart(CoreExpansionPlayerController(Controller));
		// }

	}
}

private function LoadModPluginsForBaseCampaign()
{
	local PluginCollection Plugins;
	local Plugin Plugin;
	local ExpansionPlugin ExpansionPlugin;
	local AbstractPlugin AbstractPlugin;
	local CorePlayerController Core;
	local array<AbstractPlugin> IncompatiblePlugins;
	local string IncompatibleModName;
	local string PluginId;

	Core = CorePlayerController(WorldInfo.Game.GetALocalPlayerController());

	Plugins = new class'PluginCollection';

	OnLoad(Plugins); // Allow mod to add both base campaign and expansion plugins to collection

	// Only load base campaign plugins if the mod has strictly said it is compatible
	// or if no compatibility was declared
	if(IsCompatibleWithBaseCampaign())
	{
		foreach Plugins.BaseCampaignPlugins(Plugin)
		{
			TryPopulateModName(Plugin);
			Core.AddPlugin(Plugin);
		}

		// For backwards compatiblity only as OnStart() is deprecated
		// Duplicates  will be gracefully ignored by CorePlayerController
		OnStart(Core); 
	}
	else
	{
		foreach Plugins.BaseCampaignPlugins(Plugin)
		{
			IncompatiblePlugins.AddItem(Plugin);
		}
	}
	
	foreach Plugins.ExpansionPlugins(ExpansionPlugin)
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

		PluginId = AbstractPlugin.Id;

		if(AbstractPlugin.Id == "")
		{
			PluginId = "Unidentified Plugin";
		}

		IncompatibleModName = AbstractPlugin.ModName $ ": '" $ PluginId $ "'";

		Core.IncompatibleModPluginNames.AddItem(IncompatibleModName);
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