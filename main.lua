M0RMarkers = {}
local MM = M0RMarkers

-- Written by M0R_Gaming

local debugMode = true

MM.name = "M0RMarkers"
MM.varversion = 1



function MM.print(...) 
	if MM.filter then
		MM.filter:AddMessage(...)
	end
end

if not debugMode then
	MM.print = function(...) end
end


local print = MM.print

--[[
SLASH_COMMANDS['/mmcreate'] = function(texture)
	local _, x, y, z = GetUnitWorldPosition('player')
	MM.createIcon(x, y, z, texture, nil, nil)
end

SLASH_COMMANDS['/mmcreateflat'] = function(texture)
	local _, x, y, z = GetUnitWorldPosition('player')
	MM.createIcon(x, y, z, texture, {math.pi/2, 0}, nil)
end

SLASH_COMMANDS['/mmremove'] = function()
	MM.removeClosestIcon()
end
--]]


-- formatting
-- 0 = custom icon
-- zone,x,y,z,colour (hex)
-- zone>depth>orientation>texture>colour>x,y,z/x,y,z/x,y,z<color>x,y,z<<texture>color>x,y,z<<<orientation>texture>colour>x,y,z<<<<<








MM.builtInTextureList = {

	"M0RMarkers/textures/circle.dds",
	"M0RMarkers/textures/hexagon.dds",
	"M0RMarkers/textures/square.dds",
	"M0RMarkers/textures/diamond.dds",
	"M0RMarkers/textures/octagon.dds",
	"M0RMarkers/textures/chevron.dds",


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
	"esoui/art/icons/class/gamepad/gp_class_arcanist.dds",
}


local textureLookup = {}
for i,v in pairs(MM.builtInTextureList) do
	textureLookup[tostring(i)] = v
	textureLookup[v] = i
end



-- NOTE: SHOULD REPLACE FLOATING WITH SIZE


-- string.format("%x", decimal) --<-- converts decimal to hex
-- tonumber('hex',16) --<-- converts hex to decimal


function MM.compressLoaded() -- took 169 icons 2ms to do
	local zone = GetUnitRawWorldPosition('player')
	local colours = {}
	local textures = {}
	local pitches = {}
	local yaws = {}
	local sizes = {}
	

	local mergedTables = {}
	ZO_CombineNumericallyIndexedTables(mergedTables, MM.loadedMarkers.facing, MM.loadedMarkers.ground)

	if #mergedTables == 0 then
		d("You have no markers to save")
		return nil
	end

	local minX = math.huge
	local minY = math.huge
	local minZ = math.huge
	for i,v in pairs(mergedTables) do
		if v.x < minX then minX = v.x end
		if v.y < minY then minY = v.y end
		if v.z < minZ then minZ = v.z end
	end

	local currentConcat = {}
	for i,v in ipairs(mergedTables) do
		if not v.colourHex then v.colourHex = ZO_ColorDef.FloatsToHex(unpack(v.colour)) end
		if not colours[v.colourHex] then colours[v.colourHex] = {} end
		table.insert(colours[v.colourHex], i)

		if not sizes[v.size] then sizes[v.size] = {} end
		table.insert(sizes[v.size], i)

		if v.orientation then
			local pitch = zo_floor(zo_deg(v.orientation[1]))
			if not pitches[pitch] then pitches[pitch] = {} end
			table.insert(pitches[pitch], i)

			local yaw = zo_floor(zo_deg(v.orientation[2]))
			if not yaws[yaw] then yaws[yaw] = {} end
			table.insert(yaws[yaw], i)
		end

		if not textures[v.texture] then textures[v.texture] = {} end
		table.insert(textures[v.texture], i)

		local x = v.x-minX
		local y = v.y-minY
		local z = v.z-minZ

		currentConcat[#currentConcat+1] = string.format("%x:%x:%x:%d", x,y,z,(v.depthBuffer and 1 or 0))
		--secondPart = secondPart..x..":"..y..":"..z..":"..(v.depthBuffer and "1" or "0")..","
	end

	local secondPart = table.concat(currentConcat, ",") or ""

	currentConcat = {}
	local out = tostring(zone) .. "]" .. string.format("%x:%x:%x]", minX,minY,minZ)


	currentConcat = {}
	for i,v in pairs(sizes) do
		if tostring(i) ~= "1" then -- skip default size
			currentConcat[#currentConcat+1] = tostring(i) .. ":".. table.concat(v, ",")
		end
	end
	out = out..table.concat(currentConcat, ";").."]"


	currentConcat = {}
	for i,v in pairs(pitches) do
		currentConcat[#currentConcat+1] = tostring(i) .. ":".. table.concat(v, ",")
	end
	out = out..table.concat(currentConcat, ";").."]"

	currentConcat = {}
	for i,v in pairs(yaws) do
		currentConcat[#currentConcat+1] = tostring(i) .. ":".. table.concat(v, ",")
	end
	out = out..table.concat(currentConcat, ";").."]"

	currentConcat = {}
	for i,v in pairs(colours) do
		currentConcat[#currentConcat+1] = tostring(i) .. ":".. table.concat(v, ",")
	end
	out = out..table.concat(currentConcat, ";").."]"

	currentConcat = {}
	for i,v in pairs(textures) do
		if textureLookup[i] then
			i = "^"..textureLookup[i]
		end
		currentConcat[#currentConcat+1] = tostring(i) .. ":".. table.concat(v, ",")
	end
	out = out..table.concat(currentConcat, ";").."]"..secondPart

	return "<"..out..">"
end





function MM.decompressString(exportString) -- 10 ms to load 206 textures + render
	local _,_, zone, mins, sizes, pitch, yaw, colour, texture, positions = string.find(exportString, "<(.-)](.-)](.-)](.-)](.-)](.-)](.-)](.-)>")
	local currentZone = GetUnitRawWorldPosition('player')
	--print(zone)
	if zone ~= tostring(currentZone) then d("These markers are for a different zone!") return end

	local minXH, minYH, minZH = zo_strsplit(":", mins)
	local minX = tonumber(minXH,16)
	local minY = tonumber(minYH,16)
	local minZ = tonumber(minZH,16)

	local icons = {}
	for i in zo_strgmatch(positions, "[^,]+") do
		local cXH, cYH, cZH, cDepth = zo_strsplit(":", i)
		local cX = tonumber(cXH,16)+minX
		local cY = tonumber(cYH,16)+minY
		local cZ = tonumber(cZH,16)+minZ
		if cDepth == "1" then cDepth = true else cDepth = false end
		icons[#icons+1] = {
			x=cX,
			y=cY,
			z=cZ,
			depthBuffer=cDepth,
			size = 1, -- to be overwritten
			texture = "", -- to be overwritten
			colour = {1,1,1,1}, -- to be overwritten
		}
	end

	for i in zo_strgmatch(sizes, "[^;]+") do
		local currentSize, indexes = zo_strsplit(":", i)
		for j in zo_strgmatch(indexes, "[^,]+") do
			icons[tonumber(j)].size = currentSize
		end
	end
	

	--print("\nTEXTURES:")
	for i in zo_strgmatch(texture, "[^;]+") do
		local currentTexture, indexes = zo_strsplit(":", i)
		--print(currentTexture)
		if zo_strfind(currentTexture, "%^") then
			currentTexture = textureLookup[zo_strsplit("^", currentTexture)] or ""
		end
		--print(currentTexture)
		for j in zo_strgmatch(indexes, "[^,]+") do
			--print(j)
			icons[tonumber(j)].texture = currentTexture
		end
		--print("")
	end

	-- floating, pitch, yaw, colour

	--print("\nCOLOURS:")
	for i in zo_strgmatch(colour, "[^;]+") do
		local currentColour, indexes = zo_strsplit(":", i)
		--print(currentColour)
		
		for j in zo_strgmatch(indexes, "[^,]+") do
			--print(j)
			icons[tonumber(j)].colour = {ZO_ColorDef.HexToFloats(currentColour)}
			icons[tonumber(j)].colourHex = currentColour
		end
		--print("")
	end


	--print("\nPITCHES:")
	for i in zo_strgmatch(pitch, "[^;]+") do
		local currentPitch, indexes = zo_strsplit(":", i)
		currentPitch = zo_rad(currentPitch)
		--print(currentPitch)
		
		for j in zo_strgmatch(indexes, "[^,]+") do
			--print(j)
			icons[tonumber(j)].orientation = {currentPitch, 0}
		end
		--print("")
	end

	--print("\nYAWS:")
	for i in zo_strgmatch(yaw, "[^;]+") do
		local currentYaw, indexes = zo_strsplit(":", i)
		currentYaw = zo_rad(currentYaw)
		--print(currentYaw)
		
		for j in zo_strgmatch(indexes, "[^,]+") do
			--print(j)
			if type(icons[tonumber(j)].orientation) == "table" then
				icons[tonumber(j)].orientation[2] = currentYaw
			else
				icons[tonumber(j)].orientation = {0, currentYaw}
			end
		end
		--print("")
	end

	for i,v in ipairs(icons) do
		MM.createIcon(v)
	end


end




--[[
/script M0RMarkers.decompressString("<1063]12358:30f0:e033]1,2]-90:3]0:3]ffffff:1;c9ff3e:2;ff00f4:3]^1:1,2;^6:3]2b5:0:1e0:0,cc:0:27f:0,0:3:0:0>")




{
		x = x or 0, ---------------------------------------------
		y = y+currentSelections.offsetY+defaultOffset or 0, ---------------------------------------------
		z = z or 0, ---------------------------------------------
		texture = currentSelections.texture, ---------------------------------------------
		orientation = orientation,
		colour = currentSelections.rgba or {1,1,1,1}, ---------------------------------------------
		depthBuffer = currentSelections.depth or false, ---------------------------------------------
		width = currentSelections.width or 1, -- meters
		height = currentSelections.height or 1, -- meters
	}



<1063]12358:30f0:e033]1,2]-90:3]0:3]ffffff:1;c9ff3e:2;ff00f4:3]^1=1,2;^6=3]2b5:0:1e0:0,cc:0:27f:0,0:3:0:0>
]]







MM.defaultVars = {
	loadedProfile = {},
	Profiles = {}
}




--[[

var format

loadedProfile = {
	[zone] = "name"
},

Profiles = {
	[zone] = {
		[name] = {
			icons
		},
		[name] = {
			icons
		}
	},
	[zone] = {
		[name] = {
			icons
		}
	}
}


--]]



local defaultOffset = 10

function MM.placeIcon()
	local _, x, y, z = GetUnitRawWorldPosition('player')
	local orientation = nil
	local currentSelections = MM.Settings.currentSelections
	if not currentSelections.floating then orientation = {-math.pi/2,0} end
	local icon = {
		x = x or 0,
		y = y+currentSelections.offsetY+defaultOffset or 0,
		z = z or 0,
		texture = currentSelections.texture,
		orientation = orientation,
		colour = currentSelections.rgba or {1,1,1,1},
		depthBuffer = currentSelections.depth or false,
		size = currentSelections.size or 1, -- meters
	}
	MM.createIcon(icon)

	local zoneString = MM.compressLoaded()
	MM.saveIcons(zoneString)
end

function MM.saveIcons(zoneString)

	local currentZone = GetUnitRawWorldPosition('player')
	local currentProfileName = MM.vars.loadedProfile[currentZone] or "Default"
	if MM.vars.Profiles[currentZone] then
		MM.vars.Profiles[currentZone][currentProfileName] = zoneString
	else
		MM.vars.Profiles[currentZone] = {
			[currentProfileName] = zoneString
		}
	end
end




SLASH_COMMANDS['/mmplace'] = function()
	MM.placeIcon()
end

SLASH_COMMANDS['/mmremove'] = function()
	MM.removeClosestIcon()
end








function MM.loadZone(currentZone)
	local currentProfileName = MM.vars.loadedProfile[currentZone] or "Default"
	local zoneString = nil
	print("Loading zone: "..tostring(currentZone).." with profile name: "..currentProfileName)
	if MM.vars.Profiles[currentZone] then
		zoneString = MM.vars.Profiles[currentZone][currentProfileName]
	end
	print(tostring(zoneString))
	if zoneString then
		MM.decompressString(zoneString)
	end
end


function MM.importIcons(zoneString, overwrite)
	if overwrite then
		MM.unloadEverything()
	end
	MM.decompressString(zoneString)
	if not overwrite then
		zoneString = MM.compressLoaded()
	end
	MM.saveIcons(zoneString)
	return zoneString
	
end


function MM.emptyCurrentZone()
	MM.unloadEverything()
	MM.saveIcons()
end




local oldZone = 0
function MM.playerActivated()
	local currentZone = GetUnitRawWorldPosition('player')
	if oldZone ~= currentZone then
		oldZone = currentZone
		MM.unloadEverything()
		MM.loadZone(currentZone)
	end
end









-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function MM.OnAddOnLoaded(event, addonName)

	if addonName ~= MM.name then return end

	MM:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function MM:Initialize()
	-- Addon Settings Menu
	MM.vars = ZO_SavedVars:NewAccountWide("Markers", MM.varversion, nil, MM.defaultVars)

	if LibFilteredChatPanel then
		MM.filter = LibFilteredChatPanel:CreateFilter("M0RMarkers", "/esoui/art/crowncrates/psijic/crowncrate_psijic_back.dds", {0, 0.8, 0.8}, false)
	end


	EVENT_MANAGER:RegisterForEvent(MM.name, EVENT_PLAYER_ACTIVATED, MM.playerActivated)

	MM.Settings.createSettings()
	EVENT_MANAGER:UnregisterForEvent(MM.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(MM.name, EVENT_ADD_ON_LOADED, MM.OnAddOnLoaded)