# If (!(Get-InstalledModule posh-git -ErrorAction silentlycontinue)) {
# Write-Host "Installing posh-git..."
# Install-Module posh-git -Scope CurrentUser -Force
# Write-Host "posh-git installed..."
# }
Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History

Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineOption -Colors @{ InlinePrediction = '#875f5f' }
Import-Module syntax-highlighting

Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
Import-Module posh-git
Clear-Host
Import-Module oh-my-posh
Clear-Host
#Set-PoshPrompt -Theme Paradox

$env:THEME_FOLDER = $env:USERPROFILE + "\OneDrive\Documentos\WindowsPowerShell\Themes\"
$env:THEME_FILE = "dev-environment.json"
$env:THEME_FULL_PATH = $env:THEME_FOLDER + $env:THEME_FILE
oh-my-posh init pwsh --config  $env:THEME_FULL_PATH  | Invoke-Expression
Clear-Host
#Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
 Import-Module "$ChocolateyProfile"
 Clear-Host
}
Clear-Host
