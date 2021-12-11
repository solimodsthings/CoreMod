
// Convenience class. Base campaign and expansion
// plugins are added through calls to Add() and are
// automatically sorted into separate arrays.
//
// Used by ModStart to get plugins from mods and load
// them if they are compatible with the current PlayerController.
class PluginCollection extends Object;

var array<Plugin> BaseCampaignPlugins;
var array<ExpansionPlugin> ExpansionPlugins;

function Add(AbstractPlugin NewPlugin)
{
    if(Plugin(NewPlugin) != none)
    {
        BaseCampaignPlugins.AddItem(Plugin(NewPlugin));
    }
    else if(ExpansionPlugin(NewPlugin) != none)
    {
        ExpansionPlugins.AddItem(ExpansionPlugin(NewPlugin));
    }    
}

