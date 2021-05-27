# Mixpanel Interface
mixpanel.com interface for Gmod

This library can be used in any existing addon, allowing you to track events and interactions with your addons.

This enables better understanding how users interact with your products, allowing you to make better, more impactful products.


## Requirements
 - [CFC Logger](https:/github.com/CFC-Servers/cfc_logger) _Optional, increases logging capability_


## Installation
Simply download a copy of the zip, or clone the repository straight into your addons folder! 

Pre-compiled versions are available in **[Releases](https://github.com/CFC-Servers/gm_mixpanel/releases/)**

The [`lua` branch](https://github.com/CFC-Servers/gm_mixpanel/tree/lua) is a lua-only branch containing the compiled code from the most recent release. One can use this to easily keep `gm_mixpanel` up to date.
```sh
git clone --single-branch --branch lua git@github.com:CFC-Servers/gm_mixpanel.git
```


# Usage
First, be sure to set the Mixpanel Token convar.

You can retrive your Mixpanel Project Token from your project's settings page.

Once you have it, set the following convar:
```
mixpanel_token "my token"
```

There are only two functions:
```lua
Mixpanel.TrackPlyEvent( eventName, ply, data, reliable)

Mixpanel.TrackEvent( eventName, identifier, data, reliable)
```


## Parameters

**`eventName`**
 - Both functions take an `eventName`, which you should be familiar with. It's anything you want.

**`ply`/`identifier`**
 - `TrackPlyEvent` takes a valid player entity and attaches their SteamID64 and a [CRC'd](https://wiki.facepunch.com/gmod/util.CRC) IP address to your event
 - `TrackEvent` simply takes an identifier (`string`) to attach to the event

**`data`**
 - The `data` parameter is a table of `string`->`string/int/boolean` describing any extra information about your event.
 - Defaults to `{}`, so you can omit it if no additional information is needed

**`reliable`**
 - The `reliable` flag determines whether or not the event is sent immediately (true), or queued up to be sent in the next batch request (false).
 - It's usually best to leave this as `false` (the default value) unless it's unacceptable for your event to be lost in the event of a server crash.


`TrackPlyEvent` is used to track an event relating to a player, whereas `TrackEvent` is a more flexible option.

Often, `TrackEvent` could be used on the server to track player-independent events. In our case, we pass `Server` as the identifier.


The usage is pretty simple. Here are some examples.

**Sends an event for every player chat**
```lua
-- sv_chat_tracker.lua
require( "mixpanel" )

hook.Add( "PlayerSay", "MixPanel_Example", function( ply, text, isTeam )
    local eventData = {
        text = text,
        isTeam = isTeam
    }

    Mixpanel.TrackPlyEvent( "Player Say", ply, eventData )
end )
```

**Sends an event when a player clicks on a vgui button**
```lua
-- cl_button.lua
-- For demonstration purposes only, probably not functional

local lbl = vgui.Create( "DLabel" )
lbl:SetText( "Create Team" )
lbl:SetMouseInputEnabled( true )

function lbl:DoClick()
    Mixpanel.TrackPlyEvent( "Create Team Clicked", LocalPlayer() )
    createTeam()
end
```
