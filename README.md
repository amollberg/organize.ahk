# organize.ahk

Script in AutoHotkey that helps you to preview complex file moves before 
actually performing them. A .conf file can be written using natural English and
dragged-and-dropped onto organize.ahk or passed as a command-line argument 
as a substitute of the GUI.

## File patterns
Source and destination patterns indicate which files are to be moved and where they are to be moved. 
Use `<a>`, `<b>` ... to match any character in the source file name. These same identifiers are then available as backreferences for the destination pattern.

### Examples
* To remove nested identically named folders, use `<f>\<f>\<g>` as source and `<f>\<g>` as destination.
* To flatten a folder structure of three levels, use `<first>\<second>\<third>\<file>` as source and `<first>_<second>_<third>_<file>`

## .conf files
The syntax is:

`Among <global file pattern> [including subfolders] find <source pattern> and [recycle | move to <destination pattern> [overwriting if [newer or] [larger]]]`

See demo.conf for an example.


## Requirements
See: www.autohotkey.com for the required runtime installation.
