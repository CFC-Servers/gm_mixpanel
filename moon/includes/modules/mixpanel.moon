require "cfclogger"

import Post from http
import insert, Merge from table
import CRC, TableToJSON from util
import rawset, SysTime, tostring from _G

timerExists = timer.Exists

TOKEN = GetConVar "mixpanel_token"
getToken = -> TOKEN\GetString!

START_TIME = os.time!
getTimestamp = -> tostring START_TIME + SysTime!

class MixpanelInterface
    _logger = (...) => print "[Mixpanel]", ...
    Logger = CFCLogger and CFCLogger("Mixpanel") or {
        debug: _logger,
        info: _logger,
        error: (...) => error ...
    }

    VERBOSE: true

    trackUrl = "http://api.mixpanel.com/track"
    queueTimer = "Mixpanel_QueueGroomer"
    headers = {
        "Accept": "text/plain",
        "Content-Type": "application/x-www-form-urlencoded"
    }

    -- Mixpanel implements a limit of 50 events per batch tracking call
    MAX_QUEUE_SIZE = 50
    eventQueue = {}

    _clearQueue = () ->
        queueSize = #eventQueue
        for i = 1, queueSize
            rawset eventQueue, i, nil

    _sendEventData = (data) ->
        -- Will be an event table if one event, and a table of tables if many
        eventCount = #data == 0 and 1 or #data

        formattedData =
            data: TableToJSON data
            verbose: tostring VERBOSE and 1 or 0

        onSuccess = (respBody, size, respHeaders, code) ->
            Logger\debug "Successfully tracked #{eventCount} event(s)", code, respBody, size, respHeaders
        onFailure = (...) ->
            Logger\error "Failed to track #{eventCount} event(s)!", data, ...

        Post trackUrl, formattedData, onSuccess, onFailure, headers

    _sendQueue = ->
        Logger\debug "Checking queue"

        queueSize = #eventQueue
        return unless queueSize > 0

        Logger\debug "Sending queue (#{queueSize} events)"

        _sendEventData eventQueue
        _clearQueue!

    _queueEvent = (event) ->
        insert eventQueue, event
        _sendQueue! if #eventQueue > MAX_QUEUE_SIZE

    _startQueueGroomer = () ->
        timer.Create queueTimer, 1, 0, -> _sendQueue!

    _trackEvent = (eventName, eventProperties, reliable=false) ->
        _startQueueGroomer! unless timerExists queueTimer

        eventProperties.token = getToken!
        eventProperties.time = getTimestamp!

        data =
            event: eventName,
            properties: eventProperties,

        return _sendEventData(data) if reliable

        _queueEvent data

    _getPlyIdentifiers = (ply) =>
        distinct_id: ply\SteamID64!
        ip: CRC ply\IPAddress!

    TrackPlayerEvent: (eventName, ply, eventProperties, reliable) ->
        Merge eventProperties, _getPlyIdentifiers ply

        _trackEvent eventName, eventProperties, reliable

    TrackEvent: (eventName, identifier, eventProperties, reliable) ->
        eventProperties.distinct_id = identifier

        _trackEvent eventName, eventProperties, reliable

export Mixpanel = MixpanelInterface!
