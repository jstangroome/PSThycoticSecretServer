function Set-TSSOSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Secret,

        $Connection = $script:TSSOServerConnection
    )

<#
    if ($Secret -is [int]) {
        $Secret = Get-TSSOSecret -Id $Secret -Connection $Connection
    } elseif ($Secret -is [string]) {
        $Secret = Get-TSSOSecret -Name $Secret -Connection $Connection
    }
#>

    if (-not $Secret -or $Secret -isnot [Thycotic.Secret]) {
        throw "$($MyInvocation.MyCommand): Invalid secret."
    }

    Write-Verbose "$($MyInvocation.MyCommand): Updating secret '$Name'"
    $Result = $Connection.Proxy.UpdateSecret($Connection.Token, $Secret)
    if ($Result.Errors) {
        throw "$($MyInvocation.MyCommand): UpdateSecret failed. $($Result.Errors)"
    }

    return (Get-TSSOSecret -Id $Secret.Id -Connection $Connection)
}
