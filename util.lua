local MM = M0RMarkers

ESO_Dialogs["M0RMarkerConfirmDialogue"] = {
	canQueue = true,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	buttons = { { text = "Yes",callback = function(dialogue)
		dialogue.data.yesCallback()
	end}, { text = "No", callback = function(dialogue)
		if dialogue.data.noCallback then dialogue.data.noCallback() end
	end} },
}


function MM.ShowDialogue(title, description, warning, callback, noCallback)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerConfirmDialogue", {yesCallback = callback, noCallback = noCallback}, {
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
								if LibHarvensAddonSettings and LibHarvensAddonSettings.list then
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













local fontFaceOptions = {
	["GAMEPAD_BOLD_FONT"] = "Bold",
	["GAMEPAD_MEDIUM_FONT"] = "Medium",
	["GAMEPAD_LIGHT_FONT"] = "Light",
	["GAMEPAD_MEDIUM_FONT_LATIN"] = "Latin",
	["ANTIQUE_FONT"] = "Antique",
	["HANDWRITTEN_FONT"] = "Handwritten",
	["STONE_TABLET_FONT"] = "Stone Tablet",
}
local fontEffectOptions = {
	["|thick-outline"] = "Thick Outline",
	["|soft-shadow-thick"] = "Soft Shadow Thick",
	["|soft-shadow-thin"] = "Soft Shadow Thin",
	[""] = "No Effect" -- none
}


local selectionType = {
	["fontFace"] = fontFaceOptions,
	["fontEffect"] = fontEffectOptions
}







local function SetupFontFace(dialog)
	local fontType = dialog.data.fontType
	local currentFontFace = MM.vars.fontface or "GAMEPAD_BOLD_FONT"
	local currentFontEffect = MM.vars.fonteffect or "|thick-outline"

	local iteratingList = selectionType[fontType]


	dialog.info.parametricList = {}
	local template = "ZO_GamepadSubMenuEntryWithStatusTemplate"

	for fontIterator,text in pairs(iteratingList) do
		local entryData = ZO_GamepadEntryData:New(text)
		entryData:SetFontScaleOnSelection(false)
		entryData:SetIconTintOnSelection(true)
		entryData.fontface = (fontType == "fontFace") and fontIterator or currentFontFace
		entryData.fonteffect = (fontType == "fontEffect") and fontIterator or currentFontEffect
		entryData.setup = function(control, data, ...)
			SetupProfileItem(control, data, ...)
			control:GetNamedChild("Label"):SetFont(string.format("$(%s)|34%s", data.fontface, data.fonteffect))
		end
		entryData.name = text
		entryData.isActive = (currentFontFace == fontIterator) or (currentFontEffect == fontIterator)

		local listItem = {
			template = template,
			entryData = entryData,
		}
		table.insert(dialog.info.parametricList, listItem)
	end
	dialog:setupFunc()
	dialog.entryList:SetSelectedDataByEval(IsSelected)
end

ESO_Dialogs["M0RMarkerFontSelect"] = {
	canQueue = true,
	gamepadInfo = {
		dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
	},
	setup = SetupFontFace,
	title = {
		text = "Select your desired font!",
	},
	buttons = {
		{
			text = SI_GAMEPAD_SELECT_OPTION,
			callback =  function(dialog)
							local data = dialog.entryList:GetTargetData()
							if data.fontface and data.fonteffect then
								MM.vars.fontface = data.fontface or "GAMEPAD_BOLD_FONT"
								MM.vars.fonteffect = data.fonteffect or "|thick-outline"
								for i,v in pairs(dialog.entryList.dataIndexToControl) do -- revert back to normal font
									v.label:SetFont("ZoFontGamepad34")
								end
							end
						end,
		},
		{
			text = SI_DIALOG_EXIT,
		},
	},
}



function MM.ShowFontSelect(fontType)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerFontSelect", {fontType = fontType})
end




















local function SetupEditorMapSelect(dialog)
	local currentMapId = M0RMarkers.editorTileManager.mapid
	local currentZone = GetUnitRawWorldPosition('player')
	local currentZoneLookup = M0RMarkers.mapZoneLookup[currentZone]

	dialog.info.parametricList = {}
	local template = "ZO_GamepadSubMenuEntryWithStatusTemplate"

	if currentZoneLookup then
		for i,v in pairs(currentZoneLookup) do
			local stringName = string.format(tostring(v).." ("..tostring(i)..")")

			local entryData = ZO_GamepadEntryData:New(stringName)
			entryData:SetFontScaleOnSelection(false)
			entryData:SetIconTintOnSelection(true)
			entryData.setup = SetupProfileItem
			entryData.name = stringName
			entryData.mapId = i
			entryData.isActive = i == currentMapId

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
end

ESO_Dialogs["M0RMarkerEditorMapSelect"] = {
	canQueue = true,
	gamepadInfo = {
		dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
	},
	setup = SetupEditorMapSelect,
	title =
	{
		text = "Select the Zone Map!",
	},
	buttons =
	{
		{
			text = SI_GAMEPAD_SELECT_OPTION,
			callback =  function(dialog)
							local data = dialog.entryList:GetTargetData()
							--d("Trying to load: ".. data.name)
							if data.mapId and M0RMarkers.editorTileManager then
								--d("Loading: ".. data.mapId)
								M0RMarkers.editorTileManager:SetMapId(data.mapId)
							end
						end,
		},
		{
			text = SI_DIALOG_EXIT,
		},
	},
}



function MM.ShowEditorMapSelect()
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerEditorMapSelect")
end









if not IsConsoleUI() then
	MM.highlightAnimationProvider = ZO_ReversibleAnimationProvider:New("ShowOnMouseOverLabelAnimation")

	local g_listDialog
	local function getKBProfileListDialog()
	    if not g_listDialog then
	        local function SetupItemRow(rowControl, slotInfo)
				local nameControl = rowControl:GetNamedChild("Name")
                nameControl:SetText(slotInfo.name)
                --rowControl:GetNamedChild("Selected"):SetHidden(slotInfo.name ~= MM.vars.loadedProfile[currentZone])
                --g_listDialog:GetSelectedItem() ~= slotInfo
                rowControl:GetNamedChild("Selected"):SetHidden(g_listDialog:GetSelectedItem() ~= slotInfo)
                if g_listDialog:GetSelectedItem() then
                    g_listDialog:SetFirstButtonEnabled(true)
                end
            end
	        g_listDialog = ZO_ListDialog:New("M0RMarkerProfileSelectDialogItemTemplate", 52, SetupItemRow)

	    end

	    g_listDialog:SetFirstButtonEnabled(false)
	    return g_listDialog
	end



	local function SetupDialog()
	    local listDialog = getKBProfileListDialog()

	    listDialog:SetAboveText()
	    listDialog:SetBelowText("Only profiles for the active zone can be seleted.")
	    listDialog:SetEmptyListText()

	    listDialog:ClearList()

	    local itemList = M0RMarkers.getCurrentZoneProfiles()
	    table.sort(itemList)
	    for index, name in ipairs(itemList) do
	        listDialog:AddListItem({name=name})
	    end

		local currentZone = GetUnitRawWorldPosition('player')
		--e = listDialog
	    for i,v in pairs(ZO_ScrollList_GetDataList(listDialog.list)) do
	    	--d(v.data.name)
	    	if (v.data.name ~= nil) and (v.data.name == MM.vars.loadedProfile[currentZone]) then
	    		--d("Found it")
	    		ZO_ScrollList_SelectData(listDialog.list, v.data)
	    		--ZO_Scroll_ScrollControlIntoCentralView
	    	end
		end
		--g = ZO_ScrollList_GetSelectedData(listDialog.list)
		--f = ZO_ScrollList_GetSelectedControl(listDialog.list)


	    --if slotInfo.name == MM.vars.loadedProfile[currentZone] then
        --	
        --end

	    listDialog:CommitList()
	end

	ZO_Dialogs_RegisterCustomDialog("M0RMarkerPCProfileSelect",
	    {
	        customControl = function() return getKBProfileListDialog():GetControl() end,
	        setup = function(dialog, data) SetupDialog() end,

	        title =
	        {
	            text = "Select your Profile",
	        },        
	        buttons =
	        {
	            {
	                control = getKBProfileListDialog():GetButton(1),
	                text = SI_GAMEPAD_SELECT_OPTION,
	                --clickSound = SOUNDS.INVENTORY_ITEM_REPAIR,
	                callback = function()
	                	local name = getKBProfileListDialog():GetSelectedItem().name
	                	if not name then return end
	                	MM.currentLoadProfileName = name
						MM.loadProfile(name)
	                end,
	            },

	            {
	                control = getKBProfileListDialog():GetButton(2),
	                text = SI_DIALOG_EXIT,
	            }
	        }
	    })

end









if IsConsoleUI() then

	local listofdialogs = {
		"M0RMarkerConfirmDialogue",
		"M0RMarkerNotice",
		"M0RMarkerEditDialogue",
		"M0RMarkerProfileSelect",
		"M0RMarkerProfileSelectMulti",
		"M0RMarkerEditBox",
		"M0RMarkerFontSelect",
		"M0RMarkerEditorMapSelect"
	}

	local function dialogHook(dialog, pressState, callback)
        if callback then
            callback(dialog, pressState)
        end
        if(dialog and not dialog.info.blockDialogReleaseOnPress) then
            ZO_Dialogs_ReleaseDialogOnButtonPress(dialog.name)
        end
	end

	for i,v in pairs(listofdialogs) do
		local currentDialogue = ESO_Dialogs[v]
		local oldButtons = ZO_DeepTableCopy(currentDialogue.buttons)

		for k,button in ipairs(oldButtons) do
			if type(button.text) == "number" then
				button.name = GetString(button.text)
			else
				button.name = button.text
			end

		    if not button.keybind then
		        if k == 1 then
		            button.keybind = "DIALOG_PRIMARY"
		        elseif k == 2 then
		            button.keybind = "DIALOG_NEGATIVE"
		        end
		    end
		    if not button.alignment then
		    	button.alignment = KEYBIND_STRIP_ALIGN_LEFT
		    end
		end

	    currentDialogue.buttons = nil
	    currentDialogue.OnShownCallback = function(dialog)

		    for k,button in pairs(oldButtons) do
		    	local oldCallback = button.callback
				button.callback = function(pressState) dialogHook(dialog, pressState, oldCallback) end
			end

	        local g_keybindState = KEYBIND_STRIP:GetTopKeybindStateIndex()
	        KEYBIND_STRIP:AddKeybindButtonGroup(oldButtons, g_keybindState)
	    end
	end
end