local MM = M0RMarkers
MM.Settings = {}
local settings = MM.Settings

function settings.createSettings()
	--local vars = AD.vars

	local panelName = "M0RMarkersSettingsPanel"
	local panelData = {
		type = "panel",
		name = "|cFFD700M0R Markers|r",
		author = "|c0DC1CF@M0R_Gaming|r",
		slashCommand = "/mmarkers"
	}


	local textureChoices = {
		"esoui/art/stats/alliancebadge_aldmeri.dds",
		"esoui/art/stats/alliancebadge_ebonheart.dds",
		"esoui/art/stats/alliancebadge_daggerfall.dds",
		"esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
		"esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
		"esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
		"esoui/art/icons/class/gamepad/gp_class_dragonknight.dds",
		"esoui/art/icons/class/gamepad/gp_class_sorcerer.dds",
		"esoui/art/icons/class/gamepad/gp_class_nightblade.dds",
		"esoui/art/icons/class/gamepad/gp_class_warden.dds",
		"esoui/art/icons/class/gamepad/gp_class_necromancer.dds",
		"esoui/art/icons/class/gamepad/gp_class_templar.dds",
		"esoui/art/icons/class/gamepad/gp_class_arcanist.dds"
	}



	settings.currentSelections = {
		depth=false,
		offsetY=0,
		texture=textureChoices[1],
		floating=true,
		rgba={1,1,1,1},
		width=1,
		height=1,
	}
	
	local currentSelections = settings.currentSelections


	



	

	local displayChoices = {}
	local textureSearchup = {}
	for i,v in pairs(textureChoices) do
		displayChoices[#displayChoices+1] = "|t32:32:"..v.."|t"
		textureSearchup[displayChoices[#displayChoices]] = v
		textureSearchup[v] = displayChoices[#displayChoices]
	end


	local exportString = ""


	local optionsTable = {
		{
			type = "description",
			title = "|cFFD700[M0R Markers]|r",
			text = "Hello, and thank you for using M0R Markers! If you have any errors or complaints, please reach out to me either on discord (@m0r) or at the link below!",
			width = "full",
		},
		{ -- TODO: SWAP THIS TO BE M0R MARKERS, NOT ARTAEUM
			type = "button",
			name = "Report Bug/Contact Me\n(QR Code)",
			tooltip = "Click this button to be directed to a QR Code which opens the ArtaeumGroupTool esoui page where you can reach out to me!",
			width = "full",
			func = function() RequestOpenUnsafeURL("https://m0rgaming.github.io/create-qr-code/?url=https://www.esoui.com/downloads/info3012-ArtaeumGroupTool2.0.html#comments") end,
		},
		{
			type = "button",
			name = "Report Bug/Contact Me\n(Direct Link)",
			tooltip = "Click this button to be directed to the ArtaeumGroupTool esoui page where you can reach out to me!",
			width = "full",
			func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3012-ArtaeumGroupTool2.0.html#comments") end,
		},
		{
			type = "submenu",
			name = "|cFFD700[Place Markers]|r",
			controls = {
				{
					type = "checkbox",
					name = "Enable Depth Buffer",
					tooltip = "",
					getFunc = function() return currentSelections.depth end,
					setFunc = function(value) currentSelections.depth = value end,
				},
				
				{
					type = "slider",
					name = "Vertical Offset",
					tooltip = "",
					min = -100,
					max = 100,
					step = 1,
					getFunc = function() return currentSelections.offsetY end,
					setFunc = function(value) currentSelections.offsetY = value end,
				},

				{
					type = "dropdown",
					name = "Texture",
					-- TODO: Fill out Dropdown
					choices = displayChoices,
					tooltip = "",
					getFunc = function() return textureSearchup[currentSelections.texture] end,
					setFunc = function(value) currentSelections.texture = textureSearchup[value] end,
				},
				{
					type = "editbox",
					name = "[Advanced] Custom Texture",
					tooltip = "",
					getFunc = function() return currentSelections.texture end,
					setFunc = function(value) currentSelections.texture = value end,
				},
				{
					type = "checkbox",
					name = "Facing User",
					tooltip = "",
					getFunc = function() return currentSelections.floating end,
					setFunc = function(value) currentSelections.floating = value end,
				},


				{
			        type = "colorpicker",
			        name = "Colour",
			        tooltip = "",
			        getFunc = function() return unpack(currentSelections.rgba) end,
			        setFunc = function(r,g,b,a) currentSelections.rgba = {r,g,b,a} end,
			    },
			    --[[
				{
					type = "dropdown",
					name = "Preset Colours",
					--choices = ,
					getFunc = function() return currentSelections.rgba end,
					setFunc = function(value) currentSelections.rgba = value end,
				},
				--]]
				{
			        type = "slider",
			        name = "Width",
			        tooltip = "",
			        min = 0.1,
			        max = 10,
			        step = 0.1,	--(optional)
			        getFunc = function() return currentSelections.width end,
			        setFunc = function(value) currentSelections.width = value end,
			    },
				{
			        type = "slider",
			        name = "Height",
			        tooltip = "",
			        min = 0.1,
			        max = 10,
			        step = 0.1,	--(optional)
			        getFunc = function() return currentSelections.height end,
			        setFunc = function(value) currentSelections.height = value end,
			    },
			    {
					type = "button",
					name = "Place Icon",
					tooltip = "",
					width = "half",
					func = MM.placeIcon,
				},

			    {
					type = "button",
					name = "Remove Icon",
					tooltip = "",
					width = "half",
					func = MM.removeClosestIcon,
				},
			}
		},

		{
			type = "button",
			name = "Create Export String",
			tooltip = "",
			width = "full",
			func = function() exportString = MM.compressLoaded(); if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end end,
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

	}


	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)

end