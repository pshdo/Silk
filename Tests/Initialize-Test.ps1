
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '..\Tools\Pester' -Resolve)

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Silk\Import-Silk.ps1' -Resolve)
