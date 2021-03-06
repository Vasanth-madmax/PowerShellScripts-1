function Get-Range{
<#
    .SYNOPSIS
        Function to retrieve a continuous or stepwise Range of integers,decimals,dates,month names, day names or chars. Simulating Haskell`s Range operator
        
    .DESCRIPTION
		The function works similar to the built-in Range operator (..). But adds functionality to retrieve stepwise Ranges date, month name, day name and 
		character Ranges like in Haskell.
		
    .PARAMETER Range
        A string that represents the Range. The Range can be specified as START..END or as FIRST,SECOND..END where the difference between
		FIRST and SECOND (positive or negative) determines the step increment or decrement. The elements of the Range can consist of only characters, integers,decimals,dates,month names,day names
		or special PowerShell notation like 1kb,1mb,1e6...
		
	.Example
		Set-Alias gr Get-Range
		#same as built-in
		gr 1..10

		#Range of numbers from 1 to 33 with steps of .2
		gr 1,1.2..33

		#Range of numbers from 10 to 40 with steps of 10
		gr 10,20..40

		#Range of numbers from -2 to 1024 with steps of 6
		gr -2,4..1kb

		#Range of numbers from 10 to 1 with steps of -2
		gr 10,8..1

		#Range of characters from Z to A
		gr Z..A
		
		#Range of date objects 
		gr 1/20/2014..1/1/2014
		
		#Range of month names
		gr March..May
		
		#Range of day names
		gr Monday..Wednesday
    .LINK
        https://powershellone.wordpress.com/2015/03/15/extending-the-powershell-Range-operator/
#>
   [cmdletbinding()] 
   [Alias('gr')]
    param($Range)
	#no step specified
	if ($Range -is [string]) { 
		#check for month name or day name Range
		$monthNames=(Get-Culture).DateTimeFormat.MonthNames
		$dayNames=(Get-Culture).DateTimeFormat.DayNames
		$enum=$null
		if ($monthNames -contains $Range.Split("..")[0]){$enum=$monthNames}
		elseif ($dayNames -contains $Range.Split("..")[0]){$enum=$dayNames}
		if ($enum){
			$start,$end=$Range -split '\.{2}'
			$start=$enum.ToUpper().IndexOf($start.ToUpper()) 
			$end=$enum.ToUpper().IndexOf($end.ToUpper())
			$change=1
			if ($start -gt $end){ $change=-1 }
			while($start -ne $end){
				$enum[$start]
				$start+=$change
			}
			$enum[$end]
			return
		}
		#check for character Range
		if ([char]::IsLetter($Range[0])){
			[char[]][int[]]([char]$Range[0]..[char]$Range[-1])
			return
		}
		#check for date Range
		if (($Range -split '\.{2}')[0] -as [datetime]){
			[datetime]$start,[datetime]$end=$Range -split '\.{2}'
			$change=1
			if ($start -gt $end){ $change=-1 }
			while($start -ne $end){
				write-host $start
				$start=($start).AddDays($change)
			}
			write-host $end
			return
		}
		Invoke-Expression $Range
		return 
	}
	$step=$Range[1].SubString(0,$Range[1].IndexOf("..")) - $Range[0]
	#use invoke-expression to support kb,mb.. and scientific notation e.g. 4e6
	[decimal]$start=Invoke-Expression $Range[0]
	[decimal]$end=Invoke-Expression ($Range[1].SubString($Range[1].LastIndexOf("..")+2))
	$times=[Math]::Truncate(($end-$start)/$step)
	$start
	for($i=0;$i -lt $times ;$i++){
		($start+=$step)
	}
}
