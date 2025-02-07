# Count Group Members

# Import the Microsoft Graph module
Import-Module Microsoft.Graph

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All"

# Get the group
$GroupName = "grp-bitlocker-stg2"
$Group = Get-MgGroup -Filter "displayName eq '$GroupName'"

# Get the members
$Members = Get-MgGroupMember -GroupId $Group.Id -All

# Count the members
$MemberCount = $Members.Count

Write-Output "The group '$GroupName' has $MemberCount members."
