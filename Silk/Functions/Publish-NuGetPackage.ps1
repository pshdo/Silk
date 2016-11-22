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

function Publish-NuGetPackage
{
    <#
    .SYNOPSIS
    Creates and publishes a NuGet package to nuget.org.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the module manifest of the module you want to publish.
        $NupkgPath,

        [object]
        # The API key(s) to use. To supply multiple API keys, use a hashtable where each key is a repository server name and the value is the API key for that repository. For example,
        #
        # @{ 'nuget.org' = '395edfa5-652f-4598-868e-c0a73be02c84' }
        #
        # If not specified, you'll be prompted for it. 
        $ApiKey
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $nugetPath = Join-Path -Path $PSScriptRoot -ChildPath '..\bin\NuGet.exe' -Resolve
    if( -not $nugetPath )
    {
        return
    }

    if( -not (Test-Path -Path $NupkgPath -PathType Leaf) )
    {
        Write-Error -Message ('NuGet package ''{0}'' does not exist.' -f $NupkgPath)
        return
    }

    $nupkgName = [IO.Path]::GetFileNameWithoutExtension($NupkgPath)
    if( $nupkgName -notmatch '^(.+)\.(\d+\.\d+\.\d)+$' )
    {
        Write-Error -Message ('NuGet package ''{0}'' does not have the version to publish in its name.' -f $nupkgName)
        return
    }

    $packageName = $Matches[1]
    $version = $Matches[2]
    try
    {
        $packageUrl = 'https://nuget.org/api/v2/package/{0}/{1}' -f $packageName,$version
        try
        {
            $resp = Invoke-WebRequest -Uri $packageUrl -ErrorAction Ignore
            $publish = ($resp.StatusCode -ne 200)
        }
        catch
        {
            $publish = $true
        }

        if( -not $publish )
        {
            Write-Warning ('NuGet package {0} {1} already published to nuget.org.' -f $packageName,$version)
            return
        }

        if( $PSCmdlet.ShouldProcess(('publish package to nuget.org'),'','') )
        {
            if( -not $ApiKey )
            {
                $ApiKey = Read-Host -Prompt ('Please enter your nuget.org API key')
                if( -not $ApiKey )
                {
                    Write-Error -Message ('The nuget.org API key is required. Package not published to nuget.org.')
                    continue
                }
            }

            $verbosity = 'normal'
            if( $VerbosePreference -eq 'Continue' )
            {
                $verbosity = 'detailed'
            }

            & $nugetPath push $nupkgPath -ApiKey $ApiKey -Source 'https://nuget.org/api/v2/package' -Verbosity $verbosity

            $resp = Invoke-WebRequest -Uri $packageUrl
            $resp | Select-Object -Property 'StatusCode','StatusDescription',@{ Name = 'Uri'; Expression = { $packageUrl }}
        }
    }
    finally
    {
        Pop-Location
    }
}