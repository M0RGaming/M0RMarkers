local MM = M0RMarkers

ESO_Dialogs["M0RMarkerConfirmDialogue"] = {
	canQueue = true,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	buttons = { { text = "Yes", callback = function(dialogue)
		dialogue.data.yesCallback()
	end }, { text = "No" } },
}


function MM.ShowDialogue(title, description, warning, callback)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerConfirmDialogue", {yesCallback = callback}, {
		titleParams = {title or ""},
		mainTextParams = {description or ""},
		warningParams = {warning or ""}
	})
end


ESO_Dialogs["M0RMarkerNotice"] = {
	canQueue = true,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	buttons = { { text = "OK" } },
}


function MM.ShowNotice(title, description, warning)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerNotice", {}, {
		titleParams = {title or ""},
		mainTextParams = {description or ""},
		warningParams = {warning or ""}
	})
end



ESO_Dialogs["M0RMarkerEditDialogue"] = {
	canQueue = true,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	editBox = {},
	buttons = { { text = "Confirm", callback = function(dialogue)
		local message = ZO_Dialogs_GetEditBoxText(dialogue)
		dialogue.data.yesCallback(message)
	end }, { text = "Cancel" } },
}


function MM.ShowEditDialogue(title, description, warning, callback)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerEditDialogue", {yesCallback = callback}, {
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
	control.statusIndicator:AddIcon(CHECKED_ICON)

	if IsSelected(data) then
		--control.statusIndicator:AddIcon(CHECKED_ICON)
		control.statusIndicator:Show()
	end
end

local function SetupProfiles(dialog, activeCriteria)
	local profiles = M0RMarkers.getCurrentZoneProfiles()
	dialog.info.parametricList = {}
	local template = "ZO_GamepadSubMenuEntryWithStatusTemplate"

	for i,v in pairs(profiles) do
		local entryData = ZO_GamepadEntryData:New(v)
		entryData:SetFontScaleOnSelection(false)
		entryData:SetIconTintOnSelection(true)
		entryData.setup = SetupProfileItem
		entryData.name = v
		entryData.isActive = activeCriteria(v)

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

ESO_Dialogs["M0RMarkerProfileSelect"] = {
	canQueue = true,
	gamepadInfo = {
		dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
	},
	setup = function(dialog)
		local currentZone = GetUnitRawWorldPosition('player')
		local currentProfileName = MM.vars.loadedProfile[currentZone] or "Default"

		SetupProfiles(dialog, function(itemName)
			return itemName == currentProfileName
		end)
	end,
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
								if LibHarvensAddonSettings.list then
									LibHarvensAddonSettings.list:RefreshVisible()
								end
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





ESO_Dialogs["M0RMarkerProfileSelectMulti"] = { -- TODO: Make this select all the currently loaded profiles
	canQueue = true,
	gamepadInfo = {
		dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
	},
	setup = function(dialog)
		local currentZone = GetUnitRawWorldPosition('player')
		local currentProfileName = MM.vars.loadedProfile[currentZone] or "Default"

		local currentlyLoaded = MM.currentAdditionalProfiles
		local profileLookup = {}
		for i,v in pairs(currentlyLoaded) do
			profileLookup[v] = true
		end

		SetupProfiles(dialog, function(itemName)
			return profileLookup[itemName] or false
		end)
	end,
	title = {
		text = "Select your Profile",
	},
	blockDialogReleaseOnPress = true,
	onHidingCallback = function(dialog)
		--a = dialog.entryList
		---[[
		local profilesToLoad = {}
		for i,v in pairs(dialog.entryList.dataList) do
			if v.isActive then
				--d(v.name)
				profilesToLoad[#profilesToLoad+1] = v.name
			end
		end
		MM.currentAdditionalProfiles = profilesToLoad
		MM.loadAdditionalProfiles(profilesToLoad)
		if LibHarvensAddonSettings.list then
			LibHarvensAddonSettings.list:RefreshVisible()
		end
		--]]
	end,
	buttons =
	{
		{
			text = SI_GAMEPAD_SELECT_OPTION,
			callback =  function(dialog)
				local data = dialog.entryList:GetTargetData()
				data.isActive = not data.isActive
				local control = dialog.entryList:GetTargetControl()
				control.statusIndicator:SetHidden(not data.isActive)
				--d("Trying to load: ".. data.name.. " and is now ".. tostring(data.isActive))
			end,
		},
		{
			text = SI_DIALOG_EXIT,
			callback = function()
				ZO_Dialogs_ReleaseDialogOnButtonPress("M0RMarkerProfileSelectMulti")
			end
		},
	},
}

--SLASH_COMMANDS['/mmopentest'] = function() ZO_Dialogs_ShowPlatformDialog("M0RMarkerProfileSelectMulti") end

function MM.ShowMultiProfileSelect()
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerProfileSelectMulti")
end

















ESO_Dialogs["M0RMarkerEditBox"] = {
	canQueue = true,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC, },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	setup = function(dialog) dialog:setupFunc() end,
	parametricList = {
		{
			template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
			templateData =
			{
				textChangedCallback = function(control)
					local comment = control:GetText()
					local dialog = ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC)
					dialog.data.selectedName = comment
				end,
				setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
					control.highlight:SetHidden(not selected)
					control.editBoxControl.textChangedCallback = data.textChangedCallback
					control.editBoxControl:SetMaxInputChars(1000)
					--control.editBoxControl:SetDefaultText(GetString(SI_EDIT_NOTE_DEFAULT_TEXT))
					data.control = control
					local dialog = ZO_GenericGamepadDialog_GetControl(GAMEPAD_DIALOGS.PARAMETRIC)
					if dialog.data.selectedName then
						control.editBoxControl:SetText(dialog.data.selectedName)
					end
				end,
				callback = function(dialog)
					local data = dialog.entryList:GetTargetData()
					local edit = data.control.editBoxControl

					edit:TakeFocus()
				end,
			},
		},
		{
			template = "ZO_GamepadTextFieldSubmitItem", -- ZO_GamepadFullWidthLeftLabelEntryTemplate
			templateData =
			{
				text = GetString(SI_GAMEPAD_CONTACTS_EDIT_NOTE_CONFIRM),
				setup = ZO_SharedGamepadEntry_OnSetup,
				callback = function(dialog)
					local name = dialog.data.selectedName
					dialog.data.textConfirmCallback(name)
					ZO_Dialogs_ReleaseDialogOnButtonPress("M0RMarkerEditBox")
				end,
			},
		}
	},
	blockDialogReleaseOnPress = true,
	buttons = {
		{
			text = SI_GAMEPAD_SELECT_OPTION,
			callback =  function(dialog)
				local targetData = dialog.entryList:GetTargetData()
				if(targetData and targetData.callback) then
					targetData.callback(dialog)
				end
			end,
		},
		{
			text = SI_DIALOG_EXIT,
			callback = function()
				ZO_Dialogs_ReleaseDialogOnButtonPress("M0RMarkerEditBox")
			end
		},
	},
}

--ZO_Dialogs_ShowPlatformDialog("M0RMarkerEditBox")

function MM.ShowGPEdit(title, description, warning, callback)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerEditBox", {textConfirmCallback = callback}, {
		titleParams = {title or "test"},
		mainTextParams = {description or "test"},
		warningParams = {warning or "test"}
	})
end

--SLASH_COMMANDS['/mmopentest'] = function() MM.ShowGPEdit("Test Title", "Test description", "test warning", function(name) d("Name callback: "..tostring(name)) end) end




