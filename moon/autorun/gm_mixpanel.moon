AddCSLuaFile "includes/modules/mixpanel.lua"
CreateConVar "mixpanel_token", "<empty>", FCVAR_REPLICATED, "Mixpanel project token"

playerIdentifierEvent = "MixPanel_PlayerIdentifier"

if SERVER
    util.AddNetworkString playerIdentifierEvent
    net.Receive playerIdentifierEvent, (_, ply) ->
        net.Start playerIdentifierEvent
        net.WriteString CFC ply\IPAddress!
        net.Send ply

if CLIENT
    hook.Add "Think", playerIdentifierEvent, ->
        hook.Remove "Think", playerIdentifierEvent
        net.Start playerIdentifierEvent
        net.SendToServer!

    net.Receive playerIdentifierEvent, ->
        LocalPlayer!.mixpanelIdentifier = net.ReadString!
