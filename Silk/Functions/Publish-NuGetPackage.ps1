﻿# Copyright 2012 Aaron Jensen
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
    Publishes a NuGet package to nuget.org.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the nupkg file to publish.
        $FilePath,

        [string]
        # The API key to use.
        $ApiKey
    )

    Set-StrictMode -Version 'Latest'

    $nugetPath = Join-Path -Path $PSScriptRoot -ChildPath '..\bin\NuGet.exe' -Resolve
    if( -not $nugetPath )
    {
        return
    }

    if( -not (Test-Path -Path $FilePath -PathType Leaf) )
    {
        Write-Error ('NuGet package ''{0}'' not found.' -f $FilePath)
        return
    }
    
    if( -not $ApiKey )
    {
        $ApiKey = Read-Host -Prompt ('Please enter your nuget.org API key')
    }

    & $nugetPath push $FilePath -ApiKey $ApiKey
}