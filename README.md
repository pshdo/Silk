# Overview

Silk is a PowerShell module that contains functions useful for PowerShell module authors. It supports:

 * Converting the help for a module into HTML. Supports help written in Markdown. 
 * Building module assemblies.
 * Building module ZIP and NuGet packages and publishing them to Bitbucket, nuget.org, chocolatey.org, and the Powershell Gallery.
 
# Contributing

Silk is hosted on Bitbucket in a Mercurial repository. To contribute to Silk, do the follwing:

 * [Create a Bitbucket account](https://bitbucket.org/account/signup/), if you don't already have one, then [login](https://bitbucket.org/account/signin/?next=/splatteredbits/silk).
 * Once you're logged in, come back here and [fork Silk](https://bitbucket.org/splatteredbits/silk/fork). This creates your own copy of Silk that you can make changes to. 
 * You now have a dedicated repository where you can work on Silk. 
 
Now, we need to clone your repository to your computer. You have two options: 

 * [SourceTree](https://www.sourcetreeapp.com/), a GUI application that you can use with Mercurial or Git repositories
 * the Mercurial command line program, `hg.exe`, part of [TortoiseHg](http://tortoisehg.bitbucket.org).
 
## Using SourceTree

 * [Download and install SourceTree](https://www.sourcetreeapp.com/), if you haven't already.
 * Follow the [Clone a repository](https://confluence.atlassian.com/bitbucket/clone-a-repository-223217891.html) instructions to clone your fork to your computer.
 * You can now make your changes. Use SourceTree's Commit command to commit your changes. It's in the top menu bar.
 * Once you're ready to submit your changes to the Silk project, push your changes to your Bitbucket repository. Use SourceTree's Push command (in the top menu bar).
 * Create a pull request. In SourceTree, choose Repository > Create Pull Request. When the "Create Pull Request" dialog box appears, click the "Create Pull Request On Web". Your browser will open on the Bitbucket website where you'll create your pull request. 
 * Enter a title for your changes in the Title field.
 * Enter a description of your changes in the Description field.
 * Click the "Create pull request" button.
 * You're done!

## Using `hg.exe` from the Command Line

 * [Download and install TortoiseHg](http://tortoisehg.bitbucket.org/), if you haven't already.
 * Open a command prompt. 
 * Sign into Bitbucket. Go to your [Bitbucket dashboard](http://bitbucket.org). Click your forked Silk repository. Click the "Clone" link the left menu. Copy the HTTPS URL that appears.
 * Clone your repository:
        
       > hg clone <fork URL> <path to where you want your working directory>
          
     For example, if your Bitbucket username is `hansolo` and you put all your source control repositories into a `C:\Projects` directory on your computer, you would run:
        
       > hg clone https://bitbucket.org/hansolo/silk C:\Projects\Silk
        
 * You can now make and commit changes to Silk. Use Mercurial's `commit` command:
        
       > hg commit -m "COMMIT MESSAGE" 
        
 * Once you're done making your changes, push them to Bitbucket:
          
       > hg push  
           
 * When you're ready to submit your changes to the main Silk project, create a pull request. Go to your fork of Silk (accessible from your [Bitbucket Dashboard](http://bitbucket.org)) and click "Create Pull Request" in the left menu.
 * Enter a title for your changes in the Title field.
 * Enter a description of your changes in the Description field.
 * Click the "Create pull request" button.
 * You're done!
