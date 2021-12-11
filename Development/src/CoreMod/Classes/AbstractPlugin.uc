
class AbstractPlugin extends Object;

// This needs to be defined by the plugin itself
// especially if there is a need to use Serialize() and Deserialize() later.
// This property is used to form the keyname for serialized listener data and
// also used as the name of mod when the ListMods command is used.
var string Id;

// If left blank, inherits value of ModStart's ModName
var string ModName;

var bool IsInitialized;