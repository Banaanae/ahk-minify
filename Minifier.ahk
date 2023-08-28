MinifyGui := Gui(, "AutoHotKey Minifier")
StripCommentsCtrl := MinifyGui.AddCheckBox("x10 y10 w100 h30", "Strip Comments")
ShortenVariablesCtrl := MinifyGui.AddCheckBox("x120 y10 w100 h30", "Shorten Variables")
RemoveWhitespacesCtrl := MinifyGui.AddCheckBox("x230 y10 w100 h30", "Remove whitespaces")
RemoveEmptyLinesCtrl := MinifyGui.AddCheckBox("x340 y10 w100 h30", "Remove empty lines")
RemoveBlankMsgBoxCtrl := MinifyGui.AddCheckBox("x10 y50 w100 h30", "Remove blank MsgBox")
RemoveAllMsgBoxCtrl := MinifyGui.AddCheckBox("x120 y50 w100 h30", "Remove all MsgBox")
RemoveIndentsCtrl := MinifyGui.AddCheckBox("x230 y50 w100 h30", "Remove Indents")
;Ctrl := MinifyGui.AddCheckBox("x340 y50 w100 h30", "Less Gui Lines") <- Not sure if possible
MinifyGui.AddButton("x10 y90 w430 h30", "Select file and Minify").OnEvent("Click", Minify)
MinifyGui.Show()

Minify(*) {
    MinifyFileName := FileSelect(,, "Select the file to minify")
    If (MinifyFileName = "")
        Return
    MinifyFile := FileRead(MinifyFileName)
	If (StripCommentsCtrl.Value = "1")
		MinifyFile := StripComments(MinifyFile)
	If (ShortenVariablesCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveWhitespacesCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveEmptyLinesCtrl.Value = "1")
		MinifyFile := RemoveEmptyLines(MinifyFile)
	If (RemoveBlankMsgBoxCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveAllMsgBoxCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveIndentsCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
    MinifiedFileName := StrReplace(MinifyFileName, ".ahk", ".min.ahk") ; This will behave strange if 2 .ahk is in the path
	; FileAppend(MinifyFile), MinifiedFileName
}

StripComments(MinifyFile) {
    ; Comment matching regex

    ; Semicolon based comments
	; ;.*[^"\)]$

    ; /* */ based comments
    ; ^( |\t)*?\/\*(.*)?(\n.*)*\*\/
    MinifyFile := RegexReplace(MinifyFile, "m);.*[^`"\)]$") ; TODO: Apply \K\R once VVV is working
	MinifyFile := RegexReplace(MinifyFile, "mU)^(\s)*?\/\*(.*)?(\n.*)*\*\/", "") ; Not working
	Return MinifyFile
}

ShortenVariables() {
	; Skipped
}

RemoveWhitespaces() {
	; Skipped
}

RemoveEmptyLines(MinifyFile) {
	; ^( |\t)*\k\r
	MinifyFile := RegexReplace(MinifyFile, "m)^( |\t)*\K\R")
	Return MinifyFile
}
