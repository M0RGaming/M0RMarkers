local MM = M0RMarkers
MM.Settings = {}
local settings = MM.Settings
local print = MM.print


settings.colourPresets = {
	"|cffffffWhite|r", -- 1,1,1,1
	"|c0000ffBlue|r", -- 0, 0, 1, 1
	"|c00ff00Green|r", -- 0, 1, 0, 1
	"|cff8000Orange|r", -- 1, 0.5, 0, 1
	"|cff00e6Pink|r", -- 1, 0, 0.9, 1
	"|cff0000Red|r", -- 1, 0, 0, 1
	"|cffcc00Yellow|r", -- 1, 0.8, 0, 1
	"|c00ffa6Lime Green|r", -- 0, 1, 0.65, 1
}
local colourPresets = settings.colourPresets

settings.colourLookup = {
	["|cffffffWhite|r"] = {1, 1, 1, 1},
	["|c0000ffBlue|r"] = {0, 0, 1, 1},
	["|c00ff00Green|r"] = {0, 1, 0, 1},
	["|cff8000Orange|r"] = {1, 0.5, 0, 1},
	["|cff00e6Pink|r"] = {1, 0, 0.9, 1},
	["|cff0000Red|r"] = {1, 0, 0, 1},
	["|cffcc00Yellow|r"] = {1, 0.8, 0, 1},
	["|c00ffa6Lime Green|r"] = {0, 1, 0.65, 1},

	["ffffff"] = "|cffffffWhite|r",
	["0000ff"] = "|c0000ffBlue|r",
	["00ff00"] = "|c00ff00Green|r",
	["ff8000"] = "|cff8000Orange|r",
	["ff00e6"] = "|cff00e6Pink|r",
	["ff0000"] = "|cff0000Red|r",
	["ffcc00"] = "|cffcc00Yellow|r",
	["00ffa6"] = "|c00ffa6Lime Green|r",
}

local colourLookup = settings.colourLookup
settings.displayChoices = {}
settings.textureSearchup = {}
local displayChoices = settings.displayChoices

local textureChoices = MM.builtInTextureList

local textureSearchup = settings.textureSearchup
for i,v in pairs(textureChoices) do
	local textureName = string.match(v:reverse(), "sdd.(.-)/"):reverse() or "" --string.match(v, "/(.-).dds")

	displayChoices[#displayChoices+1] = "|t24:24:"..v.."|t ("..textureName..")"
	textureSearchup[displayChoices[#displayChoices]] = v
	textureSearchup[v] = displayChoices[#displayChoices]
end


settings.currentSelections = {
	text = "",
	offsetYPercent=50,
	texture=textureChoices[1],
	floating=true,
	rgba={1,1,1,1},
	size=1,
	yaw=0,
	pitch=-90,
	offsetX = 0,
	offsetY = 0,
	offsetZ = 0,
}


settings.quickSelections = { -- seperate to avoid needing to update the menu (also now can remove it when porting to console)
	text = "",
	offsetY=50,
	texture=textureChoices[1],
	floating=true,
	rgba={1,1,1,1},
	size=1,
	yaw=0,
	pitch=-90,
}






function settings.createSettings()
	--local vars = AD.vars

	local panelName = "M0RMarkersSettingsPanel"
	local panelData = {
		type = "panel",
		name = "|cFFD700M0R Markers|r",
		author = "|c0DC1CF@M0R_Gaming|r",
		slashCommand = "/mmarkers"
	}





	
	
	local currentSelections = settings.currentSelections


	

	


	



	

	

	--a = displayChoices


	local exportString = ""
	local importString = ""

	local elmsImportString = ""

	MM.currentLoadProfileName = "Default"
	local currentLoadProfileName = MM.currentLoadProfileName


	local optionsTable = {
		
		{
			type = "button",
			name = "|cFF5555Test|r",
			tooltip = "",
			width = "half",
			func = function()
				CHAT_SYSTEM:AddTextEntry("test")
			end
		},

		{
			type = "description",
			title = "|cFFD700[Place Markers]|r",
			width = "full",
		},

		-- PLACE PRESET MARKERS HERE
		--[[
		
		--]]

		{
			type = "dropdown",
			name = "Texture",
			choices = displayChoices,
			tooltip = "",
			getFunc = function() return textureSearchup[currentSelections.texture] end,
			setFunc = function(value) currentSelections.texture = textureSearchup[value] end,
		},


		{
			type = "colorpicker",
			name = "Colour",
			tooltip = "",
			width = "half",
			getFunc = function() return unpack(currentSelections.rgba) end,
			setFunc = function(r,g,b,a) currentSelections.rgba = {r,g,b,a} end,
		},
		
		{
			type = "dropdown",
			name = "Preset Colours",
			width = "half",
			choices = colourPresets,
			getFunc = function() return colourLookup[ZO_ColorDef.FloatsToHex(unpack(currentSelections.rgba))] end,
			setFunc = function(value) currentSelections.rgba = colourLookup[value] end,
		},
		
		{
			type = "slider",
			name = "Size (cm)",
			tooltip = "",
			min = 10,
			max = 1000,
			step = 10,	--(optional)
			width = "half",
			getFunc = function() return currentSelections.size*100 end,
			setFunc = function(value) currentSelections.size = value/100 end,
		},

		{
			type = "editbox",
			name = "Text",
			tooltip = "",
			width = "half",
			isMultiline = true,
			getFunc = function() return currentSelections.text end,
			setFunc = function(text) currentSelections.text = text end,
		},
		{
			type = "submenu",
			name = "[Advanced Placing]",
			tooltip = "",
			controls = {

				{
					type = "checkbox",
					name = "Facing User",
					tooltip = "",
					getFunc = function() return currentSelections.floating end,
					setFunc = function(value) currentSelections.floating = value end,
				},

				{
					type = "slider",
					name = "Yaw",
					tooltip = "",
					min = 0,
					max = 360,
					step = 1,	--(optional)
					width = "half",
					getFunc = function() return currentSelections.yaw end,
					setFunc = function(value) currentSelections.yaw = value end,
				},

				{
					type = "slider",
					name = "Pitch",
					tooltip = "",
					min = -90,
					max = 90,
					step = 1,	--(optional)
					width = "half",
					getFunc = function() return currentSelections.pitch end,
					setFunc = function(value) currentSelections.pitch = value end,
				},
				{
					type = "editbox",
					name = "Custom Texture",
					tooltip = "",
					getFunc = function() return currentSelections.texture end,
					setFunc = function(value) currentSelections.texture = value end,
				},
				{
					type = "slider",
					name = "Vertical Offset",
					tooltip = "",
					min = -100,
					max = 100,
					step = 1,
					getFunc = function() return currentSelections.offsetYPercent end,
					setFunc = function(value) currentSelections.offsetYPercent = value end,
				},
			}
		},

		{
			type = "button",
			name = "|cFF5555Remove Icon|r",
			tooltip = "",
			width = "half",
			func = function()
				MM.ShowDialogue("Warning: Destructive Action",
					"Are you sure you would like to remove the closest marker on the ground?",
					"This is a destructive action and cannot be undone.",
					MM.removeClosestIcon
				)
			end
		},

		{
			type = "button",
			name = "Place Icon",
			tooltip = "",
			width = "half",
			func = MM.placeIcon,
		},



		{
			type = "divider",
		},



		{
			type = "submenu",
			name = "[Profiles]",
			tooltip = "",
			controls = {
				{
					type = "dropdown",
					name = "Profile Selection",
					width = "half",
					scrollable = 10,
					reference = "M0RMarkersProfileDropdown",
					choices = {},
					getFunc = function()
						MM.updateProfileDropdown(false)
						local currentZone = GetUnitRawWorldPosition('player')
						return MM.vars.loadedProfile[currentZone] or "Default"
					end,
					setFunc = function(value) currentLoadProfileName = value; if M0RMarkersProfileNameEdit then M0RMarkersProfileNameEdit:UpdateValue() end end,
				},

				{
					type = "editbox",
					name = "New Profile Name",
					tooltip = "",
					width = "half",
					isMultiline = false,
					maxChars = 2000,
					reference = "M0RMarkersProfileNameEdit",
					isExtraWide = false,
					getFunc = function() return currentLoadProfileName or "Default" end,
					setFunc = function(text) currentLoadProfileName = text; if M0RMarkersProfileDropdown then M0RMarkersProfileDropdown:UpdateValue() end end,
				},



				{
					type = "button",
					name = "|cFF5555Delete Profile|r",
					tooltip = "",
					warning = "This will delete all markers in the current profile.",
					width = "half",
					func = function()
						MM.ShowDialogue("Warning: Destructive Action",
							"Are you sure you would like to empty the current loaded profile?",
							"This is a destructive action and cannot be undone.", function()
							MM.deleteCurrentProfile(); 
						end)
					end,
				},


				{
					type = "button",
					name = "Load/Create Profile",
					tooltip = "",
					width = "half",
					func = function()
						MM.loadProfile(currentLoadProfileName or "Default")
					end,
				},


				-- MM.loadProfile(value)
			}
		},

		{
			type = "divider",
		},

		{
			type = "editbox",
			name = "Export String",
			tooltip = "",
			width = "full",
			isMultiline = true,
			maxChars = 10000,
			reference = "M0RMarkersExportEditBox",
			isExtraWide = true,
			getFunc = function() return exportString or "" end,
			setFunc = function(text) end,
		},


		{
			type = "button",
			name = "|cFF5555Empty Zone|r",
			tooltip = "",
			warning = "This will delete all markers in the current zone.",
			width = "half",
			func = function()
				MM.ShowDialogue("Warning: Destructive Action", "Are you sure you would like to empty the current zone?", "This is a destructive action and cannot be undone.", function()
					MM.emptyCurrentZone(); exportString = ""; if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end
				end)
			end,
		},

		{
			type = "button",
			name = "Create Export String",
			tooltip = "",
			width = "half",
			func = function() exportString = MM.compressLoaded(); if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end end,
		},

		{
			type = "divider",
		},
		
		{
			type = "editbox",
			name = "Import String",
			tooltip = "",
			width = "full",
			isMultiline = true,
			maxChars = 10000,
			reference = "M0RMarkersImportEditBox",
			isExtraWide = true,
			getFunc = function() return importString end,
			setFunc = function(text) importString = text end,
		},

		{
			type = "button",
			name = "Append to Profile",
			tooltip = "",
			width = "half",
			func = function()
				local zoneString = MM.importIcons(importString, false)
				exportString = zoneString
				if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end
			end,
		},
		{
			type = "button",
			name = "|cFF5555Overwrite Profile|r",
			tooltip = "",
			width = "half",
			func = function()
				MM.ShowDialogue("Warning: Destructive Action", "Are you sure you would like to overwrite the current profile?", "This is a destructive action and cannot be undone.", function()
					MM.importIcons(importString, true); exportString = importString; if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end
				end)
			end,
		},


		


		{
			type = "divider",
		},
		
		{
			type = "editbox",
			name = "Elms Markers Import",
			tooltip = "",
			width = "full",
			isMultiline = true,
			maxChars = 10000,
			isExtraWide = true,
			getFunc = function() return elmsImportString end,
			setFunc = function(text) elmsImportString = text end,
		},

		{
			type = "button",
			name = "Append to Profile",
			tooltip = "",
			width = "half",
			func = function()
				local amountLoaded, zoneString = MM.parseElmsString(elmsImportString)
				print("Parsed ".. tostring(amountLoaded).. " markers.")
				--MM.ShowDialogue("Notice", "Loaded a total of "..tostring(amountLoaded).." markers from Elms!", "", function() end)
				exportString = zoneString
				if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end
			end,
		},
		{
			type = "button",
			name = "|cFF5555Overwrite Profile|r",
			tooltip = "",
			width = "half",
			func = function()
				MM.ShowDialogue("Warning: Destructive Action", "Are you sure you would like to overwrite the current profile?", "This is a destructive action and cannot be undone.", function()
					MM.emptyCurrentZone()
					local amountLoaded, zoneString = MM.parseElmsString(elmsImportString)
					print("Parsed ".. tostring(amountLoaded).. " markers.")
					--MM.ShowDialogue("Notice", "Loaded a total of "..tostring(amountLoaded).." markers from Elms!", "", function() end)
					exportString = zoneString
					if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end
				end)
			end,
		},

	}


	if IsConsoleUI() then
		local toInsert = {
			{
				type = "description",
				title = "|cFFD700[M0R Markers]|r",
				text = "Hello, and thank you for using M0R Markers! If you have any errors or complaints, please reach out to me either on discord (@m0r) or at the link below!",
				width = "full",
			},
			{ -- TODO: SWAP THIS TO BE M0R MARKERS, NOT ARTAEUM
				type = "button",
				name = "Contact Me \n(QR Code)",
				tooltip = "Click this button to be directed to a QR Code which opens the ArtaeumGroupTool esoui page where you can reach out to me!",
				width = "half",
				func = function() RequestOpenUnsafeURL("https://m0rgaming.github.io/create-qr-code/?url=https://www.esoui.com/downloads/info3012-ArtaeumGroupTool2.0.html#comments") end,
			},
			{
				type = "button",
				name = "Contact Me \n(Direct Link)",
				tooltip = "Click this button to be directed to the ArtaeumGroupTool esoui page where you can reach out to me!",
				width = "half",
				func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3012-ArtaeumGroupTool2.0.html#comments") end,
			},
			{
				type = "divider",
			},
		}

		local mergedTables = {}

		ZO_CombineNumericallyIndexedTables(mergedTables, toInsert, optionsTable)

		optionsTable = mergedTables
	end


	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)

end