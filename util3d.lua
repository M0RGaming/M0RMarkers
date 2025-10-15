local MM = M0RMarkers

MM.loadedMarkers = {}
local loadedMarkers = MM.loadedMarkers
loadedMarkers.facing = {}
loadedMarkers.ground = {}

local facingIcons = loadedMarkers.facing
local groundIcons = loadedMarkers.ground

MM.loadedMarkers.currentTimestamp = -1

local print = MM.print


local controlPool = nil

function MM.initUtil3D()
	controlPool = ZO_ControlPool:New("M0RMarkersTemplate", M0RMarkersToplevel) -- place in init func


	-- add fragment to HUD, UI, GAME_MENU_SCENE
	local iconFragment = ZO_HUDFadeSceneFragment:New(M0RMarkersToplevel, DEFAULT_SCENE_TRANSITION_TIME, 0)
	HUD_SCENE:AddFragment(iconFragment)
	HUD_UI_SCENE:AddFragment(iconFragment)
	GAME_MENU_SCENE:AddFragment(iconFragment)


	if IsConsoleUI() and LibHarvensAddonSettings then
		SecurePostHook(LibHarvensAddonSettings, "CreateAddonList", function() LibHarvensAddonSettings.scene:AddFragment(iconFragment) end)
	else 
		local function sceneChanged(scene, oldState, newState)
			if scene.name ~= "hud" and scene.name ~= "hudui" and newState == "showing" then
				--print("No longer showing hud/hudui")
				M0RMarkerPlaceToplevel:SetHidden(true)
			end
		end
		SCENE_MANAGER:RegisterCallback("SceneStateChanged", sceneChanged)
	end
end



local currentlyUpdating = false

local currentlyCulling = false



local function updateMarkers()
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
	end
end

local function cullMarkers()
	local cullDistance = MM.vars.cullingDistance * 100 or 0
	if cullDistance == 0 then
		EVENT_MANAGER:UnregisterForUpdate("M0RMarkersCullTick")
		currentlyCulling = false

		for i,v in pairs(facingIcons) do
			v.control:SetHidden(false)
		end
		for i,v in pairs(groundIcons) do
			v.control:SetHidden(false)
		end

		return
	end

	local _, x, y, z = GetUnitRawWorldPosition('player')
	for i,v in pairs(facingIcons) do
		local dist = zo_distance3D(x,y,z, v.x, v.y, v.z)
		if dist > cullDistance then
			v.control:SetHidden(true)
		else
			v.control:SetHidden(false)
		end
	end
	for i,v in pairs(groundIcons) do
		local dist = zo_distance3D(x,y,z, v.x, v.y, v.z)
		if dist > cullDistance then
			v.control:SetHidden(true)
		else
			v.control:SetHidden(false)
		end
	end

end


function MM.startCulling()
	if not currentlyCulling then
		EVENT_MANAGER:RegisterForUpdate("M0RMarkersCullTick", 500, cullMarkers) -- only update once every half a second.
		currentlyCulling = true
	end
end




function MM.updateMarkerPositions()
	local sx, sy, sz = GuiRender3DPositionToWorldPosition(0,0,0)
	print("\nUpdating Markers, Origin:")
	print(sx)
	print(sy)
	print(sz)
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
		--print("Placing icon: "..v.bgTexture.." at: "..x..", "..y..", "..z)
		v.control:SetTransformOffset(x,y,z)
	end
end



local function createControl(icon)
	local control, key = controlPool:AcquireObject()
	control:SetHidden(false)
	control:SetSpace(SPACE_WORLD)
	control:SetAnchor(CENTER,GuiRoot,CENTER) -- needed, since releasing object will clear anchors
	--control:SetScale(icon.size/100) -- set transform scale to icon.size instead of scale
	control:SetScale(1/100) -- 1m
	control.bgLayer = control:GetNamedChild("Background")
	control.textLayer = control:GetNamedChild("Text")
	control:SetTransformNormalizedOriginPoint(0.5,0.5)

	local multiplier = MM.vars.globalMult or 1
	control:SetTransformScale(icon.size * multiplier)

	icon.control = control
	icon.key = key
	return icon
end

local function destroyControl(icon)
	icon.control:SetHidden(true)
	icon.control.bgLayer:SetHidden(true)
	icon.control.textLayer:SetText("")
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
	if icon.text then
		icon.control.textLayer:SetHidden(false)
		icon.control.textLayer:SetText(icon.text)
	end


	local x,y,z = WorldPositionToGuiRender3DPosition(icon.x, icon.y, icon.z)
	icon.control:SetTransformOffset(x,y,z)


	local orientation = icon.orientation

	if orientation then -- ground icon
		icon.control:SetTransformRotation(orientation[1], orientation[2], 0)
		table.insert(groundIcons, icon)
	else -- facing
		table.insert(facingIcons, icon)
		startUpdating()
	end
end


function MM.removeClosestIcon(overwriteX, overwriteY, overwriteZ)
	if MM.multipleProfilesLoaded then
		MM.ShowNotice("Notice", "Markers are Read-Only when multiple profiles are loaded.", "")
		d("|cFFD700More Markers|r: Markers are Read-Only when multiple profiles are loaded.")
		return
	end

	local _, x, y, z = GetUnitRawWorldPosition('player')
	if overwriteX then x = overwriteX end
	if overwriteY then y = overwriteY end
	if overwriteZ then z = overwriteZ end

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
	if closestIcon == 0 then d("|cFFD700More Markers|r: Failed to find closest icon to delete") return end

	if floating then
		destroyControl(facingIcons[closestIcon]) 
		table.remove(facingIcons, closestIcon)
	else
		destroyControl(groundIcons[closestIcon]) 
		table.remove(groundIcons, closestIcon)
	end

	MM.loadedMarkers.currentTimestamp = os.time()
	local zoneString = MM.compressLoaded()
	MM.saveIcons(zoneString) -- Update Saved icons
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