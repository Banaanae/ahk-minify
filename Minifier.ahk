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
	If (StripCommentsCtrl.Value = "1") {
		tempRes := MsgBox("Buggy, Want to continue?","Warning", "Y/N")
		If (tempRes = "Yes")
			MinifyFile := StripComments(MinifyFile)
	}
	If (ShortenVariablesCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveWhitespacesCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveEmptyLinesCtrl.Value = "1")
		MinifyFile := RemoveEmptyLines(MinifyFile)
	If (RemoveBlankMsgBoxCtrl.Value = "1")
		MinifyFile := RemoveBlankMsgBox(MinifyFile)
	If (RemoveAllMsgBoxCtrl.Value = "1")
		MinifyFile := RemoveAllMsgBox(MinifyFile)
	If (RemoveIndentsCtrl.Value = "1")
		MinifyFile := RemoveIndents(MinifyFile)
    MinifiedFileName := StrReplace(MinifyFileName, ".ahk", ".min.ahk") ; This will behave strange if 2 .ahk is in the path
	 FileAppend(MinifyFile, MinifiedFileName)
	; Check if lasterror = oserror
	MsgBox("Success! Wrote the file to " MinifiedFileName "`nPlease ensure you keep the source as it sometimes removes too much`n`nWould you like you open the file in Notepad?", "Minification Success", "Y/N")
}

StripComments(MinifyFile) {
	/*
Detect semicolon comments without picking them up in strings
Do not match if " before ; ???

Multiline comments - Figure out why it doesnt work
	*/

    ; Comment matching regex

    ; Semicolon based comments
	; ;.*[^"\)]$

    ; /* */ based comments
    ; ^( |\t)*?\/\*(.*)?(\n.*)*\*\/
	; ^( |\t)*?\/\*(.*\n)*?\*\/
	MsgBox(MinifyFile)
    MinifyFile := RegexReplace(MinifyFile, "m)( |\t)*;.*[^`"\)]$")
	MsgBox(MinifyFile)
	MinifyFile := RegexReplace(MinifyFile, "m)^( |\t)*?\/\*(.*\n)*?\*\/", "") ; Not working
	MsgBox(MinifyFile)
	Return MinifyFile
}

ShortenVariables(MinifyFile) {
	; Skipped
}

RemoveWhitespaces(MinifyFile) {
	; Skipped
	; ([~><=!:\+\-\*\/\.&|^]+==?)
}

RemoveEmptyLines(MinifyFile) {
	; ^( |\t)*\K\R
	MinifyFile := RegexReplace(MinifyFile, "m)^( |\t)*\K\R")
	Return MinifyFile
}

RemoveBlankMsgBox(MinifyFile) {
	; ^\s*?MsgBox(\(\))?$
	MinifyFile := RegexReplace(MinifyFile, "m)^\s*?MsgBox(\(\))?$")
	Return MinifyFile
}

RemoveAllMsgBox(MinifyFile) {
	; ^\s*?MsgBox(\(.*\))?( ".*")?$
	MinifyFile := RegexReplace(MinifyFile, "m)^\s*?MsgBox(\(.*\))?( `".*`")?$")
	Return MinifyFile
}

RemoveIndents(MinifyFile) {
	; ^( |\t)*
	MinifyFile := RegexReplace(MinifyFile, "m)^( |\t)*")
	Return MinifyFile
}
