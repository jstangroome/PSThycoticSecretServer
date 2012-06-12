function Augment-Secret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $Secret,

        $Connection = $script:TSSOServerConnection
    )
    
    process {
        $Template = Get-TSSOTemplate -Id $_.SecretTypeId -Connection $Connection

        $Secret.Items | 
            ForEach-Object {
                $FieldId = $_.FieldId
                $TemplateField = $Template.Fields |
                    Where-Object { $_.Id -eq $FieldId } |
                    Select-Object -First 1
                $Value = $_.Value
                if ($TemplateField.IsPassword) {
                    $Value = ConvertTo-SecureString -String $_.Value -AsPlainText -Force
                    $_.Value = $null
                }
                #TODO $_.IsFile, DownloadFileAttachmentByItemId
                $Secret = $Secret | Add-Member -MemberType NoteProperty -Name $TemplateField.DisplayName -Value $Value -PassThru
            }

        return $Secret
    }
    
}
