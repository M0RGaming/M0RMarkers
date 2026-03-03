--/script

local MM = M0RMarkers
local control


function MM.editorInit()


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

	x = GetAllMapIdsByZoneId()



	--M0RMarkerEditorToplevel:SetHidden(false)
	--SLASH_COMMANDS['/mmhideeditor'] = function() M0RMarkerEditorToplevel:SetHidden(true) end
	--SLASH_COMMANDS['/mmshoweditor'] = function() M0RMarkerEditorToplevel:SetHidden(false) end



	wm = WINDOW_MANAGER

	control = wm:CreateControl("BackgroundTest", M0RMarkerEditorToplevel, CT_BACKDROP)
	control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	control:SetDimensions(ZO_MAP_CONSTANTS.MAP_WIDTH, ZO_MAP_CONSTANTS.MAP_HEIGHT)
	--control:SetDimensions(835, 835)
	control:SetCenterColor(0, 0, 0, 0)
	control:SetEdgeColor(0, 0, 0, 1)
	control:SetAutoRectClipChildren(true)


	image = wm:CreateControl("ImageTest", control, CT_CONTROL)
	image:SetAnchor(CENTER, control, CENTER, 0, 0)
	image:SetDimensions(ZO_MAP_CONSTANTS.MAP_WIDTH, ZO_MAP_CONSTANTS.MAP_HEIGHT)
	--image:SetDimensions(835, 835)
	--image:SetTexture("esoui/art/crowncrates/psijic/crowncrate_psijic_back.dds")



	control:SetMouseEnabled(true)

	--control:SetTransformScale(835/ZO_MAP_CONSTANTS.MAP_WIDTH)

	--M0RMarkerEditorToplevel:SetTransformScale(ZO_MAP_CONSTANTS.MAP_WIDTH/835)



	control:SetScale(835/ZO_MAP_CONSTANTS.MAP_WIDTH)
	M0RMarkerEditorToplevel:SetScale(ZO_MAP_CONSTANTS.MAP_WIDTH/835)


	image:ClearAnchors()
	image:SetAnchor(CENTER, control, CENTER, 0, 0)








	local currentZoneMarkers = {}
	local markerpreviews = {}
	local selectedMarker = 0




	local function SetSelectedMarker(currentMarker)
		local markerIndex = currentMarker.index
		selectedMarker = markerIndex


		local toplevel = M0RMarkerEditorToplevel
		local selectedMarkerText = toplevel:GetNamedChild("MarkerDetails"):GetNamedChild("Text")
		local markerSize = toplevel:GetNamedChild("MarkerSize"):GetNamedChild("Edit")
		local textureEdit = toplevel:GetNamedChild("TextureSelector"):GetNamedChild("Texture"):GetNamedChild("Edit")
		local yawEdit = toplevel:GetNamedChild("Yaw"):GetNamedChild("Edit")
		local pitchEdit = toplevel:GetNamedChild("Pitch"):GetNamedChild("Edit")
		local xEdit = toplevel:GetNamedChild("X"):GetNamedChild("Edit")
		local yEdit = toplevel:GetNamedChild("Y"):GetNamedChild("Edit")
		local zEdit = toplevel:GetNamedChild("Z"):GetNamedChild("Edit")
		local textEditor = toplevel:GetNamedChild("TextEditor")
		local colourEdit = toplevel:GetNamedChild("ColourSelector"):GetNamedChild("ColourHex"):GetNamedChild("Edit")
		-- for the x y z, check the following to see if the marker is on the page. Dont allow user to move marker off of page (when applying)
		-- local nx,ny = GetRawNormalizedWorldPosition(self.cZone, cMarker.x, cMarker.y, cMarker.z)
		-- if (nx >= 0 and nx <= 1 and ny >= 0 and ny <= 1) then

		selectedMarkerText:SetText(string.format("Selected Marker: %d", selectedMarker))
		markerSize:SetText(currentMarker.size or "")
		textureEdit:SetText(currentMarker.bgTexture or "")
		if currentMarker.orientation then
			yawEdit:SetText(string.format("%.1f",zo_deg(currentMarker.orientation[1])))
			pitchEdit:SetText(string.format("%.1f",zo_deg(currentMarker.orientation[2])))
		else
			yawEdit:SetText("")
			pitchEdit:SetText("")
		end
		xEdit:SetText(currentMarker.x or "")
		yEdit:SetText(currentMarker.y or "")
		zEdit:SetText(currentMarker.z or "")
		textEditor:SetText(currentMarker.text or "")


		local hexColour
		if currentMarker.colour then
			hexColour = ZO_ColorDef.FloatsToHex(unpack(currentMarker.colour))
		end
		colourEdit:SetText(hexColour or "")


	end
	-- apply will change the currentZoneMarkers, and rerun the code for marker setup in tileManager:SetMapId(mapid)
	-- editing position will maybe change the location live (idk, might be too much work)
	-- save will populate the currentZoneMarkers back to MM.loadedMarkers, save, and load it again.











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
		local maxAnchor = (ZO_MAP_CONSTANTS.MAP_WIDTH*scale)-ZO_MAP_CONSTANTS.MAP_WIDTH
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



	local emptyMarker = {
		index = 0
	}

	local function OnMouseUp(clickedControl, button, upInside)
	    if image.dragging then
	        OnDragStop()
	    elseif button == MOUSE_BUTTON_INDEX_LEFT and upInside then
	        -- do handler
	        d("left click pressed")
	        SetSelectedMarker(emptyMarker)
	    elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
	    	d("right click pressed")
	    end
	end
	image:SetHandler("OnMouseUp", OnMouseUp)

	






	







	newControlPool = ZO_ControlPool:New("M0RMarkersTemplate", image)

	local function createControl(icon)
		local control, key = newControlPool:AcquireObject()
		control:SetHidden(false)
		control:SetSpace(SPACE_INTERFACE)
		control:SetScale(icon.size*0.20) -- 100 x 100, scale down to 20
		control.bgLayer = control:GetNamedChild("Background")
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

		icon.control:SetMouseEnabled(true)
		local function OnMouseUp(clickedControl, button, upInside)
		    if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
		        -- do handler
		        d("Clicked marker")
		        a = icon
		        SetSelectedMarker(icon)
		    elseif button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
		    	d("Right clicked marker")
		    end
		end
		icon.control:SetHandler("OnMouseUp", OnMouseUp)

		return icon
	end
	local function destroyControl(icon)
		icon.control:SetHidden(true)
		icon.control:ClearTransformRotation()
		icon.control.bgLayer:SetHidden(true)
		icon.control.textLayer:SetText("")
		icon.control.textLayer:SetHidden(true)
		newControlPool:ReleaseObject(icon.key)
		icon.control = nil
		icon.key = nil
	end






	tileManager = ZO_WorldMapTiles_Manager:New(image)

	function tileManager:SetMapId(mapid)
		self.mapid = mapid
		self:UpdateTextures()



		image:SetScale(1)
		image:ClearAnchors()
		image:SetAnchor(CENTER, control, CENTER, 0, 0)




		

		for i,v in pairs(markerpreviews) do
			destroyControl(v)
			markerpreviews[i] = nil
		end

		local currentMapId = GetCurrentMapId()
		SetMapToMapId(self.mapid)
		self.cZone = GetUnitRawWorldPosition('player')
		for i,cMarker in pairs(currentZoneMarkers) do
			local nx,ny = GetRawNormalizedWorldPosition(self.cZone, cMarker.x, cMarker.y, cMarker.z)
			if (nx >= 0 and nx <= 1 and ny >= 0 and ny <= 1) then
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

				markerpreviews[#markerpreviews+1] = currentMarker
			end
		end
		changeScale(self, 0)
		SetMapToMapId(currentMapId)
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




	tileManager:SetMapId(2688) -- 2686 -- 1545

	--/script tileManager:SetMapId(2687)
	-- GetUniversallyNormalizedMapInfo
	-- GetRawNormalizedWorldPosition



	scene = ZO_InteractScene:New("M0RMarkerEditorScene", SCENE_MANAGER, {
	    type = "Banking",
	    interactTypes = { INTERACTION_BANK },
	})
	scene:AddFragment(ZO_FadeSceneFragment:New(M0RMarkerEditorToplevel))

	--scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	-- or
	--scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)


	SLASH_COMMANDS['/showeditor'] = function() SCENE_MANAGER:Push('M0RMarkerEditorScene') end
	SLASH_COMMANDS['/hideeditor'] = function() SCENE_MANAGER:Push('hud') end

	local gamepadKeybinds = {
	    {
	        name = "Select",
	        alignment = KEYBIND_STRIP_ALIGN_LEFT,
	        keybind = "UI_SHORTCUT_PRIMARY",
	        callback = function() d("Pressed Select") end,
	    },
	    {
	        name = "Place Marker",
	        alignment = KEYBIND_STRIP_ALIGN_LEFT,
	        keybind = "UI_SHORTCUT_SECONDARY",
	        callback = function() d("Pressed Place") end,
	    },


	    {
	        name = "Move Cursor",
	        alignment = KEYBIND_STRIP_ALIGN_CENTER,
	        keybind = "UI_SHORTCUT_LEFT_STICK",
	    },
	    {
	        name = "Pan Map",
	        alignment = KEYBIND_STRIP_ALIGN_CENTER,
	        keybind = "UI_SHORTCUT_RIGHT_STICK",
	    },
	    {
	        name = "Zoom In",
	        alignment = KEYBIND_STRIP_ALIGN_CENTER,
	        keybind = "UI_SHORTCUT_LEFT_TRIGGER",
	    },
	    {
	        name = "Zoom Out",
	        alignment = KEYBIND_STRIP_ALIGN_CENTER,
	        keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
	    },


	    {
	        name = "Exit",
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
	    alignment = KEYBIND_STRIP_ALIGN_LEFT,
	    {
	        --name = "PRIMARY", -- |t30:30:/esoui/art/icons/icon_lmb.dds|t 
	        order = 1,
	        keybind = "CUSTOM_M0R_MARKERS_EDITOR_LEFT",
	        customKeybindControl = customLeft,
	        callback = function() end,
	    },
	    {
	        --name = "SECONDARY", -- |t30:30:/esoui/art/icons/icon_rmb.dds|t 
	        order = 2,
	        keybind = "CUSTOM_M0R_MARKERS_EDITOR_RIGHT",
	        customKeybindControl = customRight,
	        callback = function() end,
	    },
	    --[[
	    {
	        name = "NEGATIVE",
	        icon = "/esoui/art/icons/icon_rmb.dds",
	        order = 2,
	        keybind = CUSTOM_LORE_READER,
	        callback = function() end,
	    }
	    --]]
	}


	local cursorX = 0
	local cursorY = 0
	local function gamepadVirtualMouseLoop()
		cursorX = cursorX + (GetGamepadLeftStickX() or 0)*10
		cursorY = cursorY - (GetGamepadLeftStickY() or 0)*10
		

		local scaleDelta = GetGamepadLeftTriggerMagnitude() - GetGamepadRightTriggerMagnitude()
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

		M0RMarkerEditorToplevelCursor:ClearAnchors()
		M0RMarkerEditorToplevelCursor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cursorX, cursorY)
	end

	local function startGamepad()
		cursorX = GuiRoot:GetWidth()/2
		cursorY = GuiRoot:GetHeight()/2
		M0RMarkerEditorToplevelCursor:SetHidden(false)
		EVENT_MANAGER:RegisterForUpdate("M0RMarkerEditorCursor", 0, gamepadVirtualMouseLoop)
	end

	local function endGamepad()
		EVENT_MANAGER:UnregisterForUpdate("M0RMarkerEditorCursor")
		M0RMarkerEditorToplevelCursor:SetHidden(true)
	end


	scene:RegisterCallback("StateChange",  function(oldState, newState)
		if (newState == SCENE_SHOWING) then

			control:SetDimensions(ZO_MAP_CONSTANTS.MAP_WIDTH, ZO_MAP_CONSTANTS.MAP_HEIGHT)
			image:SetDimensions(ZO_MAP_CONSTANTS.MAP_WIDTH, ZO_MAP_CONSTANTS.MAP_HEIGHT)

			control:SetScale(835/ZO_MAP_CONSTANTS.MAP_WIDTH)
			M0RMarkerEditorToplevel:SetScale(ZO_MAP_CONSTANTS.MAP_WIDTH/835)

				

		    if IsInGamepadPreferredMode() then
				scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)

		    	KEYBIND_STRIP:AddKeybindButtonGroup(gamepadKeybinds)
		    	startGamepad()
		    else
		    	KEYBIND_STRIP:AddKeybindButtonGroup(keybinds)
		    	scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
		    end


			local currentMapId = GetCurrentMapId()
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
							d("Selected "..v)
							if tileManager then
								tileManager:SetMapId(i)
							end
						end, true)
						comboBox:AddItem(entry)

						if i == currentMapId then
							comboBox:ItemSelectedClickHelper(entry)
						end
					end
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
		end
	end)

end


--[[




<Label name="$(parent)Colour" font="ZoFontGamepadBold20" horizontalAlignment="1" verticalAlignment="1" text="Colour">
	<Anchor point="TOPLEFT" relativePoint="TOP" relativeTo="$(parent)" offsetX="12.5" offsetY="10" />
	<Dimensions x="120" y="25" />
	<Controls>
		<Control name="$(parent)Picker" inherits="ZO_ComboBox" mouseEnabled="true" tier="HIGH" >
			<Dimensions x="135" y="25" />
			<Anchor point="TOP" relativePoint="BOTTOM" relativeTo="$(parent)" offsetY="0" />
			
			<OnInitialized>
				function M0RMarkers.Settings.InitColourPicker()
					local comboBox = ZO_ComboBox:New(self)
					comboBox:SetSortsItems(false)
					local currentColourHex = M0RMarkers.Settings.colourLookup[ZO_ColorDef.FloatsToHex(unpack(M0RMarkers.Settings.quickSelections.rgba))]

					-- ZO_ComboBox_ObjectFromContainer(self)
					for i,v in ipairs(M0RMarkers.Settings.colourPresets) do
						local entry = comboBox:CreateItemEntry(v, function()
							M0RMarkers.print("Selected "..v)
							M0RMarkers.Settings.quickSelections.rgba = M0RMarkers.Settings.colourLookup[v]
						end, true)
						comboBox:AddItem(entry)

						if v == currentColourHex then
							comboBox:ItemSelectedClickHelper(entry)
						end
					end
				end
			</OnInitialized>
		</Control>
	</Controls>
</Label>
--]]