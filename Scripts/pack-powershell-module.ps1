[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    [string]
    $Path,

    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    [string]
    $Destination,

    [Parameter(Mandatory = $true)]
    [version]
    $ModuleVersion,

    [Parameter(Mandatory = $true)]
    [string]
    $CertificateFilePath,

    [Parameter(Mandatory = $true)]
    [SecureString]
    $CertificatePassword
)

. $PSScriptRoot\powershell-module-functions.ps1

$Path = Resolve-Path $Path -ErrorAction Stop
$Destination = Resolve-Path $Destination
Write-Verbose "Path: '$Path'."
Write-Verbose "Destination: '$Destination'."

# Get Module Name
$moduleManifestFile = Get-ModuleManifest -Path $Path
Write-Host "Module manifest file: '$($moduleManifestFile.FullName)'."
$destinationModulePath = Join-Path $Destination $moduleManifestFile.BaseName
Write-Host "Module destination path: '$destinationModulePath'."

# Update version in the manifest
Update-ModuleVersion -Path $moduleManifestFile.FullName -Version $ModuleVersion
Write-Host "Version set to $ModuleVersion in manifest file '$moduleManifestFile'."

Push-Location $Path
# Create Destination Directories
$target = New-Item -Path $destinationModulePath -Force -ItemType Directory
Write-Host "Destination path created: '$($target.FullName)'."
Get-ChildItem -Path $Path -Recurse -Depth 1 -Exclude Tests -Directory |
    Resolve-Path -Relative |
    ForEach-Object { New-Item -Path (Join-Path $target.FullName $_.Substring(2)) -ItemType Directory -Force }
# Create Destination Files
$certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $CertificateFilePath, $CertificatePassword, 'DefaultKeySet'
Get-ChildItem -Path $Path -Recurse -Depth 1 -Exclude *.Tests.ps1, *.yml, *.md -File |
    Resolve-Path -Relative |
    ForEach-Object { Copy-Item -Path $_ -Destination (Join-Path $target.FullName $_.Substring(2)) -Force -Verbose -PassThru } |
    Where-Object { $_.Extension -match '^\.ps.?1$' } |
    Set-AuthenticodeSignature -Certificate $certificate -TimestampServer "http://timestamp.verisign.com/scripts/timstamp.dll" -IncludeChain Signer
Write-Host "Module created and signed in '$destinationModulePath'."
Pop-Location