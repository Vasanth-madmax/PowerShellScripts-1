function Update-Content{
<#
    .SYNOPSIS
        Insert text on a new line after the line matching the startPattern or replace text between start- and end Pattern within a file
        
    .DESCRIPTION
		This is a function to insert new text within the body of a text file using regular expression replace substitution. 
		The insertion points are identified by the provided startPattern and the optional endPattern which can be normal strings or regular expressions.
		In case no endPattern is provided the new text is appended on a new line after the line matching the startPattern. 
		In case both patterns are provided the new text is inserted between the line matching the startPattern and the endPattern 
		replacing any existing text between the lines matching the patterns.
		
    .PARAMETER path
        path to the file to be updated
	
	.PARAMETER startPattern
		pattern of the start line where the new content is appended
	
	.PARAMETER endPattern
		pattern of the end line where the new content is inserted
		
	.PARAMETER content
		text to be inserted
		
    .EXAMPLE  
		#replace text between the lines starting with "//start" and "//end"
		##text before:
		#some text
		#//start
		#text
		#text
		#//end
		
		Update-Content $path "^//start" "^//end" "this is new stuff"
		
		##text afterwards:
		#some text
		#//start
		#this is new stuff
		#//end
        
    .EXAMPLE  
		#append text on a new line after the line starting with "//start"
		##text before:
		#some text
		#//start
		#text
		#text
	
		Update-Content $path "^//start" "new text"
		
		##text before:
		#some text
		#//start
		#new text
		#text
		#text
	
#>
[CmdletBinding()] 
param(
	$path,
	$startPattern,
	$endPattern,
	$content
)
	if ($endPattern){
		[regex]::Replace(([IO.File]::ReadAllText($path)),"($startPattern)([\s\S]*)($endPattern)","`$1`n$content`n`$3",[Text.RegularExpressions.RegexOptions]::Multiline) | 
			Set-Content $path
	}
	else{
		#$& refers to the match when using replace
    	[regex]::Replace(([IO.File]::ReadAllText($path)),"$startPattern","$&`n$content",[Text.RegularExpressions.RegexOptions]::Multiline) | 
			Set-Content $path
	}
}
