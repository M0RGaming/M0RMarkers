local MM = M0RMarkers

ESO_Dialogs["M0RMarkerConfirmDialogue"] = {
	canQueue = false,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	buttons = { { text = "Yes", callback = function(dialogue)
		dialogue.data.yesCallback()
		a = dialogue
	end }, { text = "No" } },
}


function MM.ShowDialogue(title, description, warning, callback)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerConfirmDialogue", {yesCallback = callback}, {
		titleParams = {title or ""},
		mainTextParams = {description or ""},
		warningParams = {warning or ""}
	})
end





local CHECKED_ICON = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds"

local function IsSelected(data)
    return data.isActive
end

local function SetupProfileItem(control, data, ...)
    ZO_SharedGamepadEntry_OnSetup(control, data, ...)

    if IsSelected(data) then
        control.statusIndicator:AddIcon(CHECKED_ICON)
        control.statusIndicator:Show()
    end
end

local function SetupProfiles(dialog)
	local profiles = M0RMarkers.getCurrentZoneProfiles()
	dialog.info.parametricList = {}
	local template = "ZO_GamepadSubMenuEntryWithStatusTemplate"

	local currentZone = GetUnitRawWorldPosition('player')
	local currentProfileName = MM.vars.loadedProfile[currentZone] or "Default"



	for i,v in pairs(profiles) do
		local entryData = ZO_GamepadEntryData:New(v, icon)
        entryData:SetFontScaleOnSelection(false)
        entryData:SetIconTintOnSelection(true)
        entryData.setup = SetupProfileItem
        entryData.name = v
        entryData.isActive = v == currentProfileName

        local listItem = 
        {
            template = template,
            entryData = entryData,
        }
        table.insert(dialog.info.parametricList, listItem)
	end
	dialog:setupFunc()
    dialog.entryList:SetSelectedDataByEval(IsSelected)
end

ESO_Dialogs["M0RMarkerProfileSelect"] =
{
    gamepadInfo =
    {
        dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
    },
    setup = SetupProfiles,
    title =
    {
        text = "Select your Profile",
    },
    buttons =
    {
        {
            text = SI_GAMEPAD_SELECT_OPTION,
            callback =  function(dialog)
                            local data = dialog.entryList:GetTargetData()
                            --d("Trying to load: ".. data.name)
                            if data.name then
                            	--d("Loading: ".. data.name)
                            	MM.currentLoadProfileName = data.name
                            	MM.loadProfile(data.name)
                            end
                        end,
        },
        {
            text = SI_DIALOG_EXIT,
        },
    },
}



function MM.ShowProfileSelect()
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerProfileSelect")
end