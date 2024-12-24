<# converts AWS instances json file into Excel  
The json file is created using the following aws cli command:
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,InstanceType,ImageId,State.Name,Placement.HostId,PrivateIpAddress,PublicIpAddress,VpcId,SubnetId,SecurityGroups[*].[GroupName,GroupId],KeyName,Tags[?Key=='Name'].Value | [0]]" --output json > instances.json

#>

# Define paths
$jsonFilePath = "C:\Users\hayyanz\instances.json"
$excelFilePath = "C:\Users\hayyanz\instances.xlsx"

# Read JSON file
$jsonData = Get-Content -Path $jsonFilePath | ConvertFrom-Json

# Create Excel COM Object
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$workbook = $excel.Workbooks.Add()
$worksheet = $workbook.Worksheets.Item(1)

# Define headers
$headers = @('InstanceId', 'InstanceType', 'ImageId', 'State', 'HostId', 'PrivateIpAddress', 'PublicIpAddress', 'VpcId', 'SubnetId', 'SecurityGroups', 'KeyName', 'Name')
$worksheet.Cells.Item(1,1).Resize(1, $headers.Length).Value = $headers

# Fill data
$row = 2
foreach ($reservation in $jsonData) {
    foreach ($instanceData in $reservation) {
        $worksheet.Cells.Item($row,1).Value = $instanceData[0]
        $worksheet.Cells.Item($row,2).Value = $instanceData[1]
        $worksheet.Cells.Item($row,3).Value = $instanceData[2]
        $worksheet.Cells.Item($row,4).Value = $instanceData[3]
        $worksheet.Cells.Item($row,5).Value = $instanceData[4] -or 'None'
        $worksheet.Cells.Item($row,6).Value = $instanceData[5]
        $worksheet.Cells.Item($row,7).Value = $instanceData[6] -or 'None'
        $worksheet.Cells.Item($row,8).Value = $instanceData[7]
        $worksheet.Cells.Item($row,9).Value = $instanceData[8]
        $worksheet.Cells.Item($row,10).Value = ($instanceData[9] | ForEach-Object { "$($_[0]) ($($_[1]))" }) -join ', '
        $worksheet.Cells.Item($row,11).Value = $instanceData[10]
        $worksheet.Cells.Item($row,12).Value = $instanceData[11]
        $row++
    }
}

# Save and close
$workbook.SaveAs($excelFilePath)
$workbook.Close()
$excel.Quit()

# Release COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

Write-Output "Conversion completed successfully! Excel file created at: $excelFilePath"