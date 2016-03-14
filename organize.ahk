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
Gui, add, checkbox, vOverwriteIfNotOlder, Overwrite if newer or same
Gui, add, checkbox, vOverwriteIfNotSmaller, Overwrite if larger or same
Gui, add, progress, w100 BackgroundFFFFFF vProgressBar

Gui, add, edit, ys vLoopPattern gUpdateExample ; Start a new column within this section.
Gui, add, edit, vFindMask gUpdateExample
Gui, add, edit, vReplaceMask gUpdateExample

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
		RegexMatch(A_LoopReadLine, "iJ)^((In|Among(st)?) )*(?P<LoopPattern>.*?) (?P<IncludeSubfolders>including subfolders )?find (?P<FindMask>.*?) (and )?move to (?P<ReplaceMask>.*?)( overwrit(ing|e) if (?:(?P<OverwriteIfNotOlder>newer)|(?P<OverwriteIfNotSmaller>larger))( or (?:(?P<OverwriteIfNotOlder>newer)|(?P<OverwriteIfNotSmaller>larger)))*)*\w*?$", Match_)
		If ErrorLevel
		{
			msgbox, Syntax error %ErrorLevel% in file "%ConfFile%":`n "%A_LoopReadLine%"
		}
		
		LoopPattern           := Match_LoopPattern
		IncludeSubfolders     := (Match_IncludeSubfolders <> "") ? 1 : 0
		FindMask              := Match_FindMask
		ReplaceMask           := Match_ReplaceMask
		OverwriteIfNotOlder   := (Match_OverwriteIfNotOlder <> "") ? 1 : 0
		OverwriteIfNotSmaller := (Match_OverwriteIfNotSmaller <> "") ? 1 : 0
		
		GuiControl,, LoopPattern, %LoopPattern%
		GuiControl,, FindMask, %FindMask%
		GuiControl,, ReplaceMask, %ReplaceMask%
		GuiControl,, IncludeSubfolders, %IncludeSubfolders%
		GuiControl,, OverwriteIfNotOlder, %OverwriteIfNotOlder%
		GuiControl,, OverwriteIfNotSmaller, %OverwriteIfNotSmaller%
		
		
		;msgbox, %LoopPattern%`, %IncludeSubfolders%`, %OverwriteIfNotOlder%`, %OverwriteIfNotSmaller%`, %FindMask%`, %ReplaceMask%
		
		Organize(Match_LoopPattern, IncludeSubfolders, OverwriteIfNotOlder, OverwriteIfNotSmaller, Match_FindMask, Match_ReplaceMask)
	}	
}

return

GuiEscape:
GuiClose:
ExitApp

updateExample:
	Gui, submit, nohide
	ExampleUnchanged = 
	ExampleChanged = 
	ExampleChangedTo = 
	MAX_EXAMPLE_LOOP_FILES = 2000
	changedN = 0
	unchangedN = 0
	if (LoopPattern <> Last_LoopPattern OR IncludeSubfolders <> Last_IncludeSubfolders OR FindMask <> Last_FindMask OR ReplaceMask <> Last_ReplaceMask)
	{
		Last_FindMask := FindMask
		Last_ReplaceMask := ReplaceMask
		;msgbox, % LoopPattern ", " Last_LoopPattern ", " IncludeSubfolders ", " Last_IncludeSubfolders  ", " fileCount  ", " ExampleInput
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
		
		PrepareMasks(FindMask, ReplaceMask)
		
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
			ExampleOutput := RegExReplace(ExampleInput, FindMask, ReplaceMask)
			;Msgbox, "%exampleinput%" `n "%exampleoutput%"
			if (ExampleInput = ExampleOutput)
			{
				ExampleUnchanged .= ExampleInput "`n"
				unchangedN++
			}
			else
			{
				ExampleChanged .= ExampleInput "`n"
				ExampleChangedTo .= ExampleOutput "`n"
				changedN++
			}
			
			
			if(unchangedN >= MAX_EXAMPLE_FILES or changedN >= MAX_EXAMPLE_FILES)
				break	
		}
	}
	;else
	;	Msgbox, Cached fileCount: %fileCount%
		
	if fileCount = "NONE"
	{
		Gui, Font, cRed
		GuiControl, Font, LoopPattern
		return
	}
	Gui, Font, cGreen  
	GuiControl, Font, LoopPattern



	;MsgBox, ExampleInput:%ExampleInput%`nFindMask: "%FindMask%"`nReplaceMask:"%ReplaceMask%"`nExampleOutput:"%ExampleOutput%"
	GuiControl,,ExampleUnchanged, %ExampleUnchanged%
	GuiControl,,ExampleChanged, %ExampleChanged%
	GuiControl,,ExampleChangedTo, %ExampleChangedTo%
return

StartOrganize:
	Gui, submit, nohide
	Organize(LoopPattern, IncludeSubfolders, OverwriteIfNotOlder, OverwriteIfNotSmaller, FindMask, ReplaceMask)
return


Organize(LoopPattern, IncludeSubfolders, OverwriteIfNotOlder, OverwriteIfNotSmaller, FindMask, ReplaceMask)
{
	GuiControl, Disable, StartOrganize
	PrepareMasks(FindMask, ReplaceMask)
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
		NewPath	:= RegExReplace(OldPath, FindMask, ReplaceMask)

		
		SlashPos := InStr(NewPath,"\",false,0)
		
		NewFolder := false
		if(SlashPos)
			NewFolder := Substr(NewPath, 1,SlashPos-1)
		
		if(NewFolder)
			FileCreateDir, %NewFolder%
		/*
		doTryAgain = true
		while (doTryAgain)
		{
		*/
		if(OldPath <> NewPath)
		{
			;MsgBox, OldPath: "%OldPath%"`nFindMask: "%FindMask%"`nReplaceMask:"%ReplaceMask%"`nNewPath:"%NewPath%"`nNewFolder:"%NewFolder%"
			ifExist, %NewPath%
			{
				FileGetSize TargetSize, %NewPath%
				FileGetSize SourceSize, %OldPath%
				FileGetTime, TargetDate, %NewPath%
				FileGetTime, SourceDate, %OldPath%
				DateDiff := SourceDate
				EnvSub, DateDiff, TargetDate, Seconds ; Source - Target
				if ((OverwriteIfNotOlder and DateDiff >= 0) or (OverwriteIfNotSmaller and SourceSize >= TargetSize))
					FileMove, %OldPath%, %NewPath%, 1     
			}
			else
				FileMove, %OldPath%, %NewPath%
			
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
		/*	<folder>\<u>\<file>
		<folder>_<u>\<file>
		
		Why_2\*.*
		<folder>\<file>
		<folder>__\<file>
		
		if(ErrorLevel)
			{
				Msgbox, 2, File Copy Error, ERROR! %ErrorLevel% file(s) could not be moved.`nFrom: %OldPath%`nTo:%NewPath%
				IfMsgBox, Cancel
				{
					GuiControl,,ProgressBar, 0
					return
				}
				IfMsgBox, Continue
					doTryAgain = false
			}
		}
		*/
		
		GuiControl,,ProgressBar,% 100 * A_Index / FileCount   ;%
	}
	GuiControl,+cGreen,ProgressBar
	GuiControl, Enable, StartOrganize
}

PrepareMasks(ByRef FindMask, ByRef ReplaceMask)
{
	FindMask := RegExReplace(FindMask, "iJ)([\.\?\+\[\{\|\(\)\^\$\\])","\$1")
	StringReplace, FindMask, FindMask, *, [^""><]*, All
	FindMask := RegExReplace(FindMask, "iJ)<(.+?)>(.*)<\1>","<$1>$2\k'$1'")
	;//msgbox, % RegexMatch("a-a", "iJ)(?P<f>.*)-\k<f>", match) ;%
	FindMask := RegExReplace(FindMask, "iJ)<(.+?)>","(?P<$1>.*)")
	ReplaceMask := RegExReplace(ReplaceMask, "i)<(.+?)>","$${$1}")
	StringReplace, ReplaceMask, ReplaceMask, *, [^""><]*, All
	FindMask 	= ^%FindMask%$
}

StrDup(char, n)
{
	r = 
	loop, %n%
		r .=  char
	return %r%
}