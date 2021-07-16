import AddToolCategory, AddToolMenuOption from spawnmenu
optOut = GetConVar "mixpanel_opt_out"

populatePanel = (panel) ->
    label = "Opt out of player telemetry"
    panel\CheckBox label, "mixpanel_opt_out"

hook.Add "AddToolMenuCategories", "Mixpanel_Menu_Category",  ->
    AddToolCategory "Options", "Telemetry", "Telemetry"

hook.Add "PopulateToolMenu", "CFC_Punt_MenuOption", ->
    AddToolMenuOption "Options", "Telemetry", "mixpanel_opt_out", "Telemetry", "", "", (panel) ->
        populatePanel panel
