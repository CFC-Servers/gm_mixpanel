if SERVER
    include "gm_mixpanel/sv_mixpanel.lua"
else
    include "gm_mixpanel/cl_mixpanel.lua"
