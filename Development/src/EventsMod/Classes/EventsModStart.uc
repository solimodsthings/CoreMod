// [Events Mod for Himeko Sutori (2021)]

// Replaces the game's player controller with an observable one.
// Other mods can use this mod to listen for specific game events
// (eg. when a shop menu inventory item is refreshed) without needing
// to know the internal workings of the game.
class EventsModStart extends Mutator;

function InitMutator(string Options, out string ErrorMessage)
{
	WorldInfo.Game.PlayerControllerClass=class'EventManager';
	super.InitMutator(Options, ErrorMessage);
	`log("Mod loaded: Events Mod");
}
