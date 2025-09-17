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

]]


local controlPool = ZO_ControlPool:New("M0RMarkersControls", M0RMarkersToplevel)
local cameraControl = M0RMarkersToplevelCamera
cameraControl:Create3DRenderSpace()


local currentlyUpdating = false


local function updateMarkers() -- IF CRUTCH OR CODES ARE LOADED, USE THEM INSTEAD. THIS IS FALLBACK (for now).
	if #facingIcons == 0 then
		EVENT_MANAGER:UnregisterForUpdate("M0RMarkersUpdateTick")
		currentlyUpdating = false
		return
	end

	Set3DRenderSpaceToCurrentCamera("M0RMarkersToplevelCamera")

	local fX, fY, fZ = cameraControl:Get3DRenderSpaceForward()
	local rX, rY, rZ = cameraControl:Get3DRenderSpaceRight()
	local uX, uY, uZ = cameraControl:Get3DRenderSpaceUp()
	local cX, cY, cZ = GuiRender3DPositionToWorldPosition(cameraControl:Get3DRenderSpaceOrigin())


	for i,v in pairs(facingIcons) do
		v.control:Set3DRenderSpaceForward(fX, fY, fZ)
		v.control:Set3DRenderSpaceRight(rX, rY, rZ)
		v.control:Set3DRenderSpaceUp(uX, uY, uZ)

		local distance = zo_floor(zo_distance3D(cX, cY, cZ, v.x, v.y, v.z))
		v.control:SetDrawLevel(-distance)
	end
end


local function createControl(icon)
	local control, key = controlPool:AcquireObject()
	control:Create3DRenderSpace()
	control:SetHidden(false)
	--control:SetColor(1,1,1,1)
	icon.control = control
	icon.key = key
	return icon
end

local function destroyControl(icon)
	icon.control:Destroy3DRenderSpace()
	icon.control:SetHidden(true)
	controlPool:ReleaseObject(icon.key)
	icon.control = nil
	icon.key = nil
end

local function startUpdating()
	if not currentlyUpdating then
		EVENT_MANAGER:RegisterForUpdate("M0RMarkersUpdateTick", 50, updateMarkers)
		currentlyUpdating = true
	end
end



function MM.createIcon(icon)
	icon = createControl(icon)
	icon.control:SetTexture(icon.texture)
	icon.control:SetColor(unpack(icon.colour))

	icon.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(icon.x, icon.y, icon.z))

	--local texWidth, texHeight = icon.control:GetTextureFileDimensions()
    icon.control:Set3DLocalDimensions(icon.width, icon.height)
    icon.control:Set3DRenderSpaceUsesDepthBuffer(icon.depthBuffer)

    local orientation = icon.orientation

	if orientation then -- ground icon
		icon.control:Set3DRenderSpaceOrientation(orientation[1], orientation[2], 0)
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
	

	MM.saveIcons() -- Update Saved icons
end