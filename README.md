# `More Markers`

This is an addon which provides the ability to place markers in the 3d world and share them to users, utilizing the official SPACE API instead of computationally heavy mathematics. This is similar to the addon Elms Markers, but offers a few improvements.

More Markers adds the ability to place fully customizable markers on the ground, quickly swap between "profiles" with various markers loaded, edit markers via the Built in Editor, share markers quickly with the rest of your group, and temporarily share where your cursor is looking with the rest of your group!

## `Detailed Features`
`(Why should you use this addon over "Elm's Markers" or Akamatsu's "Marker")`

### Increased Preformance
More Markers uses the official SPACE API created by Zenimax. This is a system which allows for greater flexibility and significantly better preformance than Ody Support Icons (and by extension Elms Markers), as Ody Support Icons does a lot of computationally heavy math every frame to place markers. This API also allows for the positioning of any UI element in the 3d world, not just textures.
In addition, the addon has a low RAM Consumption of a few megabytes for hundreds of icons.

### Editor
New in the 2.0 Update, More Markers provides an editor for your profiles which allow you to view and place/modify markers from a map view! This can be accessed by using the button in the settings, typing /mmshoweditor, or using the LibRadialMenu action!

### Greater Flexibility
More Markers supports custom text, colours, textures, and rotations for the markers in a profile. Currently markers are split into two "layers", which is the background image layer and the text layer.
Markers can contain full sentences within them, and is not limited by what textures the addon developer made. These text strings are rendered entirely using Zenimax's Fonts, so anything that ZOS supports rendering, this addon will also be able to render.
Markers are able to have a custom texture and colour for their image. Any texture that is built into the game, or provided with addons can be utilized by typing their path into the editbox. In addition, a full colour wheel is provided in addition to preset colours. This allows any combination of colours and textures, while staying lightweight and not using much resources.
Markers can be fully rotated in the 3d space or stay always facing the user. This can be used to create a lot of useful markers, such as flat text in the air or numbered ground positions. This is fully customizable when placing a marker.
Sizes can be specified for each marker, allowing for less important markers to be less visible.

### Compatibility with "Elms Markers" and Akamatsu's "Marker"
More Markers has full import compatibility with both Elm's Markers and Akamatsu's Marker, allowing users to import their old elms/marker strings and convert them into a More Markers profile. 
Currently, there is no export compatibility, due to the increased flexibility that More Markers provides. A future export compatibility is planned to be in development.

### Placement at Cursor
On PC, using the Quick Menu (/mmenu, or using the keybind) allows the user to place and remove markers where their cursor is currently pointing.
In addition, the place and remove buttons can be bound to a keybind!
On Console, this feature can be accessed by using LibRadialMenu and slotting the "Place at Reticle" action!

### Temporary Marker
Each player can send a temporary marker (lasting 5 seconds) to the rest of the group, indicating where they are looking at! This can be used to help guide tanks where to hold a boss or explain mechanics without requiring a full marker profile! This can be sent via a keybind, or a LibRadialMenu action.

### Profiles
This addon saves markers within account wide profiles, allowing users to quickly swap between profiles at the press of a buttom. Profiles also contain a last edited date, so you can see if you have the latest version of a shared profile loaded!
Additionally, multiple profiles can be loaded at once. This enables features like seperating boss markers from slayer markers in trash, or mechanic icons such as colours for Ansuul's maze.
With LibRadialMenu, users can also slot an action which allows them to quickly swap between profiles!

### Sharing
Created specifically for console, Raid Leads can now automatically share their currently loaded profile with all members of the group at the press of a button! This will allow members of the group to import markers sent by the raid lead, without needing to copy paste a string.
Similar to Elms Markers, profiles can still be shared via a string. When importing a string, users are given the choice to either overwrite or append the markers to their current profile.

### Premade Markers
This addon comes included with a few premade profiles for a majority of the trials, both custom made and converted from various Elms Markers. These will automatically be imported the first time you install the addon, or whenver you press the "Import Premade Markers" button in the settings menu. The trials with premade profiles are: vSS vOC vAS vRG vLC vKA vDSR vSE.

## `How to use the addon`
All of the detailed marker configuration controls can be found in the settings menu, including the Place and Remove buttons.
If you are on PC, you can also use the quick menu (/mmmenu) to place and remove markers without needing to open your settings. Markers can also be placed and removed with the /mmplace and /mmremove commands. In addition, keybinds can be set to open the quick menu or place/remove markers.
If you are using LibRadialMenu, the addon will add the following actions: Change Profiles, Open Editor, Open Settings, Place Marker, Place Marker at Reticle, Remove Marker, Send Temporary Marker at Reticle.

### Dependancies:
LibAddonMenu2

### Optional Dependancies:
LibGroupBroadcast (Required on Consoles)
LibRadialMenu (allows slotting quickslot actions like placing a marker, sending a temporary marker, or opening the editor)