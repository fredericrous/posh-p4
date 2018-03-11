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
  DepotBraceColor = [System.ConsoleColor]::Gray
  DepotColor = [System.ConsoleColor]::DarkGreen
  DepotBehindColor = [System.ConsoleColor]::DarkRed
  DepotErrorColor = [System.ConsoleColor]::Cyan
  BeforeChangesText = '['
  ChangesText = "+{0} ~{1} -{2}"
  AfterChangesText = ']'
  ChangesBraceColor = [System.ConsoleColor]::Yellow
  ChangesTextColor = [System.ConsoleColor]::DarkRed
}

#invoke-expression .. with timeout
#also redirect stderr to stdout. default timeout is 2 seconds
function iext($cmd, $timeout = 2) {
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
  return $result
}

#get depot location and ask for password if not logged
function getDepotLocation() {
  $mapInfo = iext "p4 where ..."
  
  #display nothing if timeout
  if ($mapInfo -eq "") {
    return ""
  }
  
  #ask for password if P4PASSWD invalid or session has expired
  if (($mapInfo -like "*password (P4PASSWD) invalid*") -or ($mapInfo -like "*session has expired*")) {
    $p4pwd = Read-Host -assecurestring "p4 password"
    $p4password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p4pwd))
    $res = ($p4password | p4 login 2>&1)
    if ($res -like "*invalid*") {
      Write-Host $res
      return
    } else {
     return getDepotLocation
    }
  } elseif ($mapInfo -like "*is not under client`'s root*") {
    return ""
  } elseif ($mapInfo -like "*unknown - use 'client' command to create it.*") {
    return ""
  } elseif ($mapInfo -NotLike "//*" -or (($mapInfo | measure-object -line).lines -gt 1)) {
    $depotLocation = "!"
  } elseif ($mapInfo.indexOf("/...") -ne -1) {
    $depotLocation = $mapInfo | % { $_.substring(0,$_.indexOf("/...")) }
  } else {
    $depotLocation = ""
  }
  return $depotLocation
}

# get a status on default changelist like "+1 ~3 -0". if request timeout return "?"
function pendingStatus() {
  $s = $global:P4PromptSettings
  $changed = 0
  $added = 0
  $deleted = 0
  $promptStatus = $s.ChangesText -f $added,$changed,$deleted
  
  $p4opened = iext "p4 opened"
  if ($p4opened -ne "") {
    foreach ($opened in $p4opened) {
      if ($opened -match "edit default change") {
        $changed += 1
      } elseif ($opened -match "add default change") {
        $added +=1
      } elseif ($opened -match "delete default change") {
        $deleted +=1
      }
    }
	$promptStatus = $s.ChangesText -f $added,$changed,$deleted
  } else {
    $promptStatus = "?"
  }
  return $promptStatus
}

#check is there are new submitted changes on depot
function changesOnDepot() {
  $p4cstat = iext "p4 cstat ..."
  if ($p4cstat -ne "") {
    $hasLastRevision = $p4cstat | select -Last 2 | select -First 1 | % { $_ -like "*have*" }
  } else {
    $hasLastRevision = "?"
  }
  return $hasLastRevision
}

#write perforce status information for current folder
#ie: p4:(//mydepot/myproj/subfolder) [+0 ~1 -0]
function Write-P4Prompt() {
  $s = $global:P4PromptSettings
  
  $depotLocation = getDepotLocation
  #do not display prompt when there is no depot
  if ($depotLocation -eq "") {
    return
  }

  if ($depotLocation -ne "!") {
    #changed files:
    $promptStatus = pendingStatus
  
    #is there any changes on depot
    $hasLastRevision = changesOnDepot
  }

  Write-Host $s.BeforeDepotText -NoNewLine -ForegroundColor $s.DepotBraceColor
  
  if ($hasLastRevision -ne "?") {
    $colorDepot = if ($hasLastRevision -eq "True") {$s.DepotColor} else {$s.DepotBehindColor}
  } else {
    $colorDepot = $s.DepotErrorColor
  }
  Write-Host $depotLocation -NoNewLine -ForegroundColor $colorDepot

  Write-Host $s.AfterDepotText -NoNewLine -ForegroundColor $s.DepotBraceColor
  
  $emptyChangesText = $s.ChangesText -f 0,0,0  
  #display changesText if there are changes..
  if ($promptStatus -ne $emptyChangesText) {
    Write-Host $s.BeforeChangesText -NoNewLine -ForegroundColor $s.ChangesBraceColor
    Write-Host $promptStatus -NoNewLine -ForegroundColor $s.ChangesTextColor
    Write-Host $s.AfterChangesText -NoNewLine -ForegroundColor $s.ChangesBraceColor
  }
}
