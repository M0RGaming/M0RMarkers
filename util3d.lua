local MM = M0RMarkers

MM.loadedMarkers = {}
local loadedMarkers = MM.loadedMarkers
loadedMarkers.facing = {}
loadedMarkers.ground = {}

local facingIcons = loadedMarkers.facing
local groundIcons = loadedMarkers.ground

--[[

marker = {
	x = ,
	y = ,
	z = ,
	texture = ,
	orientation = , (nil = facing, {yaw, pitch})
	control = ,
}

{
	x
	y
	z 
	texture
	orientation
	colour
	depthBuffer
	size
}


{
	x
	y
	z 
	bgTexture
	iconTexture
	text
	orientation
	colour
	depthBuffer
	size
}


]]


local controlPool = ZO_ControlPool:New("M0RMarkersTemplate", M0RMarkersToplevel)


local currentlyUpdating = false


local function updateMarkers() -- IF CRUTCH OR CODES ARE LOADED, USE THEM INSTEAD. THIS IS FALLBACK (for now).
	if #facingIcons == 0 then
		EVENT_MANAGER:UnregisterForUpdate("M0RMarkersUpdateTick")
		currentlyUpdating = false
		return
	end

	local fX, fY, fZ = GetCameraForward(SPACE_WORLD)
    local yaw = zo_atan2(fX, fZ) - math.pi
    local pitch = zo_atan2(fY, zo_sqrt(fX * fX + fZ * fZ))


	for i,v in pairs(facingIcons) do
		v.control:SetTransformRotation(pitch,yaw,0)
		--[[ -- might not be needed
		local distance = zo_floor(zo_distance3D(cX, cY, cZ, v.x, v.y, v.z))
		v.control:SetDrawLevel(-distance)
		--]]
	end
end

function MM.updateMarkerPositions()
	local sx, sy, sz = GuiRender3DPositionToWorldPosition(0,0,0)
	for i,v in pairs(facingIcons) do
		local x = (v.x - sx)/100
		local y = v.y/100
		local z = (v.z - sz)/100
		v.control:SetTransformOffset(x,y,z)
	end
	for i,v in pairs(groundIcons) do
		local x = (v.x - sx)/100
		local y = v.y/100
		local z = (v.z - sz)/100
		v.control:SetTransformOffset(x,y,z)
	end
end



local function createControl(icon)
	local control, key = controlPool:AcquireObject()
	control:SetHidden(false)
	control:SetScale(icon.size/100)
	control.bgLayer = control:GetNamedChild("Background")
	control.iconLayer = control:GetNamedChild("Icon")
	control.textLayer = control:GetNamedChild("Text")
	--control:SetColor(1,1,1,1)
	icon.control = control
	icon.key = key
	return icon
end

local function destroyControl(icon)
	icon.control:SetHidden(true)
	icon.control.bgLayer:SetHidden(true)
	icon.control.iconLayer:SetHidden(true)
	icon.control.textLayer:SetHidden(true)

	controlPool:ReleaseObject(icon.key)
	icon.control = nil
	icon.key = nil
end

local function startUpdating()
	if not currentlyUpdating then
		EVENT_MANAGER:RegisterForUpdate("M0RMarkersUpdateTick", 0, updateMarkers)
		currentlyUpdating = true
	end
end



function MM.createIcon(icon)
	icon = createControl(icon)

	if icon.bgTexture then
		icon.control.bgLayer:SetHidden(false)
		icon.control.bgLayer:SetTexture(icon.bgTexture)
		icon.control.bgLayer:SetColor(unpack(icon.colour))
	end
	if icon.iconTexture then
		icon.control.iconLayer:SetHidden(false)
		icon.control.iconLayer:SetTexture(icon.iconTexture)
	end
	if icon.text then
		icon.control.textLayer:SetHidden(false)
		icon.control.textLayer:SetText(icon.text)
	end



    local orientation = icon.orientation

	if orientation then -- ground icon
		icon.control:SetTransformRotation(orientation[1], orientation[2], 0)
		table.insert(groundIcons, icon)
	else -- facing
		table.insert(facingIcons, icon)
		startUpdating()
	end
end


function MM.removeClosestIcon()
	local _, x, y, z = GetUnitRawWorldPosition('player')
	local minDistance = math.huge
	local closestIcon = 0
	local floating = true
	for i,v in pairs(facingIcons) do
		local distance = zo_floor(zo_distance3D(x, y, z, v.x, v.y, v.z))
		if distance < minDistance then
			minDistance = distance
			closestIcon = i
		end
	end
	for i,v in pairs(groundIcons) do
		local distance = zo_floor(zo_distance3D(x, y, z, v.x, v.y, v.z))
		if distance < minDistance then
			minDistance = distance
			closestIcon = i
			floating = false
		end
	end
	if closestIcon == 0 then d("Failed to find closest icon") return end

	if floating then
		destroyControl(facingIcons[closestIcon]) 
		table.remove(facingIcons, closestIcon)
	else
		destroyControl(groundIcons[closestIcon]) 
		table.remove(groundIcons, closestIcon)
	end
	
	local zoneString = MM.compressLoaded()
	MM.saveIcons() -- Update Saved icons
end



function MM.unloadEverything()
	for i,v in pairs(facingIcons) do
		destroyControl(v)
	end
	ZO_ClearNumericallyIndexedTable(facingIcons)
	for i,v in pairs(groundIcons) do
		destroyControl(v)
	end
	ZO_ClearNumericallyIndexedTable(groundIcons)
end