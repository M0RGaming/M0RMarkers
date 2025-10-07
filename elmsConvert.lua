local MM = M0RMarkers
local print = MM.print


MM.elmsMap = {

	-- numbers to 12

	[1] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "1",
		size = 1.5,
	},
	[2] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "2",
		size = 1.5,
	},
	[3] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "3",
		size = 1.5,
	},
	[4] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "4",
		size = 1.5,
	},
	[5] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "5",
		size = 1.5,
	},
	[6] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "6",
		size = 1.5,
	},
	[7] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "7",
		size = 1.5,
	},
	[8] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "8",
		size = 1.5,
	},
	[9] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "9",
		size = 1.5,
	},
	[10] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "10",
		size = 1.5,
	},
	[11] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "11",
		size = 1.5,
	},
	[12] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "12",
		size = 1.5,
	},






	[13] = { -- white arrow. Offset = 100
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "↓",
		size = 1.5,
	},
	[14] = { -- marker_lightblue
		bgTexture = "M0RMarkers/textures/chevron.dds",
		colour = {0, 1, 0.65, 1}
	},
	[15] = { -- square_blue
		bgTexture = "M0RMarkers/textures/square.dds",
		colour = {0, 0, 1, 1}
	},
	[16] = { -- square_green
		bgTexture = "M0RMarkers/textures/square.dds",
		colour = {0, 1, 0, 1}
	},
	[17] = { -- square_orange
		bgTexture = "M0RMarkers/textures/square.dds",
		colour = {1, 0.5, 0, 1}
	},
	[18] = { -- HEXAGON OT
		bgTexture = "M0RMarkers/textures/hexagon.dds",
		colour = {1, 0.5, 0, 1},
		text= "OT"
	},
	[19] = { -- square_pink
		bgTexture = "M0RMarkers/textures/square.dds",
		colour = {1, 0, 0.9, 1}
	},
	[20] = { -- square_red
		bgTexture = "M0RMarkers/textures/square.dds",
		colour = {1, 0, 0, 1}
	},
	[21] = { -- HEXAGON MT
		bgTexture = "M0RMarkers/textures/hexagon.dds",
		colour = {1, 0, 0, 1},
		text = "MT"
	},
	[22] = { -- square_yellow
		bgTexture = "M0RMarkers/textures/square.dds",
		colour = {1, 0.8, 0, 1}
	},
	[23] = { -- squaretwo_blue
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 0, 1, 1},
	},
	[24] = { -- squaretwo_blue 1
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 0, 1, 1},
		text = "1"
	},
	[25] = { -- squaretwo_blue 2
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 0, 1, 1},
		text = "2"
	},
	[26] = { -- squaretwo_blue 3
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 0, 1, 1},
		text = "3"
	},
	[27] = { -- squaretwo_blue 4
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 0, 1, 1},
		text = "4"
	},
	[28] = { -- squaretwo_green
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 1, 0, 1},
	},
	[29] = { -- squaretwo_green 1
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 1, 0, 1},
		text = "1"
	},
	[30] = { -- squaretwo_green 2
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 1, 0, 1},
		text = "2"
	},
	[31] = { -- squaretwo_green 3
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 1, 0, 1},
		text = "3"
	},
	[32] = { -- squaretwo_green 4
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {0, 1, 0, 1},
		text = "4"
	},
	[33] = { -- squaretwo_orange
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0.5, 0, 1},
	},
	[34] = { -- squaretwo_orange 1
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0.5, 0, 1},
		text = "1"
	},
	[35] = { -- squaretwo_orange 2
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0.5, 0, 1},
		text = "2"
	},
	[36] = { -- squaretwo_orange 3
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0.5, 0, 1},
		text = "3"
	},
	[37] = { -- squaretwo_orange 4
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0.5, 0, 1},
		text = "4"
	},
	[38] = { -- squaretwo_pink
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0, 0.9, 1},
	},
	[39] = { -- squaretwo_red
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0, 0, 1},
	},
	[40] = { -- squaretwo_red 1
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0, 0, 1},
		text = "1"
	},
	[41] = { -- squaretwo_red 2
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0, 0, 1},
		text = "2"
	},
	[42] = { -- squaretwo_red 3
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0, 0, 1},
		text = "3"
	},
	[43] = { -- squaretwo_red 4
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0, 0, 1},
		text = "4"
	},
	[44] = { -- squaretwo_yellow
		bgTexture = "M0RMarkers/textures/diamond.dds",
		colour = {1, 0.8, 0, 1},
	},


	-- letters
	[45] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "a",
		size = 1.5,
	},
	[46] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "b",
		size = 1.5,
	},
	[47] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "c",
		size = 1.5,
	},
	[48] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "d",
		size = 1.5,
	},
	[49] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "e",
		size = 1.5,
	},
	[50] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "f",
		size = 1.5,
	},
	[51] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "g",
		size = 1.5,
	},
	[52] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "h",
		size = 1.5,
	},
	[53] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "i",
		size = 1.5,
	},
	[54] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "j",
		size = 1.5,
	},
	[55] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "k",
		size = 1.5,
	},
	[56] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "l",
		size = 1.5,
	},
	[57] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "m",
		size = 1.5,
	},
	[58] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "n",
		size = 1.5,
	},
	[59] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "o",
		size = 1.5,
	},
	[60] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "p",
		size = 1.5,
	},
	[61] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "q",
		size = 1.5,
	},
	[62] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "r",
		size = 1.5,
	},
	[63] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "s",
		size = 1.5,
	},
	[64] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "t",
		size = 1.5,
	},
	[65] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "u",
		size = 1.5,
	},
	[66] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "v",
		size = 1.5,
	},
	[67] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "w",
		size = 1.5,
	},
	[68] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "x",
		size = 1.5,
	},
	[69] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "y",
		size = 1.5,
	},
	[70] = {
		bgTexture = "M0RMarkers/textures/blank.dds",
		text = "z",
		size = 1.5,
	},



	[71] = { -- Shark Pog Equivalent
		bgTexture = "M0RMarkers/textures/sharkpog.dds",
		colour = {1, 1, 1, 1},
	},


}


function MM.parseElmsString(elmsString)
	if MM.multipleProfilesLoaded then
		MM.ShowNotice("Notice", "Markers are Read-Only when multiple profiles are loaded.", "")
		d("|cFFD700More Markers|r: Markers are Read-Only when multiple profiles are loaded.")
		return
	end

	
	local amountParsed = 0
	local currentZone = GetUnitRawWorldPosition('player')

	-- the following parse code is directly from elms
	for zone, x, y, z, iconKey in string.gmatch(elmsString, "/(%d+)//(%d+),(%d+),(%d+),(%d+)/") do
		zone = tonumber(zone)
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
		iconKey = tonumber(iconKey)


		if (MM.elmsMap[iconKey]) and (currentZone == zone) then
			print("Converting icon with key: ".. iconKey)
			local iconData = {
				bgTexture = "M0RMarkers/textures/blank.dds",
				x = 0,
				y = 0,
				z = 0,
				colour = {1, 1, 1, 1},
				text = "",
				size = 1
			}
			iconData = ZO_ShallowTableCopy(MM.elmsMap[iconKey], iconData)
			iconData.x = x
			iconData.y = y + 50 * iconData.size
			iconData.z = z
			MM.createIcon(iconData)
			amountParsed = amountParsed + 1
		end
	end
	zoneString = MM.compressLoaded()
	MM.saveIcons(zoneString)
	return amountParsed, zoneString
end