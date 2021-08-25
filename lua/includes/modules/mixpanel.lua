if SERVER then
  return include("gm_mixpanel/sv_mixpanel.lua")
else
  return include("gm_mixpanel/cl_mixpanel.lua")
end
