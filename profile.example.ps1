# Powershell profile example for posh-p4
#Zougi. 27/02/2016 

Import-Module posh-p4

function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host($pwd.ProviderPath) -nonewline

    #perforce status
    Write-P4Prompt

    $global:LASTEXITCODE = $realLASTEXITCODE
	return "> "
}

#
# another prompt sample
# posh-p4 enabled, posh-git enabled and current folder in window's top bar
#
#function global:prompt {
#
#    $realLASTEXITCODE = $LASTEXITCODE
#
#    #perforce status
#    Write-P4Prompt
#
#    #git status
#    Write-VcsStatus
#
#    $global:LASTEXITCODE = $realLASTEXITCODE
#
#    #override window title with current folder
#    $Host.UI.RawUI.WindowTitle = "$pwd - Windows Powershell"
#
#    return "$ "
#}
