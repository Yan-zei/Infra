# Search through registry.. two methods one can export to csv

<#

$results = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension" -Recurse |
    Where-Object { $_.Name -like "*8b0f187c-8b19-4d4a-8e46-ffffdf4b819b*" }
       
        $results | Format-List *

    $results | Export-Csv -Path "C:\temp\regisOutput.csv" -NoTypeInformation

#>
   # -------- another way ------#

   $searchTerm = "fdd722ed-ccef-4b08-9622-e5e723c50da5"
Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\" -Recurse | 
    Where-Object { $_.Name -like "*$searchTerm*" }