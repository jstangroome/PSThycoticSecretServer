$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. $PSScriptRoot\New-NamedWebServiceProxy.ps1
. $PSScriptRoot\Connect-TSSOServer.ps1
. $PSScriptRoot\Test-TSSOConnection.ps1
. $PSScriptRoot\Get-TSSOTemplate.ps1
. $PSScriptRoot\Get-TSSOFolder.ps1
. $PSScriptRoot\Augment-Secret.ps1
. $PSScriptRoot\Get-TSSOSecret.ps1
. $PSScriptRoot\Add-TSSOFolder.ps1
. $PSScriptRoot\Add-TSSOSecret.ps1
. $PSScriptRoot\Set-TSSOSecret.ps1

$script:TSSOServerConnection = $null

Export-ModuleMember -Function *-TSSO*
