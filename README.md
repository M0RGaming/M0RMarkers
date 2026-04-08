# `More Markers`

This is an add-on that provides the ability to place markers in the 3D world and share them with users, utilizing the official SPACE API instead of computationally heavy mathematics. This is similar to the add-ons "Elm's Markers" and Akamatsu's "Marker" but offers a few improvements.

More Markers adds the ability to place fully customizable markers on the ground, quickly swap between "profiles" with various markers loaded, edit markers via the built-in editor, share markers quickly with the rest of your group, and temporarily share where your cursor is looking with the rest of your group!

## `Detailed Features`
`(Why should you use this addon over "Elm's Markers" or Akamatsu's "Marker")`

### Increased Performance
More Markers uses the official SPACE API created by Zenimax. This is a system that allows for greater flexibility and significantly better performance than Ody Support Icons (and by extension, Elms Markers/Akamatsu's Marker), as Ody Support Icons does a lot of computationally heavy math every frame to place markers. This API also allows for the positioning of any UI element in the 3D world, not just textures.
In addition, the add-on has a low RAM consumption of a few megabytes for hundreds of icons.

### Editor
New in the 2.0 update, More Markers provides an editor for your profiles, which allows you to view and place/modify markers from a map view! This can be accessed by using the button in the settings, typing /mmshoweditor, or using the LibRadialMenu action!

### Greater Flexibility
More Markers supports custom text, colours, textures, and rotations for the markers in a profile. Currently markers are split into two "layers," which are the background image layer and the text layer.
Markers can contain full sentences within them and are not limited by what textures the addon developer made. These text strings are rendered entirely using Zenimax's fonts, so anything that ZOS supports rendering, this add-on will also be able to render.
Markers are able to have a custom texture and colour for their image. Any texture that is built into the game or provided with add-ons can be utilized by typing their path into the edit box. In addition, a full colour wheel is provided in addition to preset colours. This allows any combination of colours and textures while staying lightweight and not using a lot of resources.
Markers can be fully rotated in the 3D space or stay always facing the user. This can be used to create a lot of useful markers, such as flat text in the air or numbered ground positions. This is fully customizable when placing a marker.
Sizes can be specified for each marker, allowing for less important markers to be less visible.

### Compatibility with "Elms Markers" and Akamatsu's "Marker"
More Markers has full import compatibility with both Elm's Markers and Akamatsu's Marker, allowing users to import their old Elms/Marker strings and convert them into a More Markers profile. 
Currently, there is no export compatibility due to the increased flexibility that More Markers provides. A future export compatibility is planned to be in development.

### Placement at Cursor
On PC, using the Quick Menu (/mmmenu or using the keybind) allows the user to place and remove markers where their cursor is currently pointing.
In addition, the place and remove buttons can be bound to a keybind.
On console, this feature can be accessed by using LibRadialMenu and slotting the "Place at Reticle" action!

### Temporary Marker
Each player can send a temporary marker (lasting 5 seconds) to the rest of the group, indicating where they are looking at! This can be used to help guide tanks where to hold a boss or explain mechanics without requiring a full marker profile! This can be sent via a keybind or a LibRadialMenu action.

### Profiles
This add-on saves markers within account-wide profiles, allowing users to quickly swap between profiles at the press of a button. Profiles also contain a last edited date, so you can see if you have the latest version of a shared profile loaded!
Additionally, multiple profiles can be loaded at once. This enables features like separating boss markers from slayer markers in trash or mechanic icons such as colours for Ansuul's maze.
With LibRadialMenu, users can also slot an action, which allows them to quickly swap between profiles!

### Sharing
Created specifically for consoles, Raid Leads can now automatically share their currently loaded profile with all members of the group at the press of a button! This will allow members of the group to import markers sent by the raid lead without needing to copy/paste a string.
Similar to Elms Markers, profiles can still be shared via a string. When importing a string, users are given the choice to either overwrite or append the markers to their current profile.

### Premade Markers
This add-on comes included with a few premade profiles for a majority of the trials, both custom-made and converted from various Elm's Markers strings. These will automatically be imported the first time you install the add-on, or whenever you press the "Import Premade Markers" button in the settings menu. The trials with premade profiles are vSS, vMoL, vOC, vAS, vRG, vLC, vKA, vDSR, vSE, and Opulent Ordeal.

## `How to use the addon`
All of the detailed marker configuration controls can be found in the settings menu, including the Place and Remove buttons.
If you are on PC, you can also use the quick menu (/mmmenu) to place and remove markers without needing to open your settings. Markers can also be placed and removed with the /mmplace and /mmremove commands. In addition, keybinds can be set to open the quick menu or place/remove markers.
If you are using LibRadialMenu, the add-on will add the following actions: Change Profiles, Open Editor, Open Settings, Place Marker, Place Marker at Reticle, Remove Marker, and Send Temporary Marker at Reticle.

### Dependancies:
LibAddonMenu2

### Optional Dependancies:
LibGroupBroadcast (Required on Consoles)
LibRadialMenu (allows slotting quick slot actions like placing a marker, sending a temporary marker, or opening the editor)