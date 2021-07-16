import Merge from table
MixpanelBase = include "gm_mixpanel/base.lua"

optOut = CreateClientConVar "mixpanel_opt_out", 0, true, true, "", 0, 1
include "gm_mixpanel/cl_menu.lua"

class MixpanelInterface extends MixpanelBase
    getIdentifiers = -> {
        distinct_id: LocalPlayer!\SteamID64!
        ip: LocalPlayer!.mixpanelIdentifier
    }

    TrackEvent: (name, properties={}, reliable=false) =>
        return if optOut\GetBool!

        Merge properties, getIdentifiers!
        @_trackEvent name, properties, reliable

export Mixpanel = MixpanelInterface!
