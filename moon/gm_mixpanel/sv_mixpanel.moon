import CRC from util
MixpanelBase = include "gm_mixpanel/base.lua"

class MixpanelInterface extends MixpanelBase
    _getPlyIdentifiers: (ply) =>
        distinct_id: ply\SteamID64!
        ip: CRC ply\IPAddress!

    TrackEvent: (name, properties, reliable) =>
        properties.distinct_id = "server"
        @_trackEvent name, properties, reliable

    TrackPlyEvent: (name, ply, properties, reliable) =>
        Merge properties, @_getPlyIdentifiers ply
        @_trackEvent name, properties, reliable

export MixPanel = MixpanelInterface!
