function Add-TSSOFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Mandatory=$true)]
        $ParentFolder,
        
        $Connection = $script:TSSOServerConnection
    )

    if ($ParentFolder -is [string]) {
        $ParentFolder = (Get-TSSOFolder -Path $ParentFolder -Connection $Connection).Id
    } elseif ($ParentFolder -is [Thycotic.Folder]) {
        $ParentFolder = $ParentFolder.Id
    }
    
    if (-not $ParentFolder -or $ParentFolder -isnot [int]) {
        throw "$($MyInvocation.MyCommand): Invalid parent folder."
    }

    $FolderTypeId = 1
    
    Write-Verbose "$($MyInvocation.MyCommand): Adding folder '$Name'"
    $Result = $Connection.Proxy.FolderCreate($Connection.Token, $Name, $ParentFolder, $FolderTypeId)
    if ($Result.Errors) {
        throw "$($MyInvocation.MyCommand): FolderCreate failed. $($Result.Errors)"
    }

    Get-TSSOFolder -Id $Result.FolderId -Connection $Connection
}
