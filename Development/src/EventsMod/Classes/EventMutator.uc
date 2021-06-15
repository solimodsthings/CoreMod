// [Events Mod for Himeko Sutori (2021)]

// This mutator class is meant for other mods to extend
// as their mutator so they can register EventListeners.
//
// The mutator used for the Events Mod is EventsModStart.
class EventMutator extends Mutator;

var bool PlayerControllerExists;

function OnEventManagerCreated(EventManager Manager)
{
    // Other mods should override this function to add heir listeners here
}

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
			OnEventManagerCreated(EventManager(WorldInfo.Game.GetALocalPlayerController()));
		}
	}

	return super.CheckReplacement(Other);
}

DefaultProperties
{
    PlayerControllerExists = false
}