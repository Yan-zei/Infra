$WshShell = New-Object -ComObject WScript.Shell

$Shortcut1 = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Confluence.url")

$Shortcut2 = $WshShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Jira.url")

$Shortcut1.TargetPath = "https://tinyurl.com/yn5y84ht/"

$Shortcut2.TargetPath = "https://lovisa.atlassian.net/jira/"

$Shortcut1.Save()

$Shortcut2.Save()