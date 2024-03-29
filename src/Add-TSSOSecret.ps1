function Add-TSSOSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Template,
        
        [Parameter(Mandatory=$true)]
        $Folder,
        
        [Parameter(Mandatory=$true)]
        [string]
        $Name,
        
        [Parameter(Mandatory=$true)]
        [System.Collections.IDictionary]
        $Property,
        
        $Connection = $script:TSSOServerConnection
    )

    if ($Template -is [int]) {
        $Template = Get-TSSOTemplate -ID $Template -Connection $Connection
    } elseif ($Template -is [string]) {
        $Template = Get-TSSOTemplate -Name $Template -Connection $Connection
    }
    
    if (-not $Template -or $Template -isnot [Thycotic.SecretTemplate]) {
        throw "$($MyInvocation.MyCommand): Invalid template."
    }
    
    if ($Folder -is [string]) {
        $Folder = (Get-TSSOFolder -Path $Folder -Connection $Connection).Id
    } elseif ($Folder -is [Thycotic.Folder]) {
        $Folder = $Folder.Id
    }
    
    if (-not $Folder -or $Folder -isnot [int]) {
        throw "$($MyInvocation.MyCommand): Invalid folder."
    }

    $FieldIds = [int[]]@()
    $Values = @()
    foreach ($Field in $Template.Fields) {
        $FieldIds += $Field.Id
        if ($Property.ContainsKey($Field.DisplayName)) {
            $Values += $Property[$Field.DisplayName]
        } else {
            Write-Warning "$($MyInvocation.MyCommand): Missing property '$($Field.DisplayName)'."
            $Values += ''
        }
    }

    Write-Verbose "$($MyInvocation.MyCommand): Adding secret '$Name'"
    $Result = $Connection.Proxy.AddSecret($Connection.Token, $Template.Id, $Name, $FieldIds, $Values, $Folder)
    if ($Result.Errors) {
        throw "$($MyInvocation.MyCommand): AddSecret failed. $($Result.Errors)"
    }

    return ($Result.Secret | Augment-Secret -Connection $Connection)
}
