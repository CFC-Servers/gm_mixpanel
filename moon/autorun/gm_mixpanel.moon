import CRC from util

CreateConVar "mixpanel_token", "<empty>", FCVAR_REPLICATED, "Mixpanel project token"

playerIdentifierEvent = "Mixpanel_PlayerIdentifier"

if SERVER
    AddCSLuaFile "includes/modules/mixpanel.lua"
    AddCSLuaFile "gm_mixpanel/cl_mixpanel.lua"
    AddCSLuaFile "gm_mixpanel/cl_menu.lua"
    AddCSLuaFile "gm_mixpanel/base.lua"

    util.AddNetworkString playerIdentifierEvent
    net.Receive playerIdentifierEvent, (_, ply) ->
        net.Start playerIdentifierEvent
        net.WriteString CRC ply\IPAddress!
    net.Send ply

if CLIENT
    hook.Add "Think", playerIdentifierEvent, ->
        hook.Remove "Think", playerIdentifierEvent
        net.Start playerIdentifierEvent
    net.SendToServer!

    net.Receive playerIdentifierEvent, ->
        LocalPlayer!.mixpanelIdentifier = net.ReadString!
