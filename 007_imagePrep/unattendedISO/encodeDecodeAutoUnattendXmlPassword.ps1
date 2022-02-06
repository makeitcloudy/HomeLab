#this code has been found on
#Start-Process 'https://social.technet.microsoft.com/Forums/windows/en-US/5e6a97b5-186c-40dd-a165-2cc3e7eb2682/how-to-encrypt-a-password-in-unattendendxml?forum=itprovistadeployment'
#it bring the powershell way to get the base64 strings which can be used to encode the passwords within the autounattend.xml files
#it does not give any sort of improvement in security, it's just for obfuscation purposes ;)

#region Administrator Password
#region Administrator Password - base64 encode
$administratorPassword = 'AdministratorPassword'
$encodedAdministratorPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(('{0}AdministratorPassword' -f $administratorPassword)))
#endregion

#region Administrator Password - based64 decode
$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($encodedAdministratorPassword))
Write-Output "Decoded_Text_is:" $administratorPassword
#endregion
#endregion

#region User Password
#region User Password - base64 encode
$autoLogonPassword = 'labUserPassword'
$encodedAutoLogonPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(('{0}Password' -f $autoLogonPassword)))
#endregion

#region User Password - base64 decode
$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($encodedAdministratorPassword))
Write-Output "Decoded_Text_is:" $administratorPassword
#endregion
#endregion
