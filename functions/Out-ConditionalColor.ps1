filter Out-ConditionalColor{
    param(
		$ConditionColor
    )
	$color=$null
	$fgc=$Host.UI.RawUI.ForegroundColor;
    foreach($key in $ConditionColor.Keys){
		$sb=[scriptblock]::Create($key)
		if(&$sb){$color=$ConditionColor.$key}
	}
	if ($color){$Host.UI.RawUI.ForegroundColor=$color}
	$_
    $Host.UI.RawUI.ForegroundColor=$fgc
}
#
#example usage
#build the hashtable with condition/color pairs
$ht=@{}
$upperLimit=1000
$ht.Add("`$_.handles -gt $upperLimit","red")
$ht.Add('$_.handles -lt 50',"green")
$ht.Add('$_.Name -eq "svchost"',"blue")
Get-Process | Out-ConditionalColor -conditionColor $ht | select name,handles

