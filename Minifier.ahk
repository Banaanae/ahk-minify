MinifyGui := Gui(, "AutoHotKey Minifier - Status: Idle")
StripCommentsCtrl := MinifyGui.AddCheckBox("x10 y10 w100 h30", "Strip Comments")
StripCommentsCtrl.ToolTip := "(WIP) Removes inline and multiline comments"
ShortenVariablesCtrl := MinifyGui.AddCheckBox("x120 y10 w100 h30", "Shorten Variables")
ShortenVariablesCtrl.ToolTip := "(NOT DONE) Attempts to shorten variable names"
RemoveWhitespacesCtrl := MinifyGui.AddCheckBox("x230 y10 w100 h30", "Remove whitespaces")
RemoveWhitespacesCtrl.ToolTip := "(WIP) Removes extra whitespaces in methods, variable declarations, etc"
RemoveIndentsCtrl := MinifyGui.AddCheckBox("x340 y10 w100 h30", "Remove Indents")
RemoveIndentsCtrl.ToolTip := "Removes spaces and tabs before lines of code"
RemoveBlankMsgBoxCtrl := MinifyGui.AddCheckBox("x10 y50 w100 h30", "Remove blank MsgBox")
RemoveBlankMsgBoxCtrl.ToolTip := "Removes blank message boxes"
RemoveAllMsgBoxCtrl := MinifyGui.AddCheckBox("x120 y50 w100 h30", "Remove all MsgBox")
RemoveAllMsgBoxCtrl.ToolTip := "Removes all message boxes including blank"
OptimiseOptionsCtrl := MinifyGui.AddCheckBox("x230 y50 w100 h30", "Optimise Options")
OptimiseOptionsCtrl.ToolTip := "(NOT DONE) Replace text and hex based options with decimal"
UseOTBCtrl := MinifyGui.AddCheckBox("x340 y50 w100 h30", "Use OTB")
UseOTBCtrl.ToolTip := "(WIP) Forces one true brace, Only supports {}"
UseShorthandCtrl := MinifyGui.AddCheckBox("x10 y90 w100 h30", "Use Shorthand")
UseShorthandCtrl.ToolTip := "(NOT DONE) Replaces code with its shorthand equivilent"
RemoveEmptyLinesCtrl := MinifyGui.AddCheckBox("x120 y90 w100 h30", "Remove empty lines")
RemoveEmptyLinesCtrl.ToolTip := "Removes empty lines, recommended to use as most rules because they do not remove newline"
RemoveTrailingSpacesCtrl := MinifyGui.AddCheckBox("x230 y90 w100 h30", "Remove trailing spaces")
RemoveTrailingSpacesCtrl.ToolTip := "Removes trailing whitespaces and tabs"
HideCtrl := MinifyGui.AddCheckBox("x340 y90 w100 h30 Check3", "Hide unfinished rules")
HideCtrl.OnEvent("Click", Hide)
HideCtrl.ToolTip := "Unchecked: Show all, Check: Only complete, Indeterminate: Complete and partially Complete"
; OneLineCtrl := MinifyGui.AddCheckBox("where emptylines is now shift others, uncomment when hide is removed", "Reduce SLOC")
; OneLineCtrl.ToolTip := "Reduces the script to as few lines as possible"
MinifyGui.AddButton("x10 y120 w430 h30", "Select file and Minify").OnEvent("Click", Minify)
MinifyGui.Show()

OnMessage(0x0200, On_WM_MOUSEMOVE)

Minify(*) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Selecting file"
    MinifyFileName := FileSelect(,, "Select the file to minify")
    If (MinifyFileName = "") { ; Cancelled
        MinifyGui.Title := "AutoHotKey Minifier - Status: Idle"
		Return
	}
    MinifyFile := FileRead(MinifyFileName)
	If (RegexMatch(MinifyFile, "'") = 0)
		If (MsgBox("Detected single quotes (`') which don't have proper support yet`nThis is a crude check which probably contains false positives`n`nContinue?", "Warning", "Y/N Iconi") = "No")
			Return ; easy fix but i change regex too much
	If (StripCommentsCtrl.Value = "1")
		MinifyFile := StripComments(MinifyFile)
	If (ShortenVariablesCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveWhitespacesCtrl.Value = "1")
		MinifyFile := RemoveWhitespaces(MinifyFile)
	If (RemoveIndentsCtrl.Value = "1")
		MinifyFile := RemoveIndents(MinifyFile)
	If (RemoveBlankMsgBoxCtrl.Value = "1")
		MinifyFile := RemoveBlankMsgBox(MinifyFile)
	If (RemoveAllMsgBoxCtrl.Value = "1")
		MinifyFile := RemoveAllMsgBox(MinifyFile)
	If (OptimiseOptionsCtrl.Value = "1")
		MinifyFile := OptimiseOptions(MinifyFile)
	If (UseOTBCtrl.Value = "1")
		MinifyFile := UseOTB(MinifyFile)
	If (UseShorthandCtrl.Value = "1")
		MsgBox("Not implemented, Skipping", "WIP", 48)
	If (RemoveEmptyLinesCtrl.Value = "1")
		MinifyFile := RemoveEmptyLines(MinifyFile)
	If (RemoveTrailingSpacesCtrl.Value = "1")
		MinifyFile := RemoveTrailingSpaces(MinifyFile)
	MinifyGui.Title := "AutoHotKey Minifier - Status: Writing file"
    MinifiedFileName := RegexReplace(MinifyFileName, "\.ahk$", ".min.ahk") ; Use RegEx to avoid strange file paths
	WriteFile(MinifyFile, MinifiedFileName)
}

WriteFile(MinifyFile, MinifiedFileName) {
	FileAppend(MinifyFile, MinifiedFileName)
	CheckWrite:
	If (A_LastError = 0) { ; File write successful
		OpenMinifiedFileRes := MsgBox("Success! Wrote the file to " MinifiedFileName "`nPlease ensure you keep the source as it sometimes removes too much`n`nWould you like you open the file in Notepad?", "Minification Success", "Y/N Iconi")
		If (OpenMinifiedFileRes = "Yes") {
			Run("Notepad " MinifiedFileName) ; TODO: Open in default .ahk editor (avoid registry if possible)
		}
	} Else If (A_LastError = 183) { ; File already exists
		OverwriteRes := MsgBox("Minified file with this name already exists`nDo you want to overwrite it?", "Warning!", "Y/N Icon!")
		If (OverwriteRes = "Yes") {
			FileDelete(MinifiedFileName)
			FileAppend(MinifyFile, MinifiedFileName)
			Goto("CheckWrite") ; Skips writing file to prevent endless loop
		}
	} Else { ; Unknown Error
		UnknownErrorRes := MsgBox("Failed, received error code: " A_LastError "`nPlease report this on github`n`nWould you like to open the issue", "Failed", "Y/N Iconx")
		If (UnknownErrorRes = "Yes") {
			Run("https://github.com/Banaanae/ahk-minify/issues")
		}
	}
	MinifyFile := "" ; Free memory
	MinifyGui.Title := "AutoHotKey Minifier - Status: Idle"
}

StripComments(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Stripping Comments"
	/*
Detect semicolon comments without picking them up in strings
Do not match if " before ; ???
OR
Get all ;
Check if *ODD* number of unescaped " ' or ( (maybe {)
(^| );.* if ^ fails

Multiline comments - Fixed
	*/

    ; Comment matching regex

    ; Semicolon based comments
	; ;.*[^"\)]$
	; ( |\t)*;.*[^`"\)]$
	; (^| );.*

    ; /* */ based comments
    ; ^( |\t)*?\/\*(.*)?(\n.*)*\*\/
	; ^( |\t)*?\/\*(.*\n)*?\*\/
	; MsgBox(MinifyFile)
	WIPContRes := MsgBox("Not all inline comments will be removed,`nJust comments at the start on a line (excluding spaces and tabs)`n`nDo you want to continue?", "WIP", "Y/N")
	If (WIPContRes = "No")
		Return MinifyFile
    MinifyFile := RegexReplace(MinifyFile, "m)^\s*;.*") ; Safe Rule, Doesn't remove ALL comments but doesn't remove noncomments
	RegexMatch(MinifyFile, ".*;", &SemicolonLines)
	MsgBox(SemicolonLines[])
	MsgBox A_LastError
	;Loop (Semicolon.Count)
	; From here count " etc, if odd remove ansudna
	; MsgBox(MinifyFile)
	MinifyFile := RegexReplace(MinifyFile, "mU)^( |\t)*\/\*(.*\R)*\*\/", "") ; Removes all comments (that I know of)
	; MsgBox(A_LastError)
	; MsgBox(MinifyFile)
	Return MinifyFile
}

ShortenVariables(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Shortening Variables"
	; Skipped
	/*
Get variable names
add full name and shortened to array
next vaeiable check against array
if found replace with shortened
else make new
if new var conflicts with shortened
get second character
*/
}

RemoveWhitespaces(MinifyFile) { ; Probably need to move to after OTB
	MinifyGui.Title := "AutoHotKey Minifier - Status: Removing Whitespaces"
	; ([~><=!:\+\-\*\/\.&|^]+==?)
	; \) {
	/*
Remove spaces:
Before and after declarations
After commas in methods
Functions and if statements (and anything similar) 
*/
	WIPContRes := MsgBox("This is still a WIP`n`nDo you want to continue?", "WIP", "Y/N")
	If (WIPContRes = "No")
		Return MinifyFile
	MinifyFile := RegexReplace(MinifyFile, "\)\s+{", "){\s*")
	MinifyFile := RegexReplace(MinifyFile, "( |\t)+(?=[~><=!:\+\-\*\/\.&|^]+==?)|(?<=[~><=!:\+\-\*\/\.&|^])( |\t)+") ; https://stackoverflow.com/a/67708142
	Return MinifyFile
}

RemoveBlankMsgBox(MinifyFile) { ; Add similar?
	MinifyGui.Title := "AutoHotKey Minifier - Status: Removing blank MsgBox"
	; ^\s*MsgBox(\(\))?$
	MinifyFile := RegexReplace(MinifyFile, "m)^\s*MsgBox(\(\))?$")
	Return MinifyFile
}

RemoveAllMsgBox(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Removing all MsgBox"
	; ^\s*MsgBox(\(.*\))?( ".*")?$
	MinifyFile := RegexReplace(MinifyFile, "m)^\s*MsgBox(\(.*\))?( `".*`")?$")
	Return MinifyFile
}

RemoveIndents(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Removing Indents"
	; ^( |\t)+
	MinifyFile := RegexReplace(MinifyFile, "m)^( |\t)+")
	Return MinifyFile
}

OptimiseOptions(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Optimising Options"
	WIPContRes := MsgBox("This is still a WIP`n`nDo you want to continue?", "WIP", "Y/N")
	If (WIPContRes = "No")
		Return MinifyFile
	; Skipped
/*
Options RegEx (Although they're the same the can't be put into 1 RegEx so they can be differentiated, options are different): 
Doesnt work if , in string
MsgBox: MsgBox.*,.*,\s*\K"?.*"?
TrayTip: TrayTip.*,.*,\s*\K"?.*"?
*/
	/*
Match options in method
Detect options type, if not decimal replace with numbers
Add numbers together
"Y/N Iconx" -> "4 16" -> "20"
OR
"0x14" -Hex + 0> "20"


*/
	; MsgBox
	RegexMatch(MinifyFile, "i)MsgBox(\(|\s+).*\K`".*`"(,\s*\K(0x\d+))?", &OptimiseMsgBox) ; Matches last ; MsgBox(?:\(|\s+).*\K`".*`"(?:,\s*\K(0x\d+))?
	MsgBox(OptimiseMsgBox[0])
	MinifyFile := MinifyFile
	Return MinifyFile
}

UseOTB(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Forcing OTB"
	; \R{
	MinifyFile := RegexReplace(MinifyFile, "\R{", "{")
	Return MinifyFile
}

UseShorthand(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Replacing non-shorthand"
/*
Var += 1 -> Var++
RegexMatch("abc", "[abc]") -> "abc" ~= "[abc]"
*/
	Return MinifyFile
}

RemoveEmptyLines(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Removing empty lines"
	; ^( |\t)*\K\R
	MinifyFile := RegexReplace(MinifyFile, "m)^( |\t)*\K\R")
	Return MinifyFile
}

RemoveTrailingSpaces(MinifyFile) {
	MinifyGui.Title := "AutoHotKey Minifier - Status: Removing trailing whitespaces"
	; \s+$
	MinifyFile := RegexReplace(MinifyFile, "\s+$")
	Return MinifyFile
}

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) { ; https://www.autohotkey.com/docs/v2/lib/Gui.htm#ExToolTip
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

Hide(*) { ; Very bad temp func
	If (HideCtrl.Value = 0) {
		ShortenVariablesCtrl.Visible := OptimiseOptionsCtrl.Visible := UseShorthandCtrl.Visible := "1"
	} Else If (HideCtrl.Value = 1) {
		StripCommentsCtrl.Visible := ShortenVariablesCtrl.Visible := RemoveWhitespacesCtrl.Visible := OptimiseOptionsCtrl.Visible := UseOTBCtrl.Visible := UseShorthandCtrl.Visible := "0"
	} Else {
		StripCommentsCtrl.Visible := RemoveWhitespacesCtrl.Visible := UseOTBCtrl.Visible := "1"
	}
}