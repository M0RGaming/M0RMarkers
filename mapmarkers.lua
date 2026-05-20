local MM = M0RMarkers

function MM.initMapMarkers()
	local LMP = LibMapPins

	local function makeMarker(zone, cMarker)
		local nx,ny = GetNormalizedWorldPosition(zone, cMarker.x, cMarker.y, cMarker.z)
		if (nx >= 0 and nx <= 1 and ny >= 0 and ny <= 1) then
			LMP:CreatePin("More Markers", cMarker, nx, ny)
		end
	end
	local function markercallback()
		if not LMP:IsEnabled("More Markers") then return end
		local zone = GetUnitWorldPosition('player')
		local currentZoneMarkers = {}
		ZO_CombineNumericallyIndexedTables(currentZoneMarkers, ZO_DeepTableCopy(MM.loadedMarkers.facing), ZO_DeepTableCopy(MM.loadedMarkers.ground))
		for i, cMarker in pairs(currentZoneMarkers) do
			makeMarker(zone, cMarker)
		end
	end
	local pinLayoutData  = {
		level = 5,
		texture = function(pin)
			local _, pinTag = pin:GetPinTypeAndTag()
			return pinTag.bgTexture
		end,
		tint = function(pin)
			local _, pinTag = pin:GetPinTypeAndTag()
			return ZO_ColorDef:New(pinTag.colourHex)
		end,
		size = 25,
	}


	--tooltip creator
	local pinTooltipCreator = {
		creator = function(pin)
			local _, pinTag = pin:GetPinTypeAndTag()
			InformationTooltip:AddLine(pinTag.text)
		end,
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
	}

	local fakestorage = {}


	LMP:AddPinType("More Markers", markercallback, nil, pinLayoutData, pinTooltipCreator)
	LMP:AddPinFilter("More Markers", nil, false, fakestorage )
end
