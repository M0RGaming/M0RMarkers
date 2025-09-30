local MM = M0RMarkers

MM.protocols = {}
local protocols = MM.protocols
MM.handlers = {}
local handlers = MM.handlers


function MM.initSharing()
	local LGB = LibGroupBroadcast
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
	--if currentlySending then d("Cant start sending, as previous send is in progress") return end
	if IsUnitGrouped('player') then
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
currentData = {} -- todo: add the local back
local currentlyListening = false
local expectedDataLength = 0
function handlers.onHeader(unitTag, data)
	d("finished recieving data")
	a = data
	d(table.concat(currentData))
	d(string.format("Time Taken: %.1f seconds", (os.rawclock()-startTime)/1000))
	--d("Header Recieved")
	if data.sending and (not currentlyListening) then
		currentlyListeningTo = GetUnitDisplayName(unitTag)
		currentData = {}
		currentlyListening = true
		expectedDataLength = data.length
	elseif (not data.sending) and currentlyListening then
		if GetUnitDisplayName(unitTag) == currentlyListeningTo then
			-- check expectedDataLength vs the data recieved
			d("finished recieving data")
		end
	end
end


local times = {}
local function average(data)
	local totalI = 0
	local totalV = 0
	for i,v in pairs(data) do
		totalV = totalV+v
		totalI = totalI+1
	end
	return totalV/totalI
end

function handlers.onData(unitTag, data)
	--d("Data Recieved")
	--d("Recieved data ".. tostring(data.position).. " from "..unitTag)
	--if GetUnitDisplayName(unitTag) == currentlyListeningTo then
		if AreUnitsEqual('player', unitTag) then
			--d("Recieved data ".. tonumber(data.position))
			times[#times+1] = os.rawclock()-lastTime
			local averageTime = average(times)
			lastTime = os.rawclock()
			--d("Progress: "..tostring(tonumber(data.position)/length*100).."% - Time Taken: "..times[#times]..". Expected time remaining: "..tostring(averageTime*(length-tonumber(data.position))))
			d(string.format("Progress: %.2f%% - Time Taken: %dms - Expected Time Remaining: %dms", tonumber(data.position)/length*100, times[#times], averageTime*(length-tonumber(data.position))))
			ZO_StatusBar_SmoothTransition(M0RMarkerProgressMeterBar, tonumber(data.position)/length*100, 100)
			M0RMarkerProgressMeterEstimated:SetText(string.format("Estimated Time Remaining: %.1fs", averageTime*(length-tonumber(data.position))/1000))
			M0RMarkerProgressMeterElapsed:SetText(string.format("Elapsed Time: %.1fs", (os.rawclock()-startTime)/1000))
			MM.sendTick()
 		end
		currentData[data.position] = data.data
	--end
end