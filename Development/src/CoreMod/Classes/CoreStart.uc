// [Core Mod for Himeko Sutori (2021)]

// Replaces the game's base player controller RPGTacPlayerController
// with core mod's CorePlayerController. CorePlayerController allows
// other mutator mods to add Plugins and respond to specific game events
// without needing to know the internal workings of a game.
class CoreStart extends Mutator;

function InitMutator(string Options, out string ErrorMessage)
{
	WorldInfo.Game.PlayerControllerClass=class'CorePlayerController';
	super.InitMutator(Options, ErrorMessage);
	`log("Mod loaded: Core Mod");
}
