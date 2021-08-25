local CRC
CRC = util.CRC
CreateConVar("mixpanel_token", "<empty>", FCVAR_REPLICATED, "Mixpanel project token")
local playerIdentifierEvent = "Mixpanel_PlayerIdentifier"
if SERVER then
  AddCSLuaFile("includes/modules/mixpanel.lua")
  AddCSLuaFile("gm_mixpanel/cl_mixpanel.lua")
  AddCSLuaFile("gm_mixpanel/base.lua")
  util.AddNetworkString(playerIdentifierEvent)
  net.Receive(playerIdentifierEvent, function(_, ply)
    net.Start(playerIdentifierEvent)
    net.WriteString(CRC(ply:IPAddress()))
    return net.Send(ply)
  end)
end
if CLIENT then
  hook.Add("Think", playerIdentifierEvent, function()
    hook.Remove("Think", playerIdentifierEvent)
    net.Start(playerIdentifierEvent)
    return net.SendToServer()
  end)
  return net.Receive(playerIdentifierEvent, function()
    LocalPlayer().mixpanelIdentifier = net.ReadString()
  end)
end
