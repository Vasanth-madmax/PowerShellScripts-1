#http://stackoverflow.com/questions/4559233/technique-for-selectively-formatting-data-in-a-powershell-pipeline-and-output-as
function ConvertTo-HtmlConditionalFormat{
	param(
		$objects,
		$htConditionalFormat,
		$path,
		[switch]$open
	)
	Add-Type -AssemblyName System.Xml.Linq
	$xml = [System.Xml.Linq.XDocument]::Parse( "$($objects | ConvertTo-Html)" )
	$ns='http://www.w3.org/1999/xhtml'
	$cells = $xml.Descendants("{$ns}td")
	foreach($key in $htConditionalFormat.Keys){
		$sb=[scriptblock]::Create($key)
		$colIndex = (($xml.Descendants("{$ns}th") | Where-Object { $_.Value -eq $htConditionalFormat.$key[0] }).NodesBeforeSelf() | Measure-Object).Count
		$cells | Where { ($_.NodesBeforeSelf() | Measure).Count -eq $colIndex} | foreach {
			if(&$sb){
				$_.SetAttributeValue( "style", $htConditionalFormat.$key[1])
			}
		}
	}
	$xml.Save("$path")

	if ($open){
		ii $path
	}
}
#example usage

$path="$env:TEMP\test.html"
#build the hashtable with Condition (of property to be met)/Property/css style to apply
$ht=@{}
$upperLimit=1000
$ht.Add("[int]`$_.Value -gt $upperLimit",("Handles","color:green"))
$ht.Add('[int]$_.Value -lt 50',("Handles","background-color:red"))
$ht.Add('$_.Value -eq "rundll32"',("Name","background-color:blue"))
ConvertTo-HtmlConditionalFormat (Get-Process) $ht $path -open

$path="$env:TEMP\test.html"
#build the hashtable with Condition (of property to be met)/Property/css style to apply
$ht=@{}
$ht.Add('$_.Value -eq ".txt"',("Extension","background-color:blue"))
$ht.Add('$_.Value -eq ".bmp"',("Extension","background-color:red"))
ConvertTo-HtmlConditionalFormat (dir | select FullName,Extension,Length,LastWriteTime) $ht $path -open

