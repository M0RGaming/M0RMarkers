local MM = M0RMarkers

local protocols = {}
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

	protocols.data = handler:DeclareProtocol(502, "M0RMarkersData")
	protocols.data:AddField(LGB.CreateNumericField("position", {numBits=11, trimValues=true}))
	protocols.data:AddField(LGB.CreateStringField("data", {minLength=1, maxLength=5}))
	protocols.data:OnData(handlers.onData)
	protocols.data:Finalize({replaceQueuedMessages = false})
end

function MM.shareCurrentZone()
	local zoneString = MM.compressLoaded()
	MM.send(zoneString)
end



local currentlySending = false
local currentString = ""
local currentPosition = -1
local currentLength = -2
function MM.send(zoneString)
	if currentlySending then d("Cant start sending, as previous send is in progress") return end
	if IsUnitGrouped('player') then
		currentString = zoneString

		length = math.ceil(#zoneString / 5)
		d("length of "..length)

		protocols.header:Send({
			sending = true,
			length = length
		})
		currentPosition = 1
		currentLength = length
		currentlySending = true
		EVENT_MANAGER:RegisterForUpdate("M0RMarkerDataSendLoop", 2000, MM.sendTick)
		MM.sendTick()
	end
end

function MM.sendTick()
	for i=currentPosition, currentPosition+5 do
		d(i)
		if i > currentLength then
			-- break loop
			return
			--[[
			EVENT_MANAGER:UnregisterForUpdate("M0RMarkerDataSendLoop")
			protocols.header:Send({
				sending = false,
			})
			currentlySending = false
			currentString = ""
			currentPosition = -1
			currentLength = -2
			return
			--]]
		end
		local currentSplice = string.sub(currentString, i*5, (i+4)*5)
		protocols.data:Send({
			position = i,
			data = currentSplice
		})
	end
	currentPosition = currentPosition + 6
end


local currentlyListeningTo = ""
currentData = {} -- todo: add the local back
local currentlyListening = false
local expectedDataLength = 0
function handlers.onHeader(unitTag, data)
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

function handlers.onData(unitTag, data)
	if AreUnitsEqual('player', unitTag) then d("Recieved data ".. tonumber(data.position)) end
	if GetUnitDisplayName(unitTag) == currentlyListeningTo then
		currentData[data.position] = data.data
	end
end