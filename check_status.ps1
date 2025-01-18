# Variables
$ContainerName = "romantic_blackburn" # Replace with your container name
$ExpectedHash = "2546dcffc5ad854d4ddc64fbf056871cd5a00f2471cb7a5bfd4ac23b6e9eedad"
$DownloadPath = "/home/computeruse/Downloads"

# Check if the Docker container is running
Write-Host "Checking Docker container status..."
$ContainerStatus = docker ps --filter "name=$ContainerName" --format "{{.Status}}"

if (-not $ContainerStatus) {
    Write-Error "Error: The container '$ContainerName' is not running."
    exit 1
}

Write-Host "Container '$ContainerName' is running."

# List files in the Downloads directory
Write-Host "Checking for downloaded files in '$DownloadPath'..."
$Files = docker exec $ContainerName ls $DownloadPath

if (-not $Files) {
    Write-Error "No files found in '$DownloadPath'."
    exit 1
}

Write-Host "Found files:"
$Files

# Check each file's hash
foreach ($File in $Files) {
    $FilePath = "$DownloadPath/$File"

    # Get the file's SHA256 hash
    Write-Host "Calculating SHA256 hash for '$FilePath'..."
    $FileHash = docker exec $ContainerName sha256sum $FilePath | awk '{print $1}'

    if ($FileHash -eq $ExpectedHash) {
        Write-Host "Match found! File: '$FilePath' | SHA256: $FileHash"
        exit 0
    } else {
        Write-Host "No match for file '$FilePath'. Calculated SHA256: $FileHash"
    }
}

Write-Error "No files in '$DownloadPath' match the expected SHA256 hash."
exit 1
