function Test-TSSOConnection {
    [CmdletBinding()]
    param (
        $Connection = $script:TSSOServerConnection
    )

    if (-not $Connection -or -not $Connection.Token) { 
        return $false 
    }

    $Result = $Connection.Proxy.GetTokenIsValid($Connection.Token)
    if ($Result.Errors) { 
        return $false 
    }
    
    return $true
}
