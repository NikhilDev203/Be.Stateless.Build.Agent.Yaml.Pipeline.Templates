[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    [string]
    $Path
)

. $PSScriptRoot\powershell-module-functions.ps1

$Path = Resolve-Path -Path $Path -ErrorAction Stop
Get-ModuleManifest -Path $Path | Import-PowerShellDataFile | Select-Object -ExpandProperty RequiredModules | ForEach-Object -Process {
    Write-Host "Importing module $_"
    Install-Module -Name $_ -Scope CurrentUser -Force
}
