
// TODO: Extend class SRVPlayerController
// once the source file is included with game
class CoreSrvPlayerController extends Object;

var array<SrvPlugin> Plugins;

function AddPlugin(SrvPlugin Plugin)
{
    Plugin.Core = self;
    Plugins.AddItem(Plugin);
}

// TODO: Create hooks for SrvPlugins to use
// Can't add any until the source file for SRVPlayerController
// is included with game