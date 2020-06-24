function Get-ModuleManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )
    $moduleManifestFile = Get-ChildItem -Path $Path -Filter *.psd1 -File -Recurse -Depth 1
    if ($moduleManifestFile -isnot [System.IO.FileInfo]) {
        throw "Unique module manifest file could not be found in '$($Path.FullName)'."
    }
    $moduleManifestFile
}

function Update-ModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [version]
        $Version
    )
    $pattern = "(ModuleVersion\s*=\s*['`"])\d+(?:\.\d+){1,3}(['`"])"
    (Get-Content $Path -Raw) -creplace $pattern, "`${1}$Version`${2}" | Set-Content -Path $Path
}
