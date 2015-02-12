#Requires -Version 3
filter Out-ConditionalColorProperties{
    param(
		$ConditionColorProp
    )
	$color=$null
    foreach($key in $ConditionColorProp.Keys){
		$sb=[scriptblock]::Create($key)
		if(&$sb){
			$color=$ConditionColorProp.$key[0]
			$highlightProp=$ConditionColorProp.$key[1]
		}
	}
    if (!$firstPassed){$objString=($_ | Out-String).TrimEnd() }
    else{$objString=((($_ | Out-String) -split "`n") | where {$_.Trim() -ne ""})[-1]}
	if ($color){
		$highlightText=$_.$highlightProp
		$split = $objString -split $highlightText,2
		$found = [regex]::Match( $objString, $highlightText )
		for( $i = 0; $i -lt $split.Count; ++$i ) {
			Write-Host $split[$i] -NoNewline
		    if ($i -lt $found.Count){
				Write-Host $found[$i] -NoNewline -ForegroundColor $color
			}
		}
		Write-Host
	}
	else{
        $objString
	}
    $firstPassed=$true
}

#
#example usage
#build the hashtable with condition/color/"property value to highlight" pairs
$ht=@{}
$upperLimit=1000
$ht.Add("`$_.handles -gt $upperLimit",("red","handles"))
$ht.Add('$_.handles -lt 50',("green","handles"))
$ht.Add('$_.Name -eq "svchost"',("blue","name"))
Get-Process | Out-ConditionalColorProperties -conditionColorProp $ht 
$ht=@{}
$ht.Add('$_.Name.StartsWith("A")',("red","name"))
dir | Out-ConditionalColorProperties -conditionColorProp $ht

