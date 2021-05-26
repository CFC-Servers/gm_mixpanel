require "cfclogger"
import insert, Merge from table
import CRC, TableToJSON from util

rawset = rawset
SysTime = SysTime
timerExists = timer.Exists

mixpanelToken = CreateConVar "mixpanel_token", "<empty>", FCVAR_REPLICATED, "Mixpanel project token"

startTime = os.time!
getTimestamp = -> startTime + SysTime!

class MixpanelInterface
    getToken: -> mixpanelToken\GetString!

    _logger = (...) => print "[Mixpanel]", ...
    Logger = CFCLogger and CFCLogger("Mixpanel") or {
        debug: _logger,
        info: _logger,
        error: (...) => error ...
    }

    baseUrl: "https://api.mixpanel.com"
    trackUrl: "#{@baseUrl}/track#live-event"
    batchTrackUrl: "#{@baseUrl}/track#past-events-batch"
    queueTimer: "Mixpanel_QueueGroomer"

    eventQueue: {}

    _clearQueue: () =>
        queueSize = #@eventQueue
        for i = 1, queueSize
            rawset @eventQueue, i, nil

    _sendData: (url, data) =>
        dataSize = #data
        formattedData = TableToJSON data

        HTTP
            method: "POST",
            url: url,
            type: "application/x-www-form-urlencoded"
            parameters:
                data: formattedData
            success: (code) -> @Logger\debug "Successfully tracked #{dataSize} event(s)"
            failed: (reason) -> @Logger\error "Failed to track #{dataSize} event(s)!", data, formattedData

    _sendQueue: () =>
        queueSize = #@eventQueue
        return unless queueSize > 0

        @_sendData @batchTrackUrl, @eventQueue

    _queueEvent: (event) =>
        insert @eventQueue event
        @_sendQueue! if #@eventQueue > 50

    _startQueueGroomer: () =>
        timer.Create @queueTimer, @queueInterval, 0, -> pcall -> @_sendQueue!

    _trackEvent: (eventName, eventProperties, reliable) =>
        @_startQueueGroomer! unless timerExists @queueTimer

        eventProperties.token = @getToken!
        eventProperties.time = getTimestamp!

        data =
            event: eventName,
            properties: eventProperties,

        if reliable
            return @_sendData @trackUrl, data

        @_queueEvent data

    getPlyIdentifiers: (ply) =>
        {
            distinct_id: ply\SteamID64!
            ip: CRC ply\IPAddress!
        }

    TrackPlayerEvent: (eventName, ply, eventProperties, reliable=false) =>
        Merge eventProperties, @getPlyIdentifiers ply

        @_trackEvent eventName, eventProperties, reliable

    TrackEvent: (eventName, identifier, eventProperties, reliable=false) =>
        eventProperties.distinct_id = identifier

        @_trackEvent eventName, eventProperties, reliable

export Mixpanel = MixpanelInterface!
