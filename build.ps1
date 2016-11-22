<#
.SYNOPSIS
Sets the version number for the LibGit2 module.
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
[CmdletBinding()]
param(
    [Version]
    # The version to build. If not supplied, build the version as currently defined.
    $Version,

    [Switch]
    # Build and create packages that will be published.
    $ForRelease
)

#Requires -Version 4
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Silk\Import-Silk.ps1' -Resolve)

$manifestPath = Join-Path -Path $PSScriptRoot -ChildPath 'Silk\Silk.psd1'

$manifest = Test-ModuleManifest -Path $manifestPath
if( -not $manifest )
{
    return
}

$nuspecPath = Join-Path -Path $PSScriptRoot -ChildPath 'Silk.nuspec' -Resolve
$releaseNotesPath = Join-Path -Path $PSScriptRoot -ChildPath 'RELEASE_NOTES.md' -Resolve

# If you need to compile an assembly or other code, add SolutionPath and AssemblyInfoPath parameters, e.g.
#                 -SolutionPath (Join-Path -Path $PSScriptRoot -ChildPath 'Source\Silk.sln' -Resolve) `
#                 -AssemblyInfoPath (Join-Path -Path $PSScriptRoot -ChildPath 'Source\Silk\Properties\AssemblyInfo.cs' -Resolve)
Set-ModuleVersion -ManifestPath $manifestPath `
                  -Version $Version `
                  -ReleaseNotesPath $releaseNotesPath `
                  -NuspecPath $nuspecPath

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Tools\Pester' -Resolve)

$result = Invoke-Pester -Script (Join-Path -Path $PSScriptRoot -ChildPath 'Tests') -PassThru
if( $result.FailedCount )
{
    exit
}

if( -not $ForRelease )
{
    return
}

$valid = Assert-ModuleVersion -ManifestPath $manifestPath -ReleaseNotesPath $releaseNotesPath -NuspecPath $nuspecPath -ExcludeAssembly 'LibGit2Sharp.dll'
if( -not $valid )
{
    Write-Error -Message ('Silk isn''t at the right version. Please use the -Version parameter to set the version.')
    return
}

Set-ReleaseNotesReleaseDate -ManifestPath $manifestPath -ReleaseNotesPath $releaseNotesPath

$tags = @( 'powershell', 'module', 'help', 'tools' )

Set-ModuleManifestMetadata -ManifestPath $manifestPath -Tag $tags -ReleaseNotesPath $releaseNotesPath

$outputDirectory = Join-Path -Path $PSScriptRoot -ChildPath 'Output'
if( (Test-Path -Path $outputDirectory -PathType Container) )
{
    Get-ChildItem -Path $outputDirectory | Remove-Item -Recurse
}
else
{
    New-Item -Path $outputDirectory -ItemType 'directory'
}

Set-ModuleNuspec -ManifestPath $manifestPath `
                 -NuspecPath $nuspecPath `
                 -ReleaseNotesPath $releaseNotesPath `
                 -Tags $tags `
                 -PackageID 'Silk.PowerShell' `
                 -PackageTitle 'Silk.PowerShell'


New-NuGetPackage -OutputDirectory (Join-Path -Path $outputDirectory -ChildPath 'nuget.org') `
                 -ManifestPath $manifestPath `
                 -NuspecPath $nuspecPath `
                 -NuspecBasePath $PSScriptRoot `
                 -PackageName 'Silk.PowerShell'

Set-ModuleNuspec -ManifestPath $manifestPath `
                 -NuspecPath $nuspecPath `
                 -ReleaseNotesPath $releaseNotesPath `
                 -Tags $tags `
                 -PackageID 'Silk' `
                 -PackageTitle 'Silk'

New-ChocolateyPackage -OutputDirectory (Join-Path -Path $outputDirectory -ChildPath 'chocolatey.org') `
                      -ManifestPath $manifestPath `
                      -NuspecPath $nuspecPath

$source = Join-Path -Path $PSScriptRoot -ChildPath 'Silk'
$destination = Join-Path -Path $outputDirectory -ChildPath 'Silk'
robocopy.exe $source $destination /MIR /NJH /NJS /NP /NDL /XD /XF '*.pdb'

$examplesDir = Join-Path -Path $destination -ChildPath 'Examples'
New-Item -Path $examplesDir -ItemType 'Directory'

Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'build.ps1') |
    Copy-Item -Destination (Join-Path -Path $examplesDir -ChildPath 'Invoke-Build.ps1')

Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'New-Website.ps1') |
    Copy-Item -Destination $examplesDir

Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Publish-Silk.ps1') |
    Copy-Item -Destination (Join-Path -Path $examplesDir -ChildPath 'Publish-Module.ps1')

Get-ChildItem -Path 'RELEASE_NOTES.md','LICENSE','NOTICE' | Copy-Item -Destination $destination
