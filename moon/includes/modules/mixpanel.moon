require "cfclogger"
import insert, Merge from table
import CRC, TableToJSON from util

rawset = rawset
mixpanelToken = CreateConVar "mixpanel_token", "<empty>", FCVAR_REPLICATED, "Mixpanel project token"

class MixpanelInterface
    token: mixpanelToken:GetString!
    Logger = CFCLogger and CFCLogger("Mixpanel") or {
        debug: (...) => print ...,
        info: (...) => print ...,
        error: (...) => error ...
    }

    baseUrl: "https://api.mixpanel.com"
    trackUrl: "#{@baseUrl}/track#live-event"
    batchTrackUrl: "#{@baseUrl}/track#past-events-batch"

    eventQueue: {}

    _sendQueue: () =>
        body = TableToJSON @eventQueue
        queueSize = #@eventQueue

        HTTP
            method: "POST",
            url: @batchTrackUrl,
            type: "application/json"
            body: body
            success: (code) -> @Logger\debug "Mixpanel issued event queue of size '#{queueSize}' with status code: '#{code}'", @eventQueue
            faied: (reason) -> @Logger\error "Mixpanel failed to send event queue of size '#{queueSize}' with reason: '#{reason}'", @eventQueue

        for i = 1, queueSize
            rawset @eventQueue, i, nil

    _queueEvent: (event) =>
        insert @eventQueue event

    _trackEvent: (eventName, eventProperties) =>
        eventProperties.token = @token

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
