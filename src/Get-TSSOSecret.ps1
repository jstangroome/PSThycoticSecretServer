function Get-TSSOSecret {
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    param (
        [Parameter(ParameterSetName='Id', Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('SecretId')]
        [string]
        $Id,

        [Parameter(ParameterSetName='Name', Position=0, Mandatory=$true)]
        [Alias('SecretName')]
        [string]
        $Name,
        
        [Parameter(ParameterSetName='Search', Position=0, Mandatory=$true)]
        [string]
        $SearchTerm,

        [Parameter(ParameterSetName='Search')]
        [switch]
        $IncludeValues,

        $Connection = $script:TSSOServerConnection
    )

    process {

        if ($PSCmdlet.ParameterSetName -eq 'Id') {

            $Result = $Connection.Proxy.GetSecret($Connection.Token, $Id)
            if ($Result.Errors) {
                throw "$($MyInvocation.MyCommand): GetSecret failed. $($Result.Errors)"
            }
    
            return ($Result.Secret | Augment-Secret -Connection $Connection)
        
        } elseif ($PSCmdlet.ParameterSetName -eq 'Name') {

            Get-TSSOSecret -SearchTerm $Name -Connection $Connection |
                Where-Object { $_.SecretName -eq $Name } |
                Get-TSSOSecret -Connection $Connection
            
            return

        } ### else Search

        $Result = $Connection.Proxy.SearchSecrets($Connection.Token, $SearchTerm)
        if ($Result.Errors) {
            throw "$($MyInvocation.MyCommand): SearchSecrets failed. $($Result.Errors)"
        }

        if ($IncludeValues) {
            return ($Result.SecretSummaries | Get-TSSOSecret -Connection $Connection)
        } else {
            return $Result.SecretSummaries
        }

    }
}
