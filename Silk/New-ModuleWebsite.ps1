<#
.SYNOPSIS
Creates a new website for a module, using the module's help topics.

.DESCRIPTION

.EXAMPLE
New-ModuleWebsite -ConfigFilePath silk.json -DestinationPath C:\Inetpub\wwwroot\MyModule

Uses the `silk.json` configuration file to publish a module to `C:\Inetpub\wwwroot\MyModule`
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The path to the Silk configuration file to use.
    $ConfigFilePath,

    [Parameter(Mandatory=$true)]
    [string]
    # The path where the module's help should be published.
    $DestinationPath
)

$Error.Clear()
Set-StrictMode -Version Latest
$PSScriptRoot = Split-Path -Parent -Path $PSCommandPath

& (Join-Path $PSScriptRoot Import-Silk.ps1 -Resolve)

if( -not (Test-Path -Path $ConfigFilePath -PathType Leaf) )
{
    Write-Error ('Silk configuration file <{0}> not found.' -f $ConfigFilePath)
    exit 1
}

$ConfigFilePath = Resolve-Path -Path $ConfigFilePath | Select-Object -ExpandProperty ProviderPath
$ConfigFileRoot = Split-Path -Parent -Path $ConfigFilePath

$config = [IO.File]::ReadAllText( $ConfigFilePath ) | ConvertFrom-Json
if( -not $config )
{
    Write-Error ('Invalid Silk configuration file <{0}>.' -f $ConfigFilePath)
    exit 1
}

$modulePath = $config.ModulePath
if( -not ([IO.Path]::IsPathRooted($modulePath) ) )
{
    $modulePath = Join-Path $ConfigFileRoot $modulePath
}

if( -not (Test-Path -Path $modulePath) )
{
    Write-Error ('ModulePath <{0}> in Silk configuration file <{1}> not found. Relative paths should be relative to the configuration file itself.' -f $modulePath,$ConfigFilePath)
    exit 1
}

$moduleName = $config.ModuleName
if( (Get-Module $moduleName) )
{
    Remove-Module $moduleName
}
Import-Module $modulePath

if( -not (Get-Module $moduleName) )
{
    Write-Error ('Failed to load module <{0}> from <{1}>.' -f $moduleName,$modulePath)
    exit 1
}

$commands = Get-Command -Module $moduleName | 
                Where-Object { $_.ModuleName -eq $moduleName -and $_.Name } | 
                Sort-Object Name 

$menuBuilder = New-Object Text.StringBuilder
[void] $menuBuilder.AppendFormat( @"
	<ul id="SiteNav">
		<li>{0}</li>
	</ul>"@, $moduleName )
[void] $menuBuilder.AppendLine( '<div id="CommandMenuContainer" style="float:left;">' )
[void] $menuBuilder.AppendFormat( "`t<ul class=""CommandMenu"">`n" )
$commands | 
    Where-Object { $config.CommandsToSkip -notcontains $_ } |
    ForEach-Object {
        [void] $menuBuilder.AppendFormat( "`t`t<li><a href=""{0}.html"">{0}</a></li>", $_.Name )
    }
[void] $menuBuilder.AppendLine( "`t</ul>" )
[void] $menuBuilder.AppendLine( '</div>' )

if( -not (Test-Path $DestinationPath -PathType Container) )
{
    New-Item $DestinationPath -ItemType Directory -Force 
}

@"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>{0}</title>
	<link href="styles.css" type="text/css" rel="stylesheet" />
</head>
<body>
    {1}
</body>
</html>
"@ -f $config.Title,$menuBuilder.ToString() | Out-File -FilePath (Join-Path $DestinationPath index.html) -Encoding OEM

Join-Path $PSScriptRoot 'Resources\styles.css' | Get-Item | Copy-Item -Destination $DestinationPath

$commands | 
    #Where-Object { $_.Name -eq 'Invoke-SqlScript' } | 
    Get-Help -Full | 
    Convert-HelpToHtml -Menu $menuBuilder.ToString() -Config $config -DestinationPath $DestinationPath
