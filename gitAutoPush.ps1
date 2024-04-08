# Define the path to the directory you want to monitor
$folder = 'C:\path\to\your\directory' # Update this path to your directory
$filter = '*.*' # File types to monitor

# Git commands
$gitAdd = 'git add .'
$gitCommit = 'git commit -m "Automatic commit of changes"'
$gitPush = 'git push'

# Setup FileSystemWatcher
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{
    IncludeSubdirectories = $true
    NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
}

# Define actions on detected changes
$action = {
    & git -C $folder add .
    & git -C $folder commit -m "Automatic commit of changes"
    & git -C $folder push
    Write-Host "Changes pushed to Git at $(Get-Date)" -ForegroundColor Green
}

# Register events
Register-ObjectEvent $fsw Created -Action $action
Register-ObjectEvent $fsw Changed -Action $action
Register-ObjectEvent $fsw Deleted -Action $action
Register-ObjectEvent $fsw Renamed -Action $action

# Write a message indicating the script is monitoring the directory
Write-Host "Monitoring $folder for changes. Press any key to exit." -ForegroundColor Cyan

try {
    # Wait for the user to end the monitoring
    $null = $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
finally {
    # Unregister the events and dispose the FileSystemWatcher
    Unregister-Event -SourceIdentifier Created
    Unregister-Event -SourceIdentifier Changed
    Unregister-Event -SourceIdentifier Deleted
    Unregister-Event -SourceIdentifier Renamed
    $fsw.Dispose()
}
