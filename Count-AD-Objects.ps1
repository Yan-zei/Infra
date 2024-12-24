$ADUser = (Get-AdUser -Filter * | Measure-Object).Count
$ADGroup = (Get-ADGroup -Filter * | Measure-Object).Count
$ADComputer = (Get-ADComputer -Filter * | Measure-Object).Count
$ADObjects = $ADUser + $ADGroup + $ADComputer
$ADObjects