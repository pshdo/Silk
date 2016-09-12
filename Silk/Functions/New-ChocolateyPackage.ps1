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

function New-ChocolateyPackage
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
        # The directory where the .nupkg file should be saved.
        $OutputDirectory
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if( -not (Get-Command -Name 'choco.exe' -ErrorAction Ignore) )
    {
        Write-Error -Message ('choco.exe not found. Please install Chocoatey from chocolatey.org')
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

    Push-Location -Path $OutputDirectory
    try
    {
        Get-ChildItem -Path '*.nupkg' | Remove-Item

        $verbosity = ''
        if( $VerbosePreference -eq 'Continue' )
        {
            $verbosity = '-v'
        }

        choco.exe pack $NuspecPath --version=$($manifest.Version) $verbosity
        if( -not (Test-Path -Path '*.nupkg' -PathType Leaf) )
        {
            Write-Error -Message 'Chocolatey package not created.'
        }
    }
    finally
    {
        Pop-Location
    }
}