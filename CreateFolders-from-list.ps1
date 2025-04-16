#Create Folders from a list

# Path to the text file with country names
$filePath = "C:\Temp\countries.txt"

# Path where you want to create the folders (e.g., C:\Countries)
$folderPath = "C:\Temp\Countries-Folders"

# Create the main folder if it doesn't exist
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
}

# Read the country names from the file and create folders
Get-Content -Path $filePath | ForEach-Object {
    $countryName = $_.Trim()  # Trim any extra spaces or newlines
    $newFolder = Join-Path -Path $folderPath -ChildPath $countryName
    if (-not (Test-Path -Path $newFolder)) {
        New-Item -Path $newFolder -ItemType Directory
        Write-Host "Created folder: $newFolder"
    } else {
        Write-Host "Folder already exists: $newFolder"
    }
}
