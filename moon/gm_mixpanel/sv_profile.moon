import CRC from util
timerExists = timer.Exists
MixpanelBase = include "gm_mixpanel/base.lua"

class MixpanelProfileInterface extends MixpanelBase
    new: =>
        super!
        @trackUrl = "http://api.mixpanel.com/engage"
        @queueTimer = "Mixpanel_ProfileQueueGroomer"

    _getPlyIdentifiers: (ply) => {
        distinct_id: ply\SteamID64!
        ip: CRC ply\IPAddress!
    }

    _trackEvent: => error "Not Implemented!"

    _trackProfile: (plyData) =>
        @_startQueueGroomer! unless timerExists @queueTimer

        plyData.token = @_getToken!
        plyData.time = @_getTimestamp!

        @_queueEvent data

    MakeProfile: (ply) =>
        return if ply\GetInfoNum("mixpanel_opt_out", 0) == 1

        data = @_getPlyIdentifiers ply
        @_trackProfile @_getPlyIdentifiers ply

profileInterface = MixpanelProfileInterface!

hook.Add "PlayerInitialSpawn", "Mixpanel_TrackProfile", (ply) ->
    profileInterface\MakeProfile ply
