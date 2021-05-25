require "cfclogger"
import insert, Merge from table
import CRC, TableToJSON from util

rawset = rawset
timerExists = timer.Exists
mixpanelToken = CreateConVar "mixpanel_token", "<empty>", FCVAR_REPLICATED, "Mixpanel project token"

class MixpanelInterface
    getToken: -> mixpanelToken:GetString!
    Logger = CFCLogger and CFCLogger("Mixpanel") or {
        debug: (...) => print ...,
        info: (...) => print ...,
        error: (...) => error ...
    }

    baseUrl: "https://api.mixpanel.com"
    batchTrackUrl: "#{@baseUrl}/track#past-events-batch"
    queueTimer: "Mixpanel_QueueGroomer"

    eventQueue: {}

    _clearQueue: () =>
        for i = 1, queueSize
            rawset @eventQueue, i, nil

    _sendQueue: () =>
        queueSize = #@eventQueue
        return unless queueSize > 0

        body = TableToJSON @eventQueue

        HTTP
            method: "POST",
            url: @batchTrackUrl,
            type: "application/json"
            body: body
            success: (code) -> @Logger\debug "Mixpanel issued event queue of size '#{queueSize}' with status code: '#{code}'", @eventQueue
            faied: (reason) -> @Logger\error "Mixpanel failed to send event queue of size '#{queueSize}' with reason: '#{reason}'", @eventQueue

    _queueEvent: (event) =>
        insert @eventQueue event

    _startQueueGroomer: () =>
        timer.Create @queueTimer, @queueInterval, 0, -> pcall -> @_sendQueue

    _trackEvent: (eventName, eventProperties) =>
        @_startQueueGroomer! unless timerExists @queueTimer

        eventProperties.token = @getToken!

        data =
            event: eventName,
            properties: eventProperties,
            ip: 0,
            verbose: 0,

        @_queueEvent data

    getPlyIdentifiers: (ply) =>
        {
            distinct_id: ply\SteamID64!
            ip: CRC ply\IPAddress!
        }

    trackPlyEvent: (eventName, ply, eventProperties) =>
        Merge eventProperties, @getPlyIdentifiers ply

        @_trackEvent eventName, eventProperties

    trackEvent: (eventName, identifier, eventProperties) =>
        eventProperties.distinct_id = identifier

        @_trackEvent eventName, eventProperties

export Mixpanel = MixpanelInterface!
