require "cfclogger"
import insert, Merge from table
import CRC, TableToJSON from util

urlencode = include "gm_mixpanel/lib/urlencode.lua"

rawset = rawset
SysTime = SysTime
timerExists = timer.Exists

mixpanelToken = GetConVar "mixpanel_token"
getToken = -> mixpanelToken\GetString!

startTime = os.time!
getTimestamp = -> startTime + SysTime!

class MixpanelInterface
    _logger = (...) => print "[Mixpanel]", ...
    Logger = CFCLogger and CFCLogger("Mixpanel") or {
        debug: _logger,
        info: _logger,
        error: (...) => error ...
    }

    VERBOSE = true

    baseUrl = "https://api.mixpanel.com"
    trackUrl = "#{baseUrl}/track#live-event"
    batchTrackUrl = "#{baseUrl}/track#past-events-batch"
    queueTimer = "Mixpanel_QueueGroomer"
    headers = {
        "Accept": "text/plain",
        "Content-Type": "application/x-www-form-urlencoded"
    }

    eventQueue = {}

    _clearQueue = () ->
        queueSize = #eventQueue
        for i = 1, queueSize
            rawset eventQueue, i, nil

    _sendData = (url, data) ->
        dataSize = #data == 0 and 1 or #data

        jsonData = TableToJSON data
        formattedData = {
            data: jsonData,
            verbose: tostring(VERBOSE and 1 or 0)
        }

        body = urlencode.table formattedData

        onSuccess = (code, respBody, respHeaders) -> Logger\debug "Successfully tracked #{dataSize} event(s)", code, respBody, respHeaders
        onFailure = (...) -> Logger\error "Failed to track #{dataSize} event(s)!", data, ...

        requestHeaders = { "Content-Length": tostring #body }
        requestHeaders = Merge requestHeaders, headers

        with Logger
            \debug "Making request:"
            \debug "URL: ", url
            \debug "Formatted Data", formattedData
            \debug "Request Headers", requestHeaders
            \debug "Body", body

        HTTP
            success: onSuccess
            failed: onFailure
            method: "POST"
            url: url
            headers: requestHeaders
            body: body
            type: headers["Content-Type"]

    _sendQueue = ->
        Logger\debug "Checking queue"

        queueSize = #eventQueue
        return unless queueSize > 0

        Logger\debug "Sending queue (#{queueSize} events)"

        _sendData batchTrackUrl, eventQueue
        _clearQueue!

    _queueEvent = (event) ->
        insert eventQueue, event
        _sendQueue! if #eventQueue > 50

    _startQueueGroomer = () ->
        timer.Create queueTimer, 1, 0, -> _sendQueue!

    _trackEvent = (eventName, eventProperties, reliable=false) ->
        _startQueueGroomer! unless timerExists queueTimer

        eventProperties.token = getToken!
        eventProperties.time = getTimestamp!

        data =
            event: eventName,
            properties: eventProperties,

        if reliable
            return _sendData trackUrl, data

        _queueEvent data

    _getPlyIdentifiers = (ply) =>
        {
            distinct_id: ply\SteamID64!
            ip: CRC ply\IPAddress!
        }

    TrackPlayerEvent: (eventName, ply, eventProperties, reliable) ->
        Merge eventProperties, _getPlyIdentifiers ply

        _trackEvent eventName, eventProperties, reliable

    TrackEvent: (eventName, identifier, eventProperties, reliable) ->
        eventProperties.distinct_id = identifier

        _trackEvent eventName, eventProperties, reliable

export Mixpanel = MixpanelInterface!
