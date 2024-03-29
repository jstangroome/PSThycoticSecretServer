function Get-FolderAllChildren ($Path, $Connection) {
    if (-not $Connection.Folders.ContainsKey($Path)) {
        Get-FolderAllChildren -Path (Split-Path -Path $Path) -Connection $Connection | Out-Null
    }
    if (-not $Connection.Folders.ContainsKey($Path)) {
        return 
    }

    $Id = $Connection.Folders[$Path]

    Write-Verbose "$($MyInvocation.MyCommand): Retrieving children of folder '$Id'"
    $Result = $Connection.Proxy.FolderGetAllChildren($Connection.Token, $Id)

    if (-not $Result.Success) {
        throw "$($MyInvocation.MyCommand): FolderGetAllChildren failed. $($Result.Errors)"
    }

    $Result.Folders |
        ForEach-Object {
            if ($Path) {
                $ChildPath = $Path | Join-Path -ChildPath $_.Name
            } else {
                $ChildPath = $_.Name
            }
            $Connection.Folders[$ChildPath] = $_.Id
        }

}

function Get-TSSOFolder {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Path')]
        [string]
        $Path = '',

        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [int]
        $Id,

        $Connection = $script:TSSOServerConnection
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'Path') {
    
        Write-Debug "$($MyInvocation.MyCommand) -Path $Path"

        if (-not $Connection.Folders.ContainsKey($Path)) {
            Get-FolderAllChildren -Path (Split-Path -Path $Path) -Connection $Connection | Out-Null
        }
        if (-not $Connection.Folders.ContainsKey($Path)) {
            return
        }
        $Id = $Connection.Folders[$Path]
    }
        
    Write-Verbose "$($MyInvocation.MyCommand): Retrieving folder '$Id'"
    return $Connection.Proxy.FolderGet($Connection.Token, $Id).Folder

}

