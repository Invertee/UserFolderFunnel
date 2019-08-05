
<#PSScriptInfo

.VERSION 0.1

.GUID e22e92d8-2cbd-4db1-9c18-ccbe1a220acd

.AUTHOR Sam Petch

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI https://github.com/Invertee/UserFolderFunnel

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>


Param(
    [parameter(Mandatory=$true)] $Folder,
    [parameter()] $DestinationName = "Documents",
    [parameter()] [switch] $DeleteEmptyFolders = $false
)

$key = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name 'LongPathsEnabled' -ErrorAction SilentlyContinue
if (!($key) -or ($key.LongPathsEnabled -eq 0) ) {
    Write-Warning "Support for long file paths is disabled. Consider turning this on:
    https://www.intel.com/content/www/us/en/programmable/support/support-resources/knowledge-base/ip/2018/how-do-i-extend-windows-server-2016-file-path-support-from-260-t.html`n`n"
}

$Folders = Get-Childitem $Folder -Directory

Write-Warning "You are about to move the contents of $($folders.Count) folders, continue?" -WarningAction Inquire

Foreach ($Folder in $Folders) {
    $FolderChildItems = Get-ChildItem -Path $Folder.FullName -Force

    if ($FolderChildItems.Length -eq 0 -and $DeleteEmptyFolders) {
        Remove-Item $Folder.FullName -Force
        Write-host "Deleting empty folder $Folder" -ForegroundColor Red
    } else {
        $Destination = New-Item -Path $Folder.FullName -Name $DestinationName -ItemType Directory -Force

        $FolderChildItems.ForEach({
            Move-Item -LiteralPath $_.Fullname -Destination $Destination -Force
        })
        Write-host "Moved the contents of $Folder to $Folder/$DestinationName" -ForegroundColor Green
    }
}