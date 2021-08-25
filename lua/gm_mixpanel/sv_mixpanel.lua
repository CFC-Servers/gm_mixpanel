local CRC
CRC = util.CRC
local Merge
Merge = table.Merge
local MixpanelBase = include("gm_mixpanel/base.lua")
local MixpanelInterface
do
  local _class_0
  local _parent_0 = MixpanelBase
  local _base_0 = {
    _getPlyIdentifiers = function(self, ply)
      return {
        distinct_id = ply:SteamID64(),
        ip = CRC(ply:IPAddress())
      }
    end,
    TrackEvent = function(self, name, properties, reliable)
      if properties == nil then
        properties = { }
      end
      if reliable == nil then
        reliable = false
      end
      properties.distinct_id = "server"
      return self:_trackEvent(name, properties, reliable)
    end,
    TrackPlyEvent = function(self, name, ply, properties, reliable)
      if properties == nil then
        properties = { }
      end
      if reliable == nil then
        reliable = false
      end
      Merge(properties, self:_getPlyIdentifiers(ply))
      return self:_trackEvent(name, properties, reliable)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "MixpanelInterface",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  MixpanelInterface = _class_0
end
Mixpanel = MixpanelInterface()
