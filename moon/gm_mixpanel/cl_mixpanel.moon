MixpanelBase = include "gm_mixpanel/base.lua"

class MixpanelInterface extends MixpanelBase
    getIdentifiers = -> {
        distinct_id: LocalPlayer!\SteamID64!
        ip: LocalPlayer!.mixpanelIdentifier
    }

    TrackEvent: (name, properties, reliable) =>
        Merge properties, getIdentifiers!

        @_trackEvent name, properties, reliable

export MixPanel = MixpanelInterface!
