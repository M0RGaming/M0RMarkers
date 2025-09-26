local MM = M0RMarkers

ESO_Dialogs["M0RMarkerConfirmDialogue"] = {
	canQueue = false,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	buttons = { { text = "Yes", callback = function(dialogue)
		dialogue.data.yesCallback()
		a = dialogue
	end }, { text = "No" } },
}


function MM.ShowDialogue(title, description, warning, callback)
	ZO_Dialogs_ShowPlatformDialog("M0RMarkerConfirmDialogue", {yesCallback = callback}, {
		titleParams = {title or ""},
		mainTextParams = {description or ""},
		warningParams = {warning or ""}
	})
end