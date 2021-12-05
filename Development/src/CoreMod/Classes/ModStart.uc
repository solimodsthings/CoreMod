// [Core Mod for Himeko Sutori (2021)]

// This mutator class is meant for other mods to extend
// as their mutator so they can register their Plugins with
// the CorePlayerController through the OnStart() function.
class ModStart extends Mutator;

var bool PlayerControllerExists;

// For plugins of mods specific to the base campaign only
function OnStart(CorePlayerController Core){}

// For plugins of mods specific to the SRV campaign only
function OnSrvStart(CoreSrvPlayerController Core){}

function InitMutator(string Options, out string ErrorMessage)
{
    super.InitMutator(Options, ErrorMessage);
}

function bool CheckReplacement(Actor Other)
{
	local PlayerController Controller;

	if(!PlayerControllerExists)
	{
		Controller = WorldInfo.Game.GetALocalPlayerController();

		if(Controller != none && CorePlayerController(Controller) != none)
		{
			PlayerControllerExists = true;
			OnStart(CorePlayerController(Controller));
		}

		// TODO: Once SRVPlayerController becomes available call
		// if(Controller != none && CoreSrvPlayerController(Controller) != none)
		// {
		//	  PlayerControllerExists = true;
		//	  OnStart(CoreSrvPlayerController(Controller));
		// }
	}

	return super.CheckReplacement(Other);
}

DefaultProperties
{
    PlayerControllerExists = false
}