
// TODO: Extend class SRVPlayerController
// once the source file is included with game
class CoreExpansionPlayerController extends Object;

var array<ExpansionPlugin> Plugins;

function AddPlugin(ExpansionPlugin Plugin)
{
    Plugin.Core = self;
    Plugins.AddItem(Plugin);
}

// TODO: Create hooks for SrvPlugins to use
// Can't add any until the source file for SRVPlayerController
// is included with game