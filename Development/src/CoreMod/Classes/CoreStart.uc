// [Core Mod for Himeko Sutori (2021)]

// Replaces the game's base player controller RPGTacPlayerController
// with core mod's CorePlayerController. CorePlayerController allows
// other mutator mods to add Plugins and respond to specific game events
// without needing to know the internal workings of a game.
class CoreStart extends Mutator;

function InitMutator(string Options, out string ErrorMessage)
{
	if(WorldInfo.Game.PlayerControllerClass == class'RPGTacPlayerController')
	{
		WorldInfo.Game.PlayerControllerClass=class'CorePlayerController';
		`log("Base campaign detected. Loading compatible mods...");
		`log("Mod loaded: Core Mod");
	}
	else // TODO: Compare WorldInfo.Game.PlayerControllerClass against class'SRVPlayerController' once it is available
	{
		// TODO: Set player controller class to CoreSrvPlayerController like so:
		// WorldInfo.Game.PlayerControllerClass=class'CoreSrvPlayerController';
		`log("Core Mod was not loaded because it encountered a PlayerController class that was not 'RPGTacPlayerController'. The likely cause is that the expansion campaign was loaded, which Core Mod does not support *yet*.");
		`log("Player controller was '" $ WorldInfo.Game.PlayerControllerClass $ "'.");
	}

	super.InitMutator(Options, ErrorMessage);
}
