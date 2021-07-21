// [Core Mod for Himeko Sutori (2021)]

// This mutator class is meant for other mods to extend
// as their mutator so they can register their Plugins with
// the CorePlayerController through the OnStart() function.
class ModStart extends Mutator;

var bool PlayerControllerExists;

// Meant for other mods to override and add their plugins to
// CorePlayerCtonroller.
function OnStart(CorePlayerController Core){}

function InitMutator(string Options, out string ErrorMessage)
{
    super.InitMutator(Options, ErrorMessage);
}

function bool CheckReplacement(Actor Other)
{
	if(!PlayerControllerExists)
	{
		if(WorldInfo.Game.GetALocalPlayerController() != none)
		{
			PlayerControllerExists = true;
			OnStart(CorePlayerController(WorldInfo.Game.GetALocalPlayerController()));
		}
	}

	return super.CheckReplacement(Other);
}

DefaultProperties
{
    PlayerControllerExists = false
}