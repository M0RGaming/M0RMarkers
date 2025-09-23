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


	local textureChoices = MM.builtInTextureList



	settings.currentSelections = {
		depth=false,
		offsetY=0,
		texture=textureChoices[1],
		floating=true,
		rgba={1,1,1,1},
		size=1,
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
	local importString = ""


	local optionsTable = {
		{
			type = "description",
			title = "|cFFD700[M0R Markers]|r",
			text = "Hello, and thank you for using M0R Markers! If you have any errors or complaints, please reach out to me either on discord (@m0r) or at the link below!",
			width = "full",
		},
		{ -- TODO: SWAP THIS TO BE M0R MARKERS, NOT ARTAEUM
			type = "button",
			name = "Contact Me\n(QR Code)",
			tooltip = "Click this button to be directed to a QR Code which opens the ArtaeumGroupTool esoui page where you can reach out to me!",
			width = "half",
			func = function() RequestOpenUnsafeURL("https://m0rgaming.github.io/create-qr-code/?url=https://www.esoui.com/downloads/info3012-ArtaeumGroupTool2.0.html#comments") end,
		},
		{
			type = "button",
			name = "Contact Me\n(Direct Link)",
			tooltip = "Click this button to be directed to the ArtaeumGroupTool esoui page where you can reach out to me!",
			width = "half",
			func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3012-ArtaeumGroupTool2.0.html#comments") end,
		},
		{
			type = "divider",
		},

		{
			type = "description",
			title = "|cFFD700[Place Markers]|r",
			width = "full",
		},

		-- PLACE PRESET MARKERS HERE
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
	        name = "Size",
	        tooltip = "",
	        min = 0.1,
	        max = 10,
	        step = 0.1,	--(optional)
	        getFunc = function() return currentSelections.size end,
	        setFunc = function(value) currentSelections.size = value end,
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
			name = "Create Export String",
			tooltip = "",
			width = "full",
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
			name = "Overwrite Profile",
			tooltip = "",
			width = "half",
			func = function() MM.importIcons(importString, true); exportString = importString; if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end end,
		},
		{
			type = "button",
			name = "Empty Zone",
			tooltip = "",
			warning = "This will delete all markers in the current zone.",
			width = "full",
			func = function() MM.emptyCurrentZone(); exportString = ""; if M0RMarkersExportEditBox then M0RMarkersExportEditBox:UpdateValue() end end,
		},

	}


	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)

end