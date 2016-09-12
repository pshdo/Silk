# Copyright 2012 Aaron Jensen
# 
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

function New-NuGetPackage
{
    <#
    .SYNOPSIS
    Creates a NuGet package.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the module manifest of the module you want to publish.
        $ManifestPath,

        [Parameter(Mandatory=$true)]
        [string]
        # The path to the nuspec file for the NuGet package to publish.
        $NuspecPath,

        [Parameter(Mandatory=$true)]
        [string]
        # The base directory for the files defined in the `NuspecPath` file.
        $NuspecBasePath,

        [string]
        # The name of the NuGet package, if it is different than the module name.
        $PackageName,

        [Parameter(Mandatory=$true)]
        [string]
        # The directory where the .nupkg file should be saved.
        $OutputDirectory
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $nugetPath = Join-Path -Path $PSScriptRoot -ChildPath '..\bin\NuGet.exe' -Resolve
    if( -not $nugetPath )
    {
        return
    }

    if( -not (Test-Path -Path $OutputDirectory -PathType Container) )
    {
        New-Item -Path $OutputDirectory -ItemType 'directory' -Force
    }

    $manifest = Test-ModuleManifest -Path $ManifestPath
    if( -not $manifest )
    {
        return
    }

    if( -not $PackageName )
    {
        $PackageName = $manifest.Name
    }

    Push-Location -Path $NuSpecBasePath
    try
    {
        $nupkgPath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.{1}.nupkg' -f $PackageName,$manifest.Version)
        if( (Test-Path -Path $nupkgPath -PathType Leaf) )
        {
            Remove-Item -Path $nupkgPath
        }

        $verbosity = 'normal'
        if( $VerbosePreference -eq 'Continue' )
        {
            $verbosity = 'detailed'
        }
        & $nugetPath pack $NuspecPath -BasePath '.' -NoPackageAnalysis -Verbosity $verbosity -OutputDirectory $OutputDirectory
        if( -not (Test-Path -Path $nupkgPath -PathType Leaf) )
        {
            Write-Error ('NuGet package ''{0}'' not found.' -f $nupkgPath)
            return
        }
    }
    finally
    {
        Pop-Location
    }
}