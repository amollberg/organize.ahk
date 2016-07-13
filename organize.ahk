;//-------------------Config----

MAX_EXAMPLE_FILES = 20

;//-----------------------------

SetBatchLines -1

Gui, add, groupbox, w600 h200, Controls
Gui, add, text,yp+20 xp+20 section, Loop-pattern:  ; Save this control's position and start a new section.
Gui, add, text,, Find:
Gui, add, text,, Move to:
Gui, add, checkbox, vIncludeSubfolders, Include Subfolders
Gui, add, button,default gStartOrganize vStartOrganize,Organize!
Gui, add, checkbox, vOverwriteAlways gOverwriteAlwaysCheckboxEvent, Overwrite always
Gui, add, checkbox, vOverwriteIfNotOlder, Overwrite if newer or same
Gui, add, checkbox, vOverwriteIfNotSmaller, Overwrite if larger or same
Gui, add, progress, w100 BackgroundFFFFFF vProgressBar

Gui, add, edit, ys vLoopPattern gUpdateExample ; Start a new column within this section.
Gui, add, edit, section vFindMask gUpdateExample
Gui, add, edit, vReplaceMask gUpdateExample ; Save position ...

Gui, add, checkbox, ys+5 vCaseInsensitive gCaseInsensitiveCheckboxEvent, Case-insensitive ; ... Use same y-position but new column
Gui, add, checkbox, yp+25 vDoRecycle gRecycleCheckboxEvent, Recycle bin ; Place below previous checkbox

Gui, add, text, section x10, Unchanged:
Gui, add, edit, xs w300 -Wrap vExampleUnchanged r%MAX_EXAMPLE_FILES%
Gui, add, text, ys section , Changed:
Gui, add, edit, xs w300 -Wrap vExampleChanged r%MAX_EXAMPLE_FILES%
Gui, add, text, ys section, To:
Gui, add, edit, xs w300 -Wrap vExampleChangedTo r%MAX_EXAMPLE_FILES%

Gui, show

GuiControl,, ProgressBar, BackgroundFFFF33

Loop, %0% ; For each command line argument (conf file)
{
	ConfFile := %A_Index%  ; Filename is in %1%, %2%, ...
	Loop, Read, %ConfFile%
	{
		if A_LoopReadLine = 
			continue
		RegexMatch(A_LoopReadLine, "iJ)^((In|Among(st)?) )*(?P<LoopPattern>.*?) (?P<IncludeSubfolders>including subfolders )?find (?P<FindMask>.*?) (?P<CaseInsensitive>case[- ]?insensitive )?(and )?(?:(move to (?P<ReplaceMask>.*?))|(?P<DoRecycle>recycle))( overwrit(ing|e) (?:(?P<OverwriteAlways>always)|if (?:(?P<OverwriteIfNotOlder>newer)|(?P<OverwriteIfNotSmaller>larger))( or (?:(?P<OverwriteIfNotOlder>newer)|(?P<OverwriteIfNotSmaller>larger)))*))*\w*?$", Match_)
		If ErrorLevel
		{
			msgbox, Syntax error %ErrorLevel% in file "%ConfFile%":`n "%A_LoopReadLine%"
		}
		
		LoopPattern           := Match_LoopPattern
		IncludeSubfolders     := (Match_IncludeSubfolders <> "") ? 1 : 0
		FindMask              := Match_FindMask
		ReplaceMask           := Match_ReplaceMask
		OverwriteAlways       := (Match_OverwriteAlways <> "") ? 1 : 0
		OverwriteIfNotOlder   := (Match_OverwriteIfNotOlder <> "") ? 1 : 0
		OverwriteIfNotSmaller := (Match_OverwriteIfNotSmaller <> "") ? 1 : 0
		DoRecycle             := (Match_DoRecycle <> "") ? 1 : 0
		CaseInsensitive       := (Match_CaseInsensitive <> "") ? 1 : 0

		GuiControl,, LoopPattern, %LoopPattern%
		GuiControl,, FindMask, %FindMask%
		GuiControl,, ReplaceMask, %ReplaceMask%
		GuiControl,, IncludeSubfolders, %IncludeSubfolders%
		GuiControl,, OverwriteAlways, %OverwriteAlways%
		GuiControl,, OverwriteIfNotOlder, %OverwriteIfNotOlder%
		GuiControl,, OverwriteIfNotSmaller, %OverwriteIfNotSmaller%
		GuiControl,, DoRecycle, %DoRecycle%
		GuiControl,, CaseInsensitive, %CaseInsensitive%
		
		Organize(Match_LoopPattern, IncludeSubfolders, OverwriteAlways, OverwriteIfNotOlder, OverwriteIfNotSmaller, Match_FindMask, Match_ReplaceMask, DoRecycle, CaseInsensitive)
	}	
}

if 0 > 0 ; If there were command line arguments
{
	; We are in "batch mode" and should not persist past the end
	exitapp
}

return

GuiEscape:
GuiClose:
ExitApp

haveSubmitted := false
updateExample:
	if not haveSubmitted
		Gui, submit, nohide
	ExampleUnchanged = 
	ExampleChanged = 
	ExampleChangedTo = 
	MAX_EXAMPLE_LOOP_FILES = 2000
	changedN = 0
	unchangedN = 0
	if (LoopPattern <> Last_LoopPattern OR IncludeSubfolders <> Last_IncludeSubfolders OR FindMask <> Last_FindMask OR ReplaceMask <> Last_ReplaceMask OR Last_DoRecycle <> DoRecycle OR Last_CaseInsensitive <> CaseInsensitive)
	{
		Last_DoRecycle := DoRecycle
		Last_FindMask := FindMask
		Last_ReplaceMask := ReplaceMask
		fileCount = 0
		loop, %LoopPattern%,,%IncludeSubfolders%
		{
			fileCount++
			if(A_Index >= MAX_EXAMPLE_LOOP_FILES)
				break 
		}
		if(fileCount = 0)
		{
			fileCount = NONE
		}
		Last_LoopPattern 		:= LoopPattern
		Last_IncludeSubfolders  := IncludeSubfolders
		
		PrepareMasks(FindMask, ReplaceMask, CaseInsensitive)
		
		loop, %LoopPattern%,,%IncludeSubfolders%
		{
			if fileCount = NONE
				break
			Random, r, 0, % fileCount/MAX_EXAMPLE_FILES   ;%
			if(r > 1)
				continue
			OldPath := A_LoopFileName
			if(A_LoopFileDir)
				OldPath = %A_LoopFileDir%\%OldPath%
			ExampleInput := OldPath 

			if (RegExMatch(ExampleInput, FindMask))
			{
				if DoRecycle
					ExampleOutput := "[Recycle bin]"
				else
					ExampleOutput := RegExReplace(ExampleInput, FindMask, ReplaceMask)

				ExampleChanged .= ExampleInput "`n"
				ExampleChangedTo .= ExampleOutput "`n"
				changedN++
			}
			else
			{
				ExampleUnchanged .= ExampleInput "`n"
				unchangedN++
			}

			if(unchangedN >= MAX_EXAMPLE_FILES or changedN >= MAX_EXAMPLE_FILES)
				break	
		}
	}
		
	if fileCount = "NONE"
	{
		Gui, Font, cRed
		GuiControl, Font, LoopPattern
		return
	}
	Gui, Font, cGreen  
	GuiControl, Font, LoopPattern

	GuiControl,,ExampleUnchanged, %ExampleUnchanged%
	GuiControl,,ExampleChanged, %ExampleChanged%
	GuiControl,,ExampleChangedTo, %ExampleChangedTo%
	; Reset the flag until the next call
	haveSubmitted := false
return

OverwriteAlwaysCheckboxEvent:
	Gui, submit, nohide
	; Signal so that UpdateExample does not re-submit gui data (throws away old)
	haveSubmitted := true
	if OverwriteAlways
	{
		GuiControl, Disable, OverwriteIfNotOlder
		GuiControl, Disable, OverwriteIfNotSmaller
	} else {
		GuiControl, Enable, OverwriteIfNotOlder
		GuiControl, Enable, OverwriteIfNotSmaller
	}
	gosub UpdateExample
return

RecycleCheckboxEvent:
	Gui, submit, nohide
	haveSubmitted := true
	if DoRecycle 
	{
		GuiControl, Disable, ReplaceMask
	} else {
		GuiControl, Enable, ReplaceMask
	}
	gosub UpdateExample
return

CaseInsensitiveCheckboxEvent:
	gosub UpdateExample
return


StartOrganize:
	Gui, submit, nohide
	Organize(LoopPattern, IncludeSubfolders, OverwriteAlways, OverwriteIfNotOlder, OverwriteIfNotSmaller, FindMask, ReplaceMask, DoRecycle, CaseInsensitive)
return


Organize(LoopPattern, IncludeSubfolders, OverwriteAlways, OverwriteIfNotOlder, OverwriteIfNotSmaller, FindMask, ReplaceMask, DoRecycle, CaseInsensitive)
{
	GuiControl, Disable, StartOrganize
	PrepareMasks(FindMask, ReplaceMask, CaseInsensitive)
	FileCount = 0
	ExampleUnchanged = 
	ExampleChanged = 
	ExampleChangedTo = 
	nRowsUnchanged = 0
	nRowsChanged = 0
	loop, %loopPattern%,,%IncludeSubfolders%
		FileCount++
	GuiControl,,ProgressBar,0
	
	GuiControl,+cBlue,ProgressBar
	loop, %loopPattern%,,%IncludeSubfolders%
	{
		OldPath = %A_LoopFileName%
		if(A_LoopFileDir)
			OldPath = %A_LoopFileDir%\%OldPath%

		if(RegExMatch(OldPath, FindMask)) ;OldPath <> NewPath OR DoRecycle)
		{
			; Compute new path
			if DoRecycle
				NewPath	:= "[Recycle bin]"
			else
				NewPath	:= RegExReplace(OldPath, FindMask, ReplaceMask)

			; Create destination folder if necessary
			if not DoRecycle
			{
				SlashPos := InStr(NewPath,"\",false,0)
				NewFolder := false
				if(SlashPos)
					NewFolder := Substr(NewPath, 1,SlashPos-1)
				if(NewFolder)
					FileCreateDir, %NewFolder%
			}

			; Perform the move action
			if DoRecycle
			{
				FileRecycle, %OldPath%
			}
			else
			{
				ifExist, %NewPath%
				{
					FileGetSize TargetSize, %NewPath%
					FileGetSize SourceSize, %OldPath%
					FileGetTime, TargetDate, %NewPath%
					FileGetTime, SourceDate, %OldPath%
					DateDiff := SourceDate
					EnvSub, DateDiff, TargetDate, Seconds ; Source - Target
					if (OverwriteAlways or (OverwriteIfNotOlder and DateDiff >= 0) or (OverwriteIfNotSmaller and SourceSize >= TargetSize))
						FileMove, %OldPath%, %NewPath%, 1
				}
				else
					FileMove, %OldPath%, %NewPath%
			}


			if ErrorLevel = 0
			{
				if nRowsChanged < 100
				{
					nRowsChanged ++
					ExampleChanged .= OldPath "`n"
					ExampleChangedTo .= NewPath "`n"
					GuiControl,,ExampleChanged, %ExampleChanged%
					GuiControl,,ExampleChangedTo, %ExampleChangedTo%
				}
			}
			else
			{
				if nRowsUnchanged < 100
				{
					nRowsUnchanged ++
					ExampleUnchanged .= OldPath "`n"
					GuiControl,,ExampleUnchanged, %ExampleUnchanged%
				}
			}
			
		}
		else 
		{
			if nRowsUnchanged < 100
			{
				nRowsUnchanged ++
				ExampleUnchanged .= OldPath "`n"
				GuiControl,,ExampleUnchanged, %ExampleUnchanged%
			}
		}
		
		GuiControl,,ProgressBar,% 100 * A_Index / FileCount   ;%
	}
	GuiControl,+cGreen,ProgressBar
	GuiControl, Enable, StartOrganize
}

PrepareMasks(ByRef FindMask, ByRef ReplaceMask, CaseInsensitive)
{
	FindMask := RegExReplace(FindMask, "iJ)([\.\?\+\[\{\|\(\)\^\$\\])","\$1")
	StringReplace, FindMask, FindMask, *, [^""><]*, All
	FindMask := RegExReplace(FindMask, "iJ)<(.+?)>(.*)<\1>","<$1>$2\k'$1'")
	FindMask := RegExReplace(FindMask, "iJ)<(.+?)>","(?P<$1>.*)")
	ReplaceMask := RegExReplace(ReplaceMask, "i)<(.+?)>","$${$1}")
	StringReplace, ReplaceMask, ReplaceMask, *, [^""><]*, All
	FindMask 	= ^%FindMask%$
	if CaseInsensitive
		FindMask 	= i)%FindMask%
}

StrDup(char, n)
{
	r = 
	loop, %n%
		r .=  char
	return %r%
}