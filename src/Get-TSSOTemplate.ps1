function Get-TSSOTemplate {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(ParameterSetName='Name', Position=0)]
        [string]
        $Name = '*',

        [Parameter(Mandatory=$true, ParameterSetName='Id')]
        [int]
        $Id,

        [switch]
        $Force,
        
        $Connection = $script:TSSOServerConnection
    ) 

    if ($Force -or -not $Connection.Templates) {
        Write-Verbose "$($MyInvocation.MyCommand): Retrieving templates"
        $Result = $Connection.Proxy.GetSecretTemplates($Connection.Token)
        if ($Result.Errors) {
            throw "$($MyInvocation.MyCommand): GetSecretTemplates failed. $($Result.Errors)"
        }
        $Connection.Templates = $Result.SecretTemplates
    }
    
    if ($PSCmdlet.ParameterSetName -eq 'Id') {
        $Connection.Templates | 
            Where-Object { $_.Id -eq $Id }
    } else {
        $Connection.Templates | 
            Where-Object { $_.Name -like $Name }
    }

}
