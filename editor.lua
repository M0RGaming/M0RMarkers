--/script

local MM = M0RMarkers
local control
local tileManager
local _
local image
local destroyControl

local scene = ZO_InteractScene:New("M0RMarkerEditorScene", SCENE_MANAGER, { -- TODO MAYBE GET RID OF BANKING, IDK
	type = "Banking",
	interactTypes = { INTERACTION_BANK },
})

local deferredInit = ZO_DeferredInitializingObject:New(scene)
function deferredInit:OnDeferredInitialize()
	MM.editorInit()
end

SLASH_COMMANDS['/mmshoweditor'] = function() SCENE_MANAGER:Push('M0RMarkerEditorScene') end


function MM.editorInit()


	--local ZosMapWidth, ZosMapHeight = ZO_WorldMap:GetDimensions()
	local _, guiHeight = GuiRoot:GetDimensions()
	local ZosMapWidth = guiHeight*0.75
	local ZosMapHeight = guiHeight*0.75



	MM.editorSelections = {

	}

	-- now doing this in xml
	--[[
	local function GetAllMapIdsByZoneId()
		local startTime = os.rawclock()
		local results = {}
		local mapIdMax = 10000
		for mapId = 1, mapIdMax do
			local name, _, _, zoneIndex = GetMapInfoById(mapId)
			local zoneId = GetZoneId(zoneIndex)
			if zoneId ~= 2 then
				if results[zoneId] then
					results[zoneId][mapId] = name
				else
					results[zoneId] = {[mapId] = name}
				end
				last = mapId
			end
		end
		d(string.format("Searched through %d maps, and took %dms", last, os.rawclock()-startTime))
		return results
	end
	--]]

	--x = GetAllMapIdsByZoneId()

	M0RMarkers.mapZoneLookup = {}
	local mapIdMax = 10000
	for mapId = 1, mapIdMax do
		local name, _, _, zoneIndex = GetMapInfoById(mapId)
		local zoneId = GetZoneId(zoneIndex)
		if zoneId ~= 2 then
			if M0RMarkers.mapZoneLookup[zoneId] then
				M0RMarkers.mapZoneLookup[zoneId][mapId] = name
			else
				M0RMarkers.mapZoneLookup[zoneId] = {[mapId] = name}
			end
		end
	end

	-- manual adding of zones cause KA broke or something idk
	M0RMarkers.mapZoneLookup[1196] = {
		[1805] = GetMapNameById(1805),
		[1806] = GetMapNameById(1806),
		[1807] = GetMapNameById(1807), -- start at 18182
		[1808] = GetMapNameById(1808), -- start at 10882
	}

	local mapStartY = {
		[1807] = 18182,
		[1808] = 10882
	}

	local mapEndY = {
		[1806] = 18182,
		[1807] = 10882
	}
	local mapFloors = {
		[1806] = 21720,
		[1807] = 14644,
		[1808] = 7120
	}




	--M0RMarkerEditorToplevel:SetHidden(false)
	--SLASH_COMMANDS['/mmhideeditor'] = function() M0RMarkerEditorToplevel:SetHidden(true) end
	--SLASH_COMMANDS['/mmshoweditor'] = function() M0RMarkerEditorToplevel:SetHidden(false) end



	local wm = WINDOW_MANAGER

	control = wm:CreateControl("M0RMarkersEditorImageBackground", M0RMarkerEditorToplevel, CT_BACKDROP)
	control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	control:SetDimensions(ZosMapWidth, ZosMapHeight)
	--control:SetDimensions(835, 835)
	control:SetCenterColor(0, 0, 0, 0)
	control:SetEdgeColor(0, 0, 0, 1)
	control:SetAutoRectClipChildren(true)


	image = wm:CreateControl("M0RMarkersEditorImageImage", control, CT_CONTROL)
	image:SetAnchor(CENTER, control, CENTER, 0, 0)
	image:SetDimensions(ZosMapWidth, ZosMapHeight)
	--image:SetDimensions(835, 835)
	--image:SetTexture("esoui/art/crowncrates/psijic/crowncrate_psijic_back.dds")



	control:SetMouseEnabled(true)

	--control:SetTransformScale(835/ZO_MAP_CONSTANTS.MAP_WIDTH)

	--M0RMarkerEditorToplevel:SetTransformScale(ZO_MAP_CONSTANTS.MAP_WIDTH/835)



	control:SetScale(835/ZosMapWidth)
	M0RMarkerEditorToplevel:SetScale(ZosMapWidth/835)


	image:ClearAnchors()
	image:SetAnchor(CENTER, control, CENTER, 0, 0)



	local originX
	local originZ
	local nxratio
	local nzratio


	local cursorId




	local currentZoneMarkers = {}
	local markerpreviews = {}
	local selectedMarker = 0


	local emptyMarker = {
		index = 0
	}



	local function SetSelectedMarker(currentMarker)
		if not markerpreviews[currentMarker.index] then -- if the marker isnt on the current map, dont load it (maybe fixes falg idk)
			currentMarker = emptyMarker
		end
		if currentZoneMarkers[selectedMarker] and currentZoneMarkers[selectedMarker].control and currentZoneMarkers[selectedMarker].control.highlight then
			currentZoneMarkers[selectedMarker].control.highlight:SetHidden(true)
		end
		--x = currentZoneMarkers
		if type(currentMarker) ~= "table" then return end
		local markerIndex = currentMarker.index
		selectedMarker = markerIndex

		if currentMarker.control then
			currentMarker.control.highlight:SetHidden(false)
		end


		local toplevel = M0RMarkerEditorToplevel
		local selectedMarkerText = toplevel:GetNamedChild("MarkerDetails"):GetNamedChild("Text")
		local markerSize = toplevel:GetNamedChild("MarkerSize"):GetNamedChild("Edit")
		local textureEdit = toplevel:GetNamedChild("TextureSelector"):GetNamedChild("Texture"):GetNamedChild("Edit")
		local yawEdit = toplevel:GetNamedChild("Yaw"):GetNamedChild("Edit")
		local pitchEdit = toplevel:GetNamedChild("Pitch"):GetNamedChild("Edit")

		local xContainer = toplevel:GetNamedChild("X")
		local xEdit = xContainer:GetNamedChild("Edit")
		local xText = xContainer:GetNamedChild("Text")

		local yContainer = toplevel:GetNamedChild("Y")
		local yEdit = yContainer:GetNamedChild("Edit")
		local yText = yContainer:GetNamedChild("Text")

		local zContainer = toplevel:GetNamedChild("Z")
		local zEdit = zContainer:GetNamedChild("Edit")
		local zText = zContainer:GetNamedChild("Text")

		local textEditor = toplevel:GetNamedChild("TextEditor")
		local colourEdit = toplevel:GetNamedChild("ColourSelector"):GetNamedChild("ColourHex"):GetNamedChild("Edit")
		-- for the x y z, check the following to see if the marker is on the page. Dont allow user to move marker off of page (when applying)
		-- local nx,ny = GetRawNormalizedWorldPosition(self.cZone, cMarker.x, cMarker.y, cMarker.z)
		-- if (nx >= 0 and nx <= 1 and ny >= 0 and ny <= 1) then

		selectedMarkerText:SetText(string.format("Selected Marker: %d", selectedMarker))
		markerSize:SetText(currentMarker.size or "")
		textureEdit:SetText(currentMarker.bgTexture or "")
		if currentMarker.orientation then
			pitchEdit:SetText(string.format("%.1f",zo_deg(currentMarker.orientation[1])))
			yawEdit:SetText(string.format("%.1f",zo_deg(currentMarker.orientation[2])))
		else
			pitchEdit:SetText("")
			yawEdit:SetText("")
		end
		xEdit:SetText(currentMarker.x or "")
		yEdit:SetText(currentMarker.y or "")
		zEdit:SetText(currentMarker.z or "")
		textEditor:SetText(currentMarker.text or "")


		-- position sanity check
		if markerIndex ~= 0 then
			if (not currentMarker.y) or (currentMarker.y == 0) then
				yEdit:SetColor(1,0,0)
				yText:SetColor(1,0,0)
			else
				yEdit:SetColor(1,1,1)
				yText:SetColor(1,1,1)
			end
		
			local nx = (currentMarker.x - originX)/nxratio
			local nz = (currentMarker.z - originZ)/nzratio
			--d(nx,nz)
			if nx > 1 or nx < 0 then
				xEdit:SetColor(1,0,0)
				xText:SetColor(1,0,0)
			else
				xEdit:SetColor(1,1,1)
				xText:SetColor(1,1,1)
			end

			if nz > 1 or nz < 0 then
				zEdit:SetColor(1,0,0)
				zText:SetColor(1,0,0)
			else
				zEdit:SetColor(1,1,1)
				zText:SetColor(1,1,1)
			end
		else
			xEdit:SetColor(1,1,1)
			xText:SetColor(1,1,1)
			yEdit:SetColor(1,1,1)
			yText:SetColor(1,1,1)
			zEdit:SetColor(1,1,1)
			zText:SetColor(1,1,1)
		end




		local hexColour
		if currentMarker.colour then
			hexColour = ZO_ColorDef.FloatsToHex(unpack(currentMarker.colour))
		end
		colourEdit:SetText(hexColour or "")


	end
	-- apply will change the currentZoneMarkers, and rerun the code for marker setup in tileManager:SetMapId(mapid)
	-- editing position will maybe change the location live (idk, might be too much work)
	-- save will populate the currentZoneMarkers back to MM.loadedMarkers, save, and load it again.


	function MM.reselectCurrentMarker()
		SetSelectedMarker(currentZoneMarkers[selectedMarker])
	end



	function MM.editorApplyPressed()
		--b = currentZoneMarkers
		--d("Apply Pressed")
		if selectedMarker == 0 then return end
		local selections = M0RMarkers.editorSelections
		--for i,v in pairs(selections) do
		--	d(string.format("%s: %s", i, v))
		--end
		local cMarker = currentZoneMarkers[selectedMarker]
		local x = tonumber(selections.x)
		local y = tonumber(selections.y)
		local z = tonumber(selections.z)
		if x then cMarker.x = x end
		if y then cMarker.y = y end
		if z then cMarker.z = z end
		if selections.text then cMarker.text = selections.text end
		local markersize = selections.markersize
		if markersize then cMarker.size = markersize end
		local colourR, colourG, colourB, colourA = ZO_ColorDef.HexToFloats(selections.colour)
		if colourR then
			cMarker.colourHex = selections.colour
			cMarker.colour[1] = colourR
			cMarker.colour[2] = colourG
			cMarker.colour[3] = colourB
			cMarker.colour[4] = colourA
		end
		local texture = selections.texture
		if texture ~= "" then cMarker.bgTexture = texture end
		local yaw = tonumber(selections.yaw)
		local pitch = tonumber(selections.pitch)
		if pitch or yaw then
			cMarker.orientation = {zo_rad(pitch or 0), zo_rad(yaw or 0)}
		else
			cMarker.orientation = nil
		end


		-- TODO: Do a sanity check. If position is off the screen, ask user to confirm if they want that

		tileManager:ReloadMap()
		SetSelectedMarker(cMarker)
	end

	local function deleteSelectedMarker()
		if selectedMarker == 0 then return end
		if currentZoneMarkers[selectedMarker] then
			currentZoneMarkers[selectedMarker] = nil
			tileManager:ReloadMap()
		end
	end

	function MM.deleteMarkerPressed()
		if selectedMarker == 0 then return end
		MM.ShowDialogue("Warning: Destructive Action",
					string.format("Are you sure you would like to remove the selected marker %d?", selectedMarker),
					"This is a destructive action and cannot be undone.",
					deleteSelectedMarker
				)
	end



	function MM.deleteAllDuplicates() -- god this is inefficient  
		local count = 0
		--deletedMarkers = {}
		for i,v in pairs(currentZoneMarkers) do
			for j,k in pairs(currentZoneMarkers) do
				if (i ~= j) and (v.x == k.x) and (v.y == k.y) and (v.z == k.z) and (v.text == k.text) and (v.size == k.size) and (v.colourHex == k.colourHex) and (v.bgTexture == k.bgTexture) and (v.yaw == k.yaw) and (v.pitch == k.pitch) then
					-- i guess this is an exact match
					currentZoneMarkers[j] = nil
					--deletedMarkers[#deletedMarkers+1] = j
					count = count + 1
				end
			end
		end
		if count ~= 0 then
			MM.ShowNotice("Notice", string.format("%d duplicate markers were found and deleted.", count), "")
		else
			MM.ShowNotice("Notice", "No duplicate markers were found.", "")
		end
		--d("Found and deleted "..count.." duped markers.")
		tileManager:ReloadMap()
	end



	local function createMarker(x,y)
		local l, t, r, b = image:ProjectRectToScreenAndBuildAABB()
		local dx = x-l
		local dy = y-t
		local nx = dx/(r-l)
		local ny = dy/(b-t)
		--d(nx,ny)
		local worldX = originX+nx*nxratio
		local _, _, py, _ = GetUnitRawWorldPosition('player')

		if mapFloors[tileManager.mapid] then
			py = mapFloors[tileManager.mapid]
			MM.ShowNotice("Notice", "Due to how ESO handles Falgravn's Room in Kynes Aegis, markers placed with the editor will be offset by a certain distance and may not show up in game unless manually corrected.", "")
		end

		local worldZ = originZ+ny*nzratio



		local marker = {
			--index = #currentZoneMarkers+1,
			bgTexture = "M0RMarkers/textures/diamond.dds",
			colour = {1,1,1,1},
			colourHex = "ffffff",
			size = 1,
			text = "",
			x = zo_floor(worldX),
			y = py or 0,
			z = zo_floor(worldZ)
		}

		currentZoneMarkers[#currentZoneMarkers+1] = marker
		tileManager:ReloadMap()
		--d(marker.index)
		SetSelectedMarker(marker)
	end




	local function saveProfile() --destroyControl(v)
		MM.unloadEverything()
		local loadedMarkers = MM.loadedMarkers
		for i,v in pairs(markerpreviews) do
			destroyControl(v)
			markerpreviews[i] = nil
		end
		for i,v in pairs(currentZoneMarkers) do
			if type(v.orientation) == "table" then
				loadedMarkers.ground[#loadedMarkers.ground+1] = v
			else
				loadedMarkers.facing[#loadedMarkers.facing+1] = v
			end
		end
		MM.loadedMarkers.currentTimestamp = os.time()
		local zoneString = MM.compressLoaded()
		MM.saveIcons(zoneString)
		ZO_ClearNumericallyIndexedTable(loadedMarkers.facing)
		ZO_ClearNumericallyIndexedTable(loadedMarkers.ground)
		MM.decompressString(zoneString)
		SCENE_MANAGER:Push('hud')
	end

	function MM.editorSavePressed()
		MM.ShowDialogue("Warning: Destructive Action",
					"Are you sure you would like to overwrite the current profile with your edited changes?",
					"This is a destructive action and cannot be undone.",
					saveProfile
				)
	end







	local function updateTick(dataType, customDeltaX, customDeltaY)
		local deltaX = 0
		local deltaY = 0
		local startOX = image.startOriginX
		local startOY = image.startOriginY

		if image.dragging then
			local x, y = GetUIMousePosition()
			deltaX = x-image.startX
			deltaY = y-image.startY
		elseif dataType == "customDelta" then
			deltaX = customDeltaX
			deltaY = customDeltaY
		end



		image:ClearAnchors()

		local scale = image:GetScale()

		--local maxAnchor = zo_clamp((ZO_MAP_CONSTANTS.MAP_WIDTH*scale)-ZO_MAP_CONSTANTS.MAP_WIDTH, 0, ZO_MAP_CONSTANTS.MAP_WIDTH) -- 1 to 2, worse. 2 to 3, better
		local maxAnchor = (ZosMapWidth*scale)-ZosMapWidth
		--local maxAnchor = (835*scale)-835

		image:SetAnchor(CENTER, control, CENTER, zo_clamp(startOX+deltaX,-maxAnchor, maxAnchor), zo_clamp(startOY+deltaY,-maxAnchor, maxAnchor))
	end


	local function changeScale(self, delta, dataType)
		--d(delta, cursorX, cursorY)
		if (not image.dragging) or (dataType == "gamepadCursor") then
			if dataType ~= "gamepadCursor" then
				image.startX, image.startY = GetUIMousePosition()
			end
			_, _, _, _, image.startOriginX, image.startOriginY = image:GetAnchor()
		end
		local globalScale = M0RMarkerEditorToplevel:GetScale() or 1

		local scale = zo_clamp(image:GetScale()+delta/10, 1, 8)
		image:SetScale(scale)

		for i,v in pairs(markerpreviews) do
			local markerScale = zo_clamp(v.size*0.25/scale,0,0.25*v.size)
			v.control:SetScale(markerScale)
			v.control:ClearAnchors()


			local dx = 100
			local currentSize = dx*markerScale
			local x,y = v.control:GetDimensions()
			v.control:SetAnchor(TOPLEFT,image,TOPLEFT, v.initialXAnchor-currentSize/2, v.initialYAnchor-currentSize/2)
			local scalingFactor = 1
			
			if x < (25 * globalScale) then
				scalingFactor = (25*globalScale)/x
			end

			if x > (35 * globalScale) then
				scalingFactor = (35*globalScale)/x
			end
			scalingFactor = scalingFactor/v.control.textLayer:GetNumLines()
			
			v.control:SetTransformScale(scalingFactor)
		end

		updateTick()
	end


	control:SetHandler("OnMouseWheel", changeScale)


	image:SetMouseEnabled(true)
	image:SetHandler("OnDragStart", function()
		image.dragging = true
		--d("Started Dragging")
		image.startX, image.startY = GetUIMousePosition()
		_, _, _, _, image.startOriginX, image.startOriginY = image:GetAnchor()
		EVENT_MANAGER:RegisterForUpdate("image update tick", 10, updateTick)
	end)

	local function OnDragStop()
		--d("Stopped Dragging")
		image.dragging = false
		EVENT_MANAGER:UnregisterForUpdate("image update tick")
	end


	local function updateLastPlayerClickPositions(source)
		local toplevel = M0RMarkerEditorToplevel
		local xEdit = toplevel:GetNamedChild("lastX"):GetNamedChild("Edit")
		local yEdit = toplevel:GetNamedChild("playerY"):GetNamedChild("Edit")
		local zEdit = toplevel:GetNamedChild("lastZ"):GetNamedChild("Edit")

		local _, _, y, _ = GetUnitRawWorldPosition("player")
		local mx, my = GetUIMousePosition()
		if cursorId and source == "gamepadCursor" then
			mx, my = WINDOW_MANAGER:GetCursorPosition(cursorId)
		end
		local l, t, r, b = image:ProjectRectToScreenAndBuildAABB()
		local dx = mx-l
		local dy = my-t
		local nx = dx/(r-l)
		local ny = dy/(b-t)
		local worldX = originX+nx*nxratio
		local worldZ = originZ+ny*nzratio

		xEdit:SetText(zo_floor(worldX))
		yEdit:SetText(y)
		zEdit:SetText(zo_floor(worldZ))


	end





	local function ImageOnMouseUp(clickedControl, button, upInside, ctrl, alt, shift, command, source)
		--d(...)
		if image.dragging then
			OnDragStop()
		elseif button == MOUSE_BUTTON_INDEX_LEFT and upInside then
			-- do handler
			--d("left click pressed")
			SetSelectedMarker(emptyMarker)
			updateLastPlayerClickPositions(source)

		elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
			--d("right click pressed")
			local x,y = GetUIMousePosition()
			if cursorId and source == "gamepadCursor" then
				x, y = WINDOW_MANAGER:GetCursorPosition(cursorId)
			end
			createMarker(x,y)
		end
	end
	image:SetHandler("OnMouseUp", ImageOnMouseUp)

	






	







	local newControlPool = ZO_ControlPool:New("M0RMarkersTemplate", image)

	local function createControl(icon)
		local control, key = newControlPool:AcquireObject()
		control:SetHidden(false)
		control:SetSpace(SPACE_INTERFACE)
		control:SetScale(icon.size*0.20) -- 100 x 100, scale down to 20
		control.bgLayer = control:GetNamedChild("Background")
		control.highlight = control.bgLayer:GetNamedChild("Highlight")
		control.textLayer = control.bgLayer:GetNamedChild("Text")
		control:SetTransformNormalizedOriginPoint(0.5,0.5)

		--control:SetTransformScale(icon.size*0.1)

		local textMultiplier = MM.vars.fontScale or 1
		local fontFace = MM.vars.fontface or "GAMEPAD_BOLD_FONT"
		local fontEffect = MM.vars.fonteffect or "|thick-outline"
		control.textLayer:SetFont(string.format("$(%s)|$(GP_20)%s", fontFace, fontEffect))
		control.textLayer:SetScale(4*textMultiplier) -- 4 is default




		icon.control = control
		icon.key = key

		if icon.bgTexture then
			icon.control.bgLayer:SetHidden(false)
			icon.control.bgLayer:SetTexture(icon.bgTexture)
			icon.control.bgLayer:SetColor(unpack(icon.colour))
		end
		if icon.text then
			icon.control.textLayer:SetHidden(false)
			icon.control.textLayer:SetText(icon.text)
		end

		icon.control.highlight:SetHidden(true)
		icon.control:SetMouseEnabled(true)
		local function OnMouseUp(clickedControl, button, upInside, ctrl, alt, shift, command, source)
			if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
				SetSelectedMarker(icon)
				if shift then
					updateLastPlayerClickPositions()
				end
			elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
				local x,y = GetUIMousePosition()
				if cursorId and source == "gamepadCursor" then
					x, y = WINDOW_MANAGER:GetCursorPosition(cursorId)
				end

				if not shift then
					MM.ShowDialogue("Creating Marker",
						"You are currently trying to create a marker on top of an existing marker. It may be hard to select one of the stacked markers.\n\nWould you like to continue?",
						"You can hold shift to avoid this popup.",
						function() createMarker(x,y) end)
				else
					createMarker(x,y)
				end

				
			end
		end
		icon.control:SetHandler("OnMouseUp", OnMouseUp)

		return icon
	end
	function destroyControl(icon)
		icon.control:SetHidden(true)
		icon.control:ClearTransformRotation()
		icon.control.bgLayer:SetHidden(true)
		icon.control.textLayer:SetText("")
		icon.control.textLayer:SetHidden(true)
		icon.control.highlight:SetHidden(true)
		newControlPool:ReleaseObject(icon.key)
		icon.control = nil
		icon.key = nil
	end























	tileManager = ZO_WorldMapTiles_Manager:New(image)

	function tileManager:SetMapId(mapid, fromReload)
		self.mapid = mapid
		self:UpdateTextures()

		local preReloadScale
		local preReloadAnchor
		if fromReload then
			preReloadScale = image:GetScale()
			preReloadAnchor = {image:GetAnchor()}
		end
		image:SetScale(1)
		image:ClearAnchors()
		image:SetAnchor(CENTER, control, CENTER, 0, 0)




		

		for i,v in pairs(markerpreviews) do
			destroyControl(v)
			markerpreviews[i] = nil
		end

		local currentMapId = GetCurrentMapId()
		SetMapToMapId(self.mapid)
		local px, py, pz
		self.cZone, px, py, pz = GetUnitWorldPosition('player')
		for i,cMarker in pairs(currentZoneMarkers) do
			local nx,ny = GetNormalizedWorldPosition(self.cZone, cMarker.x, cMarker.y, cMarker.z) -- GetRawNormalizedWorldPosition
			if (nx >= 0 and nx <= 1 and ny >= 0 and ny <= 1) and (cMarker.y <= (mapStartY[self.mapid] or math.huge)) and (cMarker.y >= (mapEndY[self.mapid] or 0)) then
				local currentMarker = createControl(cMarker)

				local imageWidth, imageHeight = image:GetDimensions()
				local markerWidth, markerHeight = currentMarker.control:GetDimensions()
				currentMarker.initialXAnchor = nx*imageWidth
				currentMarker.initialYAnchor = ny*imageHeight
				currentMarker.control:SetAnchor(TOPLEFT,image,TOPLEFT, currentMarker.initialXAnchor-markerWidth/2, currentMarker.initialYAnchor-markerHeight/2)

				if currentMarker.orientation then
					currentMarker.control:SetTransformRotationZ(currentMarker.orientation[2])
				end

				currentMarker.index = i

				markerpreviews[i] = currentMarker
			end
		end

		local offset = 2000
		local pnx, pnz = GetNormalizedWorldPosition(self.cZone, px, py, pz)
		local onx, onz = GetNormalizedWorldPosition(self.cZone, px+offset, py, pz+offset)
		local dnx = onx-pnx
		local dnz = onz-pnz
		nxratio = offset/dnx
		nzratio = offset/dnz

		local offsetXtoOrigin = -pnx*nxratio
		local offsetZtoOrigin = -pnz*nzratio
		originX = px + offsetXtoOrigin
		originZ = pz + offsetZtoOrigin

		--d(GetRawNormalizedWorldPosition(self.cZone, originX, py, originZ))

		if fromReload then
			image:SetScale(preReloadScale)
			image:SetAnchor(preReloadAnchor[2],preReloadAnchor[3],preReloadAnchor[4],preReloadAnchor[5],preReloadAnchor[6])
		end
		changeScale(self, 0)
		SetMapToMapId(currentMapId)

		if M0RMarkerEditorToplevelMapSelectorGamepadButton and type(self.mapid) == "number" then
			local name, _, _, zoneIndex = GetMapInfoById(self.mapid)
			M0RMarkerEditorToplevelMapSelectorGamepadButton:SetText(string.format("%s (%d)", name, self.mapid))
		end

		SetSelectedMarker(emptyMarker)
	end

	function tileManager:ReloadMap()
		self:SetMapId(self.mapid, true)
	end

	function tileManager:UpdateMapData()
		local numHorizontalTiles, numVerticalTiles = GetMapNumTilesForMapId(self.mapid)

		self.horizontalTiles = numHorizontalTiles
		self.verticalTiles = numVerticalTiles
		self.totalTiles = numHorizontalTiles * numVerticalTiles
	end

	function tileManager:UpdateTextures()
		self:UpdateMapData()
		self:LayoutTiles()

		for i = 1, self.totalTiles do
			local tileControl = self:GetActiveObject(i)
			tileControl:SetTexture(GetMapTileTextureForMapId(self.mapid, i))
		end
	end

	function tileManager:LayoutTiles()
	    if self.horizontalTiles == nil then
	        self:UpdateMapData()
	    end

	    local tileWidth = ZosMapWidth / self.horizontalTiles
	    local tileHeight = ZosMapHeight / self.verticalTiles

	    self:ReleaseAllObjects()
	    
	    for i = 1, self.totalTiles do
	        local tileControl = self:AcquireObject(i)
	        tileControl:SetDimensions(tileWidth, tileHeight)
	        local xOffset = zo_mod(i - 1, self.horizontalTiles) * tileWidth
	        local yOffset = zo_floor((i - 1) / self.horizontalTiles) * tileHeight
	        tileControl:SetAnchor(TOPLEFT, self.parent, TOPLEFT, xOffset, yOffset)
	    end
	end




	tileManager:SetMapId(2688) -- 2686 -- 1545

	--/script tileManager:SetMapId(2687)
	-- GetUniversallyNormalizedMapInfo
	-- GetRawNormalizedWorldPosition



	




















	
	scene:AddFragment(ZO_HUDFadeSceneFragment:New(M0RMarkerEditorToplevel, DEFAULT_SCENE_TRANSITION_TIME, 0))


	scene:SetHideSceneConfirmationCallback(function(scene, nextSceneName, bypassHideSceneConfirmationReason)
		--a = {scene, nextSceneName, bypassHideSceneConfirmationReason}
		if scene.hideSceneConfirmationPush then
			scene:AcceptHideScene()
		else
			--d("Trying to hide")
			MM.ShowDialogue("Warning: Exiting Editor",
					"Are you sure you would like to close the editor?",
					"This will discard all changes you have made.",
					function() scene:AcceptHideScene() end
				)
		end
	end)

	--scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	-- or
	--scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)


	
	--SLASH_COMMANDS['/mmhideeditor'] = function() SCENE_MANAGER:Push('hud') end

	local function handleFakeClick(button)
		local clickedControl = WINDOW_MANAGER:GetControlAtCursor(cursorId)
		if clickedControl:GetOwningWindow() == ZO_KeybindStripControl then return end
		--d(clickedControl:GetName())
		local handler = clickedControl:GetHandler("OnMouseUp")
		if not handler then handler = clickedControl:GetHandler("OnClicked") end
		if not handler then handler = clickedControl:GetHandler("OnMouseDown") end
		if not handler then return end
		handler(clickedControl, button, true, false, false, false, false, "gamepadCursor")
	end


	local snapGamepadCursor

	local customDPAD = M0RMarkerEditorToplevel:GetNamedChild("DpadButton")
	customDPAD:SetCustomKeyIcon("esoui/art/buttons/gamepad/ps4/nav_ps4_dpad.dds")
	customDPAD:SetText("Snap Cursor")

	local customGPZoom = M0RMarkerEditorToplevel:GetNamedChild("GPZoom")
	customGPZoom:SetCustomKeyIcon("esoui/art/buttons/gamepad/scarlett/nav_scarlett_ltrt.dds")
	customGPZoom:SetText("Zoom")


	local gamepadKeybinds = {
		{
			name = "Select",
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = function() -- GAMEPAD LEFT CLICK
				handleFakeClick(MOUSE_BUTTON_INDEX_LEFT)
			end,
		},
		{
			name = "Place Marker",
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			keybind = "UI_SHORTCUT_SECONDARY",
			callback = function() handleFakeClick(MOUSE_BUTTON_INDEX_RIGHT) end,
		},


		{
			name = "Move Cursor",
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			keybind = "UI_SHORTCUT_LEFT_STICK",
		},
		{
			name = "Pan",
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			keybind = "UI_SHORTCUT_RIGHT_STICK",
		},
		--[[
		{
			name = "Zoom Out",
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			keybind = "UI_SHORTCUT_LEFT_TRIGGER",
		},
		{
			name = "Zoom In",
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
		},
		--]]
		{
			--order = 5,
			keybind = "CUSTOM_M0R_MARKERS_EDITOR_ZOOM",
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			customKeybindControl = customGPZoom,
			callback = function() end,
		},






		{
			name = "Snap to Mid",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			keybind = "UI_SHORTCUT_INPUT_UP",
			ethereal = true,
			callback = function()
				if (GetGamepadLeftStickY() == 0) and (GetGamepadRightStickY() == 0) then
					snapGamepadCursor("SnapPointMid")
				end
			end,
		},
		{
			name = "Snap to Discard",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			keybind = "UI_SHORTCUT_INPUT_DOWN",
			ethereal = true,
			callback = function()
				if (GetGamepadLeftStickY() == 0) and (GetGamepadRightStickY() == 0) then
					snapGamepadCursor("SnapPointApply")
				end
			end,
		},
		{
			name = "Snap to Left",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			keybind = "UI_SHORTCUT_INPUT_LEFT",
			ethereal = true,
			callback = function()
				if (GetGamepadLeftStickX() == 0) and (GetGamepadRightStickX() == 0) then
					snapGamepadCursor("SnapPointLeft")
				end
			end,
		},
		{
			name = "Snap to Right",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			keybind = "UI_SHORTCUT_INPUT_RIGHT",
			ethereal = true,
			callback = function()
				if (GetGamepadLeftStickX() == 0) and (GetGamepadRightStickX() == 0) then
					snapGamepadCursor("SnapPointRight")
				end
			end,
		},

		{
			--name = "SECONDARY", -- |t30:30:/esoui/art/icons/icon_rmb.dds|t 
			order = 5,
			keybind = "CUSTOM_M0R_MARKERS_EDITOR_SNAP",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			customKeybindControl = customDPAD,
			callback = function() end,
		},



		{
			name = "|c98FB98Save|r",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			keybind = "UI_SHORTCUT_TERTIARY",
			callback = function() M0RMarkers.editorSavePressed() end,
		},

		{
			name = "|cFFB6C1Exit|r",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			keybind = "UI_SHORTCUT_NEGATIVE",
			callback = function() SCENE_MANAGER:Push('hud') end,
		}
	}


	local customLeft = M0RMarkerEditorToplevel:GetNamedChild("LeftMouseButton")
	customLeft:SetCustomKeyIcon("EsoUI/Art/Miscellaneous/icon_LMB.dds")
	customLeft:SetText("Select")
	local customRight = M0RMarkerEditorToplevel:GetNamedChild("RightMouseButton")
	customRight:SetCustomKeyIcon("EsoUI/Art/Miscellaneous/icon_RMB.dds")
	customRight:SetText("Place Marker")

	local keybinds = {
		{
			--name = "PRIMARY", -- |t30:30:/esoui/art/icons/icon_lmb.dds|t 
			order = 1,
			keybind = "CUSTOM_M0R_MARKERS_EDITOR_LEFT",
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			customKeybindControl = customLeft,
			callback = function() end,
		},
		{
			--name = "SECONDARY", -- |t30:30:/esoui/art/icons/icon_rmb.dds|t 
			order = 2,
			keybind = "CUSTOM_M0R_MARKERS_EDITOR_RIGHT",
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			customKeybindControl = customRight,
			callback = function() end,
		},
		{
			--name = "SECONDARY", -- |t30:30:/esoui/art/icons/icon_rmb.dds|t 
			order = 2,
			name = "Save Profile",
			keybind = "CUSTOM_M0R_MARKERS_EDITOR_SAVE",
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			callback = MM.editorSavePressed,
		},
	}

	local cursorX = 0
	local cursorY = 0
	local oldcursorX = 0
	local oldcursorY = 0
	local function gamepadVirtualMouseLoop()
		if ZO_Dialogs_IsShowingDialog() then return end
		cursorX = cursorX + (GetGamepadLeftStickX() or 0)*10
		cursorY = cursorY - (GetGamepadLeftStickY() or 0)*10
		

		local scaleDelta = GetGamepadRightTriggerMagnitude() - GetGamepadLeftTriggerMagnitude()
		local panX = (GetGamepadRightStickX() or 0)*20
		local panY = (GetGamepadRightStickY() or 0)*20

		if (scaleDelta ~= 0) or (not ((panX == 0) and (panY == 0))) then
			_, _, _, _, image.startOriginX, image.startOriginY = image:GetAnchor()
		end

		if scaleDelta ~= 0 then
			changeScale(nil, scaleDelta, "gamepadCursor")
		end



		if not ((panX == 0) and (panY == 0)) then
			--_, _, _, _, image.startOriginX, image.startOriginY = image:GetAnchor()
			updateTick("customDelta", -panX, panY)
		end


		if (cursorX ~= oldcursorX) or (cursorY ~= oldcursorY) then
			local toplevelscale = M0RMarkerEditorToplevel:GetScale() or 1
			M0RMarkerEditorToplevelCursor:ClearAnchors()
			M0RMarkerEditorToplevelCursor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cursorX/toplevelscale, cursorY/toplevelscale)
			WINDOW_MANAGER:UpdateCursorPosition(cursorId, cursorX, cursorY)

			oldcursorX = cursorX
			oldcursorY = cursorY
		end
	end

	local function startGamepad()
		cursorX = GuiRoot:GetWidth()/2
		cursorY = GuiRoot:GetHeight()/2

		if cursorId then
			WINDOW_MANAGER:DestroyCursor(cursorId)
			cursorId = nil
		end
		cursorId = WINDOW_MANAGER:CreateCursor(cursorX, cursorY)

		M0RMarkerEditorToplevelCursor:SetHidden(false)
		EVENT_MANAGER:RegisterForUpdate("M0RMarkerEditorCursor", 0, gamepadVirtualMouseLoop)
	end

	local function endGamepad()
		EVENT_MANAGER:UnregisterForUpdate("M0RMarkerEditorCursor")
		M0RMarkerEditorToplevelCursor:SetHidden(true)

		cursorX = 0
		cursorY = 0
		oldcursorX = 0
		oldcursorY = 0

		if cursorId then
			WINDOW_MANAGER:DestroyCursor(cursorId)
			cursorId = nil
		end
	end


	snapGamepadCursor = function(location)
		local control = M0RMarkerEditorToplevel:GetNamedChild(location)
		if control then
			cursorX = control:GetLeft()
			cursorY = control:GetTop()
		end
	end


	scene:RegisterCallback("StateChange",  function(oldState, newState)
		if (newState == SCENE_SHOWING) then

			--ZosMapWidth, ZosMapHeight = ZO_WorldMap:GetDimensions()
			_, guiHeight = GuiRoot:GetDimensions()
			ZosMapWidth = guiHeight*0.75
			ZosMapHeight = guiHeight*0.75

			control:SetDimensions(ZosMapWidth, ZosMapHeight)
			image:SetDimensions(ZosMapWidth, ZosMapHeight)

			control:SetScale(835/ZosMapWidth)
			M0RMarkerEditorToplevel:SetScale(ZosMapWidth/835)

				

			if IsInGamepadPreferredMode() then
				scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)

				M0RMarkerEditorToplevelMapSelectorPicker:SetHidden(true)
				M0RMarkerEditorToplevelMapSelectorGamepadButton:SetHidden(false)

				KEYBIND_STRIP:AddKeybindButtonGroup(gamepadKeybinds)
				startGamepad()
			else

				M0RMarkerEditorToplevelMapSelectorPicker:SetHidden(false)
				M0RMarkerEditorToplevelMapSelectorGamepadButton:SetHidden(true)

				KEYBIND_STRIP:AddKeybindButtonGroup(keybinds)
				scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
			end

			local oldMap = GetCurrentMapId()
			SetMapToPlayerLocation()
			local currentMapId = GetCurrentMapId()
			SetMapToMapId(oldMap)

			local currentZone = GetUnitRawWorldPosition('player')
			local currentZoneLookup = M0RMarkers.mapZoneLookup[currentZone]

			currentZoneMarkers = {}
			ZO_CombineNumericallyIndexedTables(currentZoneMarkers, ZO_DeepTableCopy(MM.loadedMarkers.facing), ZO_DeepTableCopy(MM.loadedMarkers.ground))

			local comboBox = M0RMarkers.mapSelectorEditbox
			if comboBox then
				comboBox:ClearItems()
				if currentZoneLookup then
					for i,v in pairs(currentZoneLookup) do
						local stringName = string.format(tostring(v).." ("..tostring(i)..")")
						local entry = comboBox:CreateItemEntry(stringName, function()
							--d("Selected "..v)
							if tileManager then
								tileManager:SetMapId(i)
							end
						end, true)
						comboBox:AddItem(entry)

						if i == currentMapId then
							comboBox:ItemSelectedClickHelper(entry)
						end
					end
				else -- if the current zone couldnt be found in the lookup, just display the current map index.
					local name = GetMapInfoById(currentMapId)
					local stringName = string.format(tostring(name).." ("..tostring(currentMapId)..")")
					local entry = comboBox:CreateItemEntry(stringName, function()
						if tileManager then
							tileManager:SetMapId(currentMapId)
						end
					end, true)
					comboBox:AddItem(entry)
					comboBox:ItemSelectedClickHelper(entry)
				end
			end

		elseif (newState == SCENE_HIDDEN) then
			if IsInGamepadPreferredMode() then
				KEYBIND_STRIP:RemoveKeybindButtonGroup(gamepadKeybinds)
				scene:RemoveFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
			else
				KEYBIND_STRIP:RemoveKeybindButtonGroup(keybinds)
				scene:RemoveFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
			end
			endGamepad()

			-- destroy all marker previews
			for i,v in pairs(markerpreviews) do
				destroyControl(v)
				markerpreviews[i] = nil
			end
		end
	end)



	M0RMarkers.image = image -- debug stuff

	M0RMarkers.editorTileManager = tileManager

end