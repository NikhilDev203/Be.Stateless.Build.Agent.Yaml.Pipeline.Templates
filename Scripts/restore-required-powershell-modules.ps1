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
$manifest = Get-ModuleManifest -Path $Path | Import-PowerShellDataFile
$manifest.RequiredModules | ForEach-Object -Process {
    Write-Host "Installing module $_"
    Install-Module -Name $_.ModuleName -Scope CurrentUser -SkipPublisherCheck -Force
}
