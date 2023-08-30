MinifyGui := Gui(, "AutoHotKey Minifier")
StripCommentsCtrl := MinifyGui.AddCheckBox("x10 y10 w100 h30", "Strip Comments")
StripCommentsCtrl.ToolTip := "(WIP) Removes inline and multiline comments"
ShortenVariablesCtrl := MinifyGui.AddCheckBox("x120 y10 w100 h30", "Shorten Variables") ; .ToolTip := "(NOT DONE) Attempts to shorten variable names"
RemoveWhitespacesCtrl := MinifyGui.AddCheckBox("x230 y10 w100 h30", "Remove whitespaces") ; .ToolTip := "(NOT DONE) Removes extra whitespaces in methods, variable declarations, etc"
RemoveIndentsCtrl := MinifyGui.AddCheckBox("x340 y10 w100 h30", "Remove Indents") ; .ToolTip := "Removes spaces and tabs before lines of code"
RemoveBlankMsgBoxCtrl := MinifyGui.AddCheckBox("x10 y50 w100 h30", "Remove blank MsgBox") ; .ToolTip := "Removes blank message boxes"
RemoveAllMsgBoxCtrl := MinifyGui.AddCheckBox("x120 y50 w100 h30", "Remove all MsgBox") ; .ToolTip := "Removes all message boxes including blank"
RemoveEmptyLinesCtrl := MinifyGui.AddCheckBox("x230 y50 w100 h30", "Remove empty lines") ; .ToolTip := "Removes empty lines, recommended to use as most rules because they do not remove newline"
;Ctrl := MinifyGui.AddCheckBox("x340 y50 w100 h30", "Less Gui Lines") <- Not sure if possible
; OTB
; Trailing space
MinifyGui.AddButton("x10 y90 w430 h30", "Select file and Minify").OnEvent("Click", Minify)
MinifyGui.Show()
OnMessage(0x0200, On_WM_MOUSEMOVE)

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
	WriteFile(MinifyFile, MinifiedFileName)
}

WriteFile(MinifyFile, MinifiedFileName) {
	FileAppend(MinifyFile, MinifiedFileName)
	CheckWrite:
	If (A_LastError = 0) {
		MsgBox("Success! Wrote the file to " MinifiedFileName "`nPlease ensure you keep the source as it sometimes removes too much`n`nWould you like you open the file in Notepad?", "Minification Success", "Y/N Iconi")
	} Else If (A_LastError = 183) {
		OverwriteRes := MsgBox("Minified file with this name already exists`nDo you want to overwrite it?", "Warning!", "Y/N Icon!")
		If (OverwriteRes = "Yes") {
			FileDelete(MinifiedFileName)
			FileAppend(MinifyFile, MinifiedFileName)
			Goto("CheckWrite") ; Skips writing file to prevent endless loop
		}
	} Else {
		UnknownErrorRes := MsgBox("Failed, received error code: " A_LastError "`nPlease report this on github`n`nWould you like to open the issue", "Failed", "Iconx")
		If (UnknownErrorRes = "Yes") {
			Run("https://github.com/Banaanae/ahk-minify/issues")
		}
	}
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

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd)
{
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd)
    {
        Text := "", ToolTip() ; Turn off any previous tooltip.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl
        {
            if !CurrControl.HasProp("ToolTip")
                return ; No tooltip for this control.
            Text := CurrControl.ToolTip
            SetTimer () => ToolTip(Text), -1000
            SetTimer () => ToolTip(), -4000 ; Remove the tooltip.
        }
        PrevHwnd := Hwnd
    }
}
