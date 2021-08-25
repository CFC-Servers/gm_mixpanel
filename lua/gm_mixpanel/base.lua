require("logger")
local Post
Post = http.Post
local insert
insert = table.insert
local TableToJSON
TableToJSON = util.TableToJSON
local rawset, SysTime, tostring
do
  local _obj_0 = _G
  rawset, SysTime, tostring = _obj_0.rawset, _obj_0.SysTime, _obj_0.tostring
end
local timerExists = timer.Exists
local TOKEN = CreateConVar("mixpanel_token", "", FCVAR_REPLICATED)
local getToken
getToken = function()
  return TOKEN:GetString()
end
local START_TIME = os.time()
local getTimestamp
getTimestamp = function()
  return tostring(START_TIME + SysTime())
end
local MixpanelBase
do
  local _class_0
  local _base_0 = {
    _clearQueue = function(self)
      local queueSize = #self.eventQueue
      for i = 1, queueSize do
        rawset(self.eventQueue, i, nil)
      end
    end,
    _sendEventData = function(self, data)
      local eventCount = #data == 0 and 1 or #data
      local formattedData = {
        data = TableToJSON(data),
        verbose = tostring(self.VERBOSE and 1 or 0)
      }
      local onSuccess
      onSuccess = function(respBody, size, respHeaders, code)
        return self.Logger:debug("Successfully tracked " .. tostring(eventCount) .. " event(s)")
      end
      local onFailure
      onFailure = function(...)
        return self.Logger:error("Failed to track " .. tostring(eventCount) .. " event(s)!", data, ...)
      end
      return Post(self.trackUrl, formattedData, onSuccess, onFailure, self.headers)
    end,
    _sendQueue = function(self)
      local queueSize = #self.eventQueue
      if not (queueSize > 0) then
        return 
      end
      self.Logger:debug("Sending queue (" .. tostring(queueSize) .. " events)")
      self:_sendEventData(self.eventQueue)
      return self:_clearQueue()
    end,
    _queueEvent = function(self, event)
      insert(self.eventQueue, event)
      if #self.eventQueue > self.MAX_QUEUE_SIZE then
        return self:_sendQueue()
      end
    end,
    _startQueueGroomer = function(self)
      return timer.Create(self.queueTimer, 1, 0, function()
        return pcall(function()
          return self:_sendQueue()
        end)
      end)
    end,
    _trackEvent = function(self, eventName, eventProperties, reliable)
      if reliable == nil then
        reliable = false
      end
      if not (timerExists(self.queueTimer)) then
        self:_startQueueGroomer()
      end
      eventProperties.token = getToken()
      eventProperties.time = getTimestamp()
      local data = {
        event = eventName,
        properties = eventProperties
      }
      if reliable then
        return self:_sendEventData(data)
      end
      return self:_queueEvent(data)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      local _logger
      _logger = function(self, ...)
        return print("[Mixpanel]", ...)
      end
      self.Logger = Logger and Logger("Mixpanel") or {
        debug = _logger,
        info = _logger,
        error = function(self, ...)
          return error(...)
        end
      }
      self.VERBOSE = true
      self.trackUrl = "http://api.mixpanel.com/track"
      self.queueTimer = "Mixpanel_QueueGroomer"
      self.headers = {
        ["Accept"] = "text/plain",
        ["Content-Type"] = "application/x-www-form-urlencoded"
      }
      self.MAX_QUEUE_SIZE = 50
      self.eventQueue = { }
    end,
    __base = _base_0,
    __name = "MixpanelBase"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  MixpanelBase = _class_0
  return _class_0
end
