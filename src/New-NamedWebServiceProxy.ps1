function New-NamedWebServiceProxy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Uri,

        [Parameter(Mandatory=$true)]
        [string]
        $Namespace,

        [Parameter(Mandatory=$true)]
        [string]
        $Class
    )

    $TypeName = $Namespace + '.' + $Class

    $Assembly = [AppDomain]::CurrentDomain.GetAssemblies() |
        Where-Object {
            $_.GetType($TypeName)
        }

    if ((Measure-Object -InputObject $Assembly).Count -gt 1) {
        throw "$($MyInvocation.MyCommand): AppDomain contains multiple definitions of the same type. Restart PowerShell host."
    }
    
    if ($Assembly) {
        $Proxy = New-Object -TypeName $TypeName
    } else {
        $Proxy = New-WebServiceProxy -Uri $Uri -Namespace $Namespace 
    }
    $Proxy.Url = $Uri

    return $Proxy
}
