<#
.SYNOPSIS
  perforce prompt for windows powershell
.DESCRIPTION
  posh-p4 Module:
  Bring P4 pending changelist info to the prompt. Kinda like we have with posh-git
.NOTES
  Author: Frederic ROUSSEAU
#>

# you can override this settings from your $PROFILE
$global:P4PromptSettings = New-Object PSObject -Property @{
  BeforeDepotText= ' p4:('
  AfterDepotText = ') '
  BraceDepotColor = [System.ConsoleColor]::Cyan
  DepotColor = [System.ConsoleColor]::DarkGreen
  DepotBehindColor = [System.ConsoleColor]::DarkRed
  DepotErrorColor = [System.ConsoleColor]::Cyan
  ChangesColor = [System.ConsoleColor]::Yellow
}

#invoke-expression .. with timeout
#also redirect stderr to stdout. default timeout is 2 seconds
function iext ($cmd, $timeout = 2) {
  $StartTime = Get-Date
  $newPowerShell = [PowerShell]::Create().AddScript("set-location $PWD; $cmd 2>&1")
  $job = $newPowerShell.BeginInvoke()
  While (-Not $job.IsCompleted) {
    $elapsedTime = $(Get-Date) - $StartTime
    if ($elapsedTime.seconds -ge $timeout) {
      return ""
    }
  }
  $result = $newPowerShell.EndInvoke($job)
  $newPowerShell.Dispose()
  $result
}

#write perforce status information for current folder
function Write-P4Prompt() {
  $s = $global:P4PromptSettings
  
  $mapInfo = iext "p4 where ..."
  if ($mapInfo -like "*password (P4PASSWD) invalid*") {
    $p4pwd = Read-Host -assecurestring "p4 password"
    $p4password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p4pwd))
    $res = ($p4password | p4 login 2>&1)
    if ($res -like "*invalid*") {
      Write-Host $res
      return
    } else {
     $mapInfo = iext "p4 where ..."
	 $depotLocation = $mapInfo | % { $_.substring(0,$_.indexOf("/...")) }
    }
  } elseif ($mapInfo -like "*is not under client`'s root*") {
    return
  } elseif ($mapInfo -NotLike "//*" -or (($mapInfo | measure-object -line).lines -gt 1)) {
    $depotLocation = "!"
  } else {
    $depotLocation = $mapInfo | % { $_.substring(0,$_.indexOf("/...")) }
  }

  $changed = 0
  $added = 0
  $deleted = 0
  $hasLastRevision = $false

  if ($depotLocation -ne "!") {
    #changed files:
    $p4opened = iext "p4 opened"
	if ($p4opened -ne "") {
	  $changed = ($p4opened | select-string -pattern 'not opened' -notmatch | measure-object -line).lines
	} else {
	  $changed = "?"
    }
    #new files not yet added or deleted:
    $p4status = iext "p4 status ..." 3
	if ($p4status -ne "") {
	  $p4status | %{ if($_ -match "to delete"){ $deleted += 1 } elseif ($_ -match "to add") { $added +=1 } }
	} else {
	  $deleted = "?"
	  $added = "?"
    }
    #is there any changes on depot
	$p4cstat = "p4 cstat ..."
	if ($p4cstat -ne "") {
      $hasLastRevision = $p4cstat | select -Last 2 | select -First 1 | % { $_ -like "*have*" }
	} else {
	  $hasLastRevision = "?"
	}
  }

  Write-Host $s.BeforeDepotText -NoNewLine -ForegroundColor $s.BraceDepotColor
  
  if ($hasLastRevision -ne "?") {
    $colorDepot = if ($hasLastRevision) {$s.DepotColor} else {$s.DepotBehindColor}
  } else {
    $colorDepot = $s.DepotErrorColor
  }
  Write-Host $depotLocation -NoNewLine -ForegroundColor $colorDepot

  Write-Host $s.AfterDepotText -NoNewLine -ForegroundColor $s.BraceDepotColor

  if (($added -ne 0) -or ($changed -ne 0) -or ($deleted -ne 0)) {
    Write-Host "[" -NoNewLine -ForegroundColor $s.ChangesColor
    Write-Host "+$added ~$changed -$deleted" -NoNewLine -ForegroundColor $s.DepotBehindColor
    Write-Host "]" -NoNewLine -ForegroundColor $s.ChangesColor
  }
}
