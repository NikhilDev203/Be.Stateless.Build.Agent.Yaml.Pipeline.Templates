[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(Mandatory = $true)]
    [string]
    $Path,

    [Parameter(Mandatory = $true)]
    [string]
    $NuGetApiKey
)

. $PSScriptRoot\powershell-module-functions.ps1

$Path = Resolve-Path $Path -Verbose -ErrorAction Stop

# Determine Module Path
$moduleManifestFile = Get-ModuleManifest -Path $Path
Write-Host "Module manifest file: '$($moduleManifestFile.FullName)'."
$modulePath = Split-Path $moduleManifestFile.FullName
Write-Host "Module path: '$modulePath'."

Publish-Module -Path $modulePath -NuGetApiKey $NuGetApiKey