function Invoke-Starship-TransientFunction {
    (&starship module time) + (&starship module directory) + "$ "
}
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt



#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
carapace _carapace | Out-String | Invoke-Expression

atuin init powershell --disable-up-arrow | Out-String | Invoke-Expression

# 将 Ctrl+/ 绑定到 Ctrl+r 的功能（atuin search）
Set-PSReadLineKeyHandler -Chord "Ctrl+/" -BriefDescription "Runs Atuin search" -ScriptBlock {
    $atuinModule = Get-Module Atuin
    if ($atuinModule) {
        & $atuinModule { Invoke-AtuinSearch }
    }
}

###

Set-PSReadLineKeyHandler -Chord "Ctrl+d" -BriefDescription "Exits the shell" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' exit')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
