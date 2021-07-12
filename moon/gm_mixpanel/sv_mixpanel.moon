import CRC from util
import Merge from table
MixpanelBase = include "gm_mixpanel/base.lua"

class MixpanelInterface extends MixpanelBase
    _getPlyIdentifiers: (ply) => {
        distinct_id: ply\SteamID64!
        ip: CRC ply\IPAddress!
    }

    TrackEvent: (name, properties={}, reliable=false) =>
        properties.distinct_id = "server"
        @_trackEvent name, properties, reliable

    TrackPlyEvent: (name, ply, properties={}, reliable=false) =>
        Merge properties, @_getPlyIdentifiers ply
        @_trackEvent name, properties, reliable

export Mix = MixpanelInterface!
