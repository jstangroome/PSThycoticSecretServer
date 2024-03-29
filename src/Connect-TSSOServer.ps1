function Connect-TSSOServer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Organization,
        
        [string]
        $UserName,

        [string]
        $Password,
        
        [string]
        $Domain,
        
        [string]
        $Uri = 'https://secretserveronline.com/webservices/sswebservice.asmx',
        
        [switch]
        $PassThru
    )

    if (-not $UserName -or -not $Password) {
        $TSSOCredential = $Host.UI.PromptForCredential('Thycotic Secret Server Online', 'Provide your credentials to access Secret Server Online:', $UserName, 'secretserveronline.com')
        if (-not $TSSOCredential) {
            throw "$($MyInvocation.MyCommand): Secret Server Online credentials not supplied by user"
        }
        $NetworkCred = $TSSOCredential.GetNetworkCredential()
        $UserName = $NetworkCred.UserName 
        $Password = $NetworkCred.Password
    }

    Write-Verbose "$($MyInvocation.MyCommand): Connecting to Secret Server web service"
    $Proxy = New-NamedWebServiceProxy -Uri $Uri -Namespace Thycotic -Class SSWebService

    Write-Verbose "$($MyInvocation.MyCommand): Checking web service version"
    $Result = $Proxy.VersionGet()
    if ($Result.Errors) {
        throw "$($MyInvocation.MyCommand): VersionGet failed. $($Result.Errors)"
    }
    if ($Result.Version -notlike '7.8.*') {
        Write-Warning ("$($MyInvocation.MyCommand): Support for web service version '{0}' has not been verified." -f $Result.Version)
    }

    Write-Verbose "$($MyInvocation.MyCommand): Authenticating"
    $Result = $Proxy.Authenticate($UserName, $Password, $Organization, $Domain)
    if ($Result.Errors) {
        throw "$($MyInvocation.MyCommand): Authenticate failed. $($Result.Errors)"
    }
    

    $Connection = New-Object -TypeName PSObject -Property @{
        Token = $Result.Token
        Proxy = $Proxy
        Templates = @()
        Folders = @{'' = -1 <# root folder #>}
    }

    $script:TSSOServerConnection = $Connection

    if ($PassThru) {
        Write-Output $Connection
    }

}
