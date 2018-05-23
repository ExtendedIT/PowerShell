#Blocked User Script
#Connect to MSOLOnline
$cred = Get-Credential
Write-Host "Connecting to Office 365"
Connect-MsolService -Credential $cred

$AuditMode = Read-Host -Prompt 'Do you want to run this script in audit mode (audit mode lists but doesnt remove any licenses)? (Y/N)'
$CSVPath = Read-Host -Prompt 'Please provide a full path where we can export a CSV File, leave blank for no CSV file'

$users = Get-MsolUser | Where {$_.IsLicensed -eq "True" -and $_.BlockCredential -eq "True"} | Select UserPrincipalName, Licenses


if (($users.count > 0) -or $users.UserPrincipalName -ne $null){
    Write-Host "The following users exist who are blocked and licensed"
    

    $users

    
    #Remove The Licenses
    If ($AuditMode -eq "N"){
     
        foreach ($user in $users){
            
            $upn = $user.UserPrincipalName
            
            (get-MsolUser -UserPrincipalName $upn).licenses.AccountSkuId |
                foreach{
                    Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $_
                    }
            Get-MsolUSer -UserPrincipalName $upn | Select UserPrincipalName, Licenses
            
            }
        
    }

    #Export the Licenses
    If ($CSVPath -ne $null){

        foreach ($user in $users){
        $MSOLLicenses = ""
        foreach($MSOLLic in $user.Licenses){
            $MSOLLicenses = $MSOLLicenses + $MSOLLic.AccountSkuId
        }
        $upn = $user.UserPrincipalName

        $table="$UPN, $MSOLLicenses"
        $table
        $table | Out-File $CSVPath -Encoding Ascii -Append 

        }

    }
   

} else {

   Write-Host "There are no Licensed users who are blocked, exiting script..."
}

Get-PSSession | Remove-PSSession