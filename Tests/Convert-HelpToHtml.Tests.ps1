
$tempDir = 'Silk-{0}' -f [IO.Path]::GetRandomFileName()
$tempDir = Join-Path -Path $env:TEMP -ChildPath $tempDir
New-Item -Path $tempDir -ItemType 'Directory' | Out-String | Write-Verbose

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function Global:SilkDocumentMe
{
    <#
    .SYNOPSIS
    Function that exists to test the `Convert-HelpToHtml` function.

    Make sure it supports multiple paragraphs.

    .DESCRIPTION
    The `SilkDocumentMe` function is a dummy function that only exists to test the `Convert-HelpToHtml` function.

    You should never use it.

    You shouldn't be able to, since the tests delete it from scope when they're done.  Ha ha!

    .INPUTS
    System.String. *Description*

    .INPUTS
    System.Object

    .OUTPUTS
    System.Uri.

    .OUTPUTS
    System.DateTime *Description*

    .LINK
    http://get-silk.org

    .LINK
    https://bitbucket.org/splatteredbits/silk

    .NOTES
    Line 1. *Italic*

    Line 2. **Bold**

    Line 3. `Monospace`

    .EXAMPLE
    SilkDocumentMet -First 'fubar' -Second 'snafu'

    Demonstration so that we make sure `Convert-HelpToHtml` properly shows examples.

    Hopefully, it also supports multiple paragraphs.

    .EXAMPLE
    SilkDocumentMet -First 'fubar'

    This example exists to make sure multiple examples are converted to HTML.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The first parameter.
        #
        # The first parameter's second paragraph.
        $First,

        [Parameter(Mandatory=$true)]
        [string]
        $Second
    )

    Set-StrictMode -Version 'Latest'
}

Describe 'Convert-HelpToHtml' {

    BeforeAll {
    }

    AfterAll {
        Remove-Item -Path $tempDir -Recurse
        Remove-Item -Path 'function:SilkDocumentMe'
    }

    It "converts comment based help to HTML" {

        Get-Command -Name 'SilkDocumentMe' | Should Not BeNullOrEmpty

        $html = Convert-HelpToHtml -Name 'SilkDocumentMe'
        Write-Verbose -Message $html
        $html | Should Be @"
<h1>SilkDocumentMe</h1>
<div class="Synopsis">
<p>Function that exists to test the <code>Convert-HelpToHtml</code> function.</p>`n`n<p>Make sure it supports multiple paragraphs.</p>
</div>

<h2>Syntax</h2>
<pre class="Syntax"><code>SilkDocumentMe [-First] &lt;String&gt; [-Second] &lt;String&gt; [&lt;CommonParameters&gt;]</code></pre>

<h2>Description</h2>
<div class="Description">
<p>The <code>SilkDocumentMe</code> function is a dummy function that only exists to test the <code>Convert-HelpToHtml</code> function.</p>`n`n<p>You should never use it.</p>`n`n<p>You shouldn't be able to, since the tests delete it from scope when they're done.  Ha ha!</p>
</div>

<h2>Related Commands</h2>

<ul class="RelatedCommands">
<li><a href="http://get-silk.org">http://get-silk.org</a></li>
<li><a href="https://bitbucket.org/splatteredbits/silk">https://bitbucket.org/splatteredbits/silk</a></li>
</ul>

<h2> Parameters </h2>
<table id="Parameters">
<tr>
	<th>Name</th>
    <th>Type</th>
	<th>Description</th>
	<th>Required?</th>
	<th>Pipeline Input</th>
	<th>Default Value</th>
</tr>
<tr valign='top'>
	<td>First</td>
	<td><a href="http://msdn.microsoft.com/en-us/library/system.string.aspx">String</a></td>
	<td class="ParamDescription"><p>The first parameter.</p>`n`n<p>The first parameter's second paragraph.</p></td>
	<td>true</td>
	<td>false</td>
    <td></td>
</tr>
<tr valign='top'>
	<td>Second</td>
	<td><a href="http://msdn.microsoft.com/en-us/library/system.string.aspx">String</a></td>
	<td class="ParamDescription"></td>
	<td>true</td>
	<td>false</td>
    <td></td>
</tr>

</table>

<h2>Input Types</h2>
<div class="InputTypes">
<p><a href="http://msdn.microsoft.com/en-us/library/system.string.aspx">System.String</a>. <em>Description</em></p>
<p><a href="http://msdn.microsoft.com/en-us/library/system.object.aspx">System.Object</a>. </p>
</div>

<h2>Return Values</h2>
<div class="ReturnValues">
<p><a href="http://msdn.microsoft.com/en-us/library/system.uri.aspx">System.Uri</a>. </p>
<p><a href="http://msdn.microsoft.com/en-us/library/system.datetime.aspx">System.DateTime</a>. <em>Description</em></p>
</div>

<h2>Notes</h2>
<div class="Notes">
<p>Line 1. <em>Italic</em></p>`n`n<p>Line 2. <strong>Bold</strong></p>`n`n<p>Line 3. <code>Monospace</code></p>
</div>

<h2>EXAMPLE 1</h2>
<pre><code>SilkDocumentMet -First 'fubar' -Second 'snafu'</code></pre>
<p>Demonstration so that we make sure <code>Convert-HelpToHtml</code> properly shows examples.</p>`n`n<p>Hopefully, it also supports multiple paragraphs.</p>


<h2>EXAMPLE 2</h2>
<pre><code>SilkDocumentMet -First 'fubar'</code></pre>
<p>This example exists to make sure multiple examples are converted to HTML.</p>

"@
    }
     
    It "converts examples with multiple remarks" {
        $html = Convert-HelpToHtml -Name 'Get-Module'

        $help = Get-Help -Name 'Get-Module'

        $help | Should Not BeNullOrEmpty
        ,@($help.Examples.example[8].remarks.text) | Should Not BeNullOrEmpty
        $help.Examples.example[8].remarks.text | ForEach-Object { $html | Should Match ([regex]::Escape( $_.Trim() )) }
    }
}