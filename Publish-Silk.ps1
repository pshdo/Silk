<#
.SYNOPSIS
Packages and publishes Silk packages.

.DESCRIPTION
The `Publish-Silk.ps1` script packages and publishes a version of the Silk module. It uses the version defined in the Silk.psd1 file. Before publishing, it adds the current date to the version in the release notes, updates the module's website, then tags the latest revision with the version number. It then publishes the module to NuGet, Chocolatey, and the PowerShell Gallery. If the version of Silk being published already exists in a location, it is not re-published. If the PowerShellGet module isn't installed, the module is not publishes to the PowerShell Gallery.

.EXAMPLE
Publish-Silk.ps1

Yup. That's it.
#>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[CmdletBinding(SupportsShouldProcess=$true)]
param(
)

#Requires -Version 4
Set-StrictMode -Version Latest

& (Join-Path -Path $PSScriptRoot -ChildPath 'Silk\Import-Silk.ps1' -Resolve)

$silkRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Output\Silk'
$releaseNotesPath = Join-Path -Path $silkRoot -ChildPath 'RELEASE_NOTES.md' -Resolve

$manifestPath = Join-Path -Path $silkRoot -ChildPath 'Silk.psd1'
$manifest = Test-ModuleManifest -Path $manifestPath
if( -not $manifest )
{
    return
}

$nupkgPath = Join-Path -Path $PSScriptRoot `
                       -ChildPath ('Output\nuget.org\Silk.PowerShell.{0}.nupkg' -f $manifest.Version)
Publish-NuGetPackage -NupkgPath $nupkgPath

$nupkgPath = Join-Path -Path $PSScriptRoot `
                       -ChildPath ('Output\chocolatey.org\Silk.{0}.nupkg' -f $manifest.Version)
Publish-ChocolateyPackage -NupkgPath $nupkgPath

$tags = @( 'powershell', 'module', 'help', 'tools' )

Publish-PowerShellGalleryModule -ManifestPath $manifestPath `
                                -ModulePath $silkRoot `
                                -ReleaseNotesPath $releaseNotesPath `
                                -LicenseUri 'http://www.apache.org/licenses/LICENSE-2.0' `
                                -ProjectUri 'http://get-silk.org' `
                                -Tags $tags
