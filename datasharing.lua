local MM = M0RMarkers

MM.protocols = {}
local protocols = MM.protocols
MM.handlers = {}
local handlers = MM.handlers


function MM.initSharing()
	local LGB = LibGroupBroadcast
	if LGB then
		local handler = LGB:RegisterHandler("M0RMarkers")
		handler:SetDisplayName("M0R Markers")
		handler:SetDescription("Tool for placing markers in the 3d world!")

		
		protocols.header = handler:DeclareProtocol(501, "M0RMarkersHeader")
		protocols.header:AddField(LGB.CreateOptionalField(LGB.CreateNumericField("length", {numBits=11, trimValues=true})))
		protocols.header:AddField(LGB.CreateFlagField("sending")) -- either true or false. if true then just started. if false then just ended. true requires length to exist
		protocols.header:OnData(handlers.onHeader)
		protocols.header:Finalize({replaceQueuedMessages = false})
		

		protocols.data = handler:DeclareProtocol(500, "M0RMarkersData")
		protocols.data:AddField(LGB.CreateNumericField("position", {numBits=11, trimValues=true}))
		protocols.data:AddField(LGB.CreateStringField("data", {minLength=0, maxLength=26}))
		protocols.data:OnData(handlers.onData)
		protocols.data:Finalize({replaceQueuedMessages = false})
	else
		protocols.header = {}
		function protocols.header:Send()
			d("You cannot send markers locally without LibGroupBroadcast")
		end
		protocols.data = {}
		function protocols.data:Send()
			d("You cannot send markers locally without LibGroupBroadcast")
		end
	end
end

function MM.shareCurrentZone()
	local zoneString = MM.compressLoaded()
	MM.send(zoneString)
end


SLASH_COMMANDS['/mmtest'] = MM.shareCurrentZone


local currentlySending = false
local currentString = ""
local currentPosition = -1
local currentLength = -2
local lastTime = 0
local startTime = 0

function MM.send(zoneString)
	if currentlySending then d("Cant start sending, as previous send is in progress") return end
	if IsUnitGrouped('player') then
		if not IsUnitGroupLeader('player') then
			d("You must be the group leader to share markers!")
		end
		currentString = zoneString

		length = math.ceil(#zoneString / 25)
		d("length of "..length)


		--protocols.header:Send({
		--	sending = true,
		--	length = length
		--})
		
		currentPosition = 0
		currentLength = length
		currentlySending = true
		currentlyListeningTo = GetUnitDisplayName('player') 
		MM.sendTick()
		lastTime = os.rawclock()
		startTime = os.rawclock()

		M0RMarkerProgressMeterBar:SetValue(0)
		M0RMarkerProgressMeterEstimated:SetText(string.format("Estimated Time Remaining: %.1fs", 0))
		M0RMarkerProgressMeterElapsed:SetText(string.format("Elapsed Time: %.1fs", 0))
		M0RMarkerProgressMeter:SetHidden(false)


	end
end



function MM.sendTick()
	local currentSplice = string.sub(currentString, (currentPosition*25)+1, (currentPosition*25)+25)
	--d("Sending: "..currentSplice)
	if currentSplice == "" then
		protocols.header:Send({
			sending = false,
			length = length
		})
		d("FINSIHED")
		return
	end
	protocols.data:Send({
		position = currentPosition+1,
		data = currentSplice
	})
	--d("Sending: "..currentSplice)
	currentPosition = currentPosition + 1
end


local currentlyListeningTo = ""
local currentData = {} -- todo: add the local back
local currentlyListening = false
local expectedDataLength = 0
function handlers.onHeader(unitTag, data)
	--d("finished recieving data")
	--a = data


	if AreUnitsEqual('player', unitTag) then
		currentlySending = false
		M0RMarkerProgressMeter:SetHidden(true)
		d("finished sending data")
		print(table.concat(currentData))
		d(string.format("Time Taken: %.1f seconds", (os.rawclock()-startTime)/1000))
		--return --TODO: MAKE SURE THIS IS UNCOMMENTED
	end

	local failed = false
	d("expected length: "..tostring(data.length))
	for i=1, tonumber(data.length) do
		--d(i)
		if currentData[i] == nil then
			d("Failed to get data with index: "..i)
			failed = true
		end
	end
	if failed then
		d("Something Failed when recieving data")
		return
	end
	d("finished recieving data")
	local parsedString = table.concat(currentData)
	print(parsedString)
	d(string.format("Time Taken: %.1f seconds", (os.rawclock()-startTime)/1000))

	local _,_, zone, timestamp, mins, sizes, pitch, yaw, colour, texture, positions = string.find(parsedString, "<(.-)](.-)](.-)](.-)](.-)](.-)](.-)](.-)](.-)>")
	if (zone == nil) or (timestamp == nil) then
		d("Something Failed when recieving data")
		return
	else
		local userName = GetUnitDisplayName(unitTag)
		local newProfileName = string.format("%s Shared: %s", userName, os.date("%Y/%m/%d %I:%M %p", tonumber(timestamp))) --%d/%m/%y %I:%M %p
		local intZone = tonumber(zone)
		print(newProfileName)

		MM.ShowDialogue("Recieved Markers from "..userName,
			string.format("Would you like to import these markers for %s?\nThis will be saved to a profile called: |cFFD700%s|r", GetZoneNameById(intZone), newProfileName),
			string.format("These Markers were last edited at:\n|c0DC1CF%s|r",os.date("%a, %b %d %Y - %I:%M %p", MM.loadedMarkers.currentTimestamp)),
			function()
				MM.vars.loadedProfile[intZone] = newProfileName
				

				local strings = {}
				--if parsedString == nil then parsedString = "" end
				for i=1,10 do -- split into 1900 length strings
					local currentString = string.sub(parsedString, (i-1)*1900+1, i*1900)
					if (currentString == "") or (currentString == nil) then
						break
					else
						strings[#strings+1] = currentString
					end
				end
				if MM.vars.Profiles[intZone] then
					MM.vars.Profiles[intZone][newProfileName] = strings
				else
					MM.vars.Profiles[intZone] = {
						[newProfileName] = strings
					}
				end

				local currentZone = GetUnitWorldPosition('player')
				if currentZone == intZone then
					MM.loadProfile(newProfileName)
				end

				MM.currentAdditionalProfiles = {}
				MM.multipleProfilesLoaded = false
				if M0RMarkersProfileDropdown then
					M0RMarkersProfileDropdown:UpdateValue()
				end
				if M0RMarkersProfilesCurrentLoadedProfile then M0RMarkersProfilesCurrentLoadedProfile:UpdateValue() end
				d("Saved Transmitted Markers!")
			end
		)

	end

	--[[

	--d("Header Recieved")
	if data.sending and (not currentlyListening) then
		currentlyListeningTo = GetUnitDisplayName(unitTag)
		currentData = {}
		currentlyListening = true
		expectedDataLength = data.length
	elseif (not data.sending) and currentlyListening then
		if GetUnitDisplayName(unitTag) == currentlyListeningTo then
			-- check expectedDataLength vs the data recieved
			
		end
	end
	--]]
end


local times = {}
local function average(data)
	local totalI = 0
	local totalV = 0
	for i=1,#data do
		totalV = totalV+data[i]
		totalI = totalI+1
	end
	return totalV/totalI
end

function handlers.onData(unitTag, data)
		if AreUnitsEqual('player', unitTag) then -- only transmitter should get a progress bar, as header is not sent before
			table.insert(times, 1, os.rawclock()-lastTime)
			times[11] = nil

			local averageTime = average(times)
			lastTime = os.rawclock()
			--d("Progress: "..tostring(tonumber(data.position)/length*100).."% - Time Taken: "..times[#times]..". Expected time remaining: "..tostring(averageTime*(length-tonumber(data.position))))
			print(string.format("Progress: %.2f%% - Time Taken: %dms - Expected Time Remaining: %dms", tonumber(data.position)/length*100, times[1], averageTime*(length-tonumber(data.position))))
			ZO_StatusBar_SmoothTransition(M0RMarkerProgressMeterBar, tonumber(data.position)/length*100, 100)
			M0RMarkerProgressMeterEstimated:SetText(string.format("Estimated Time Remaining: %.1fs", averageTime*(length-tonumber(data.position))/1000))
			M0RMarkerProgressMeterElapsed:SetText(string.format("Elapsed Time: %.1fs", (os.rawclock()-startTime)/1000))
			MM.sendTick()
 		end
		currentData[data.position] = data.data
	--end
end