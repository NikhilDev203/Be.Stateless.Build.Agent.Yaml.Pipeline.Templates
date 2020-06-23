function Get-ModuleManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )
    process {
        $moduleManifestFiles = Get-ChildItem *.psd1 -File -Recurse -Depth 1 -Path $Path
        if ($moduleManifestFiles.Count -gt 1) {
            throw "There are more than one module manifest file in '$($Path.FullName)'."
        }
        if ($moduleManifestFiles.Count -eq 0) {
            throw "There is no module manifest file '$($Path.FullName)'."
        }
        $moduleManifestFiles | Select-Object -First 1
    }
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
    process {
        $match = "(ModuleVersion\s*=\s*)(['|`"]\d*(.\d*){1,3}['|`"])"
        $replacement = "`$1'$Version'"
        (Get-Content $Path) | ForEach-Object { $_ -creplace $match, $replacement } | Set-Content -Path $Path
    }
}
