# This shell script does the following
# 1. Finds the N biggest image files in the specified folder and prints them
# 2. Finds images  that are 0 bytes in size, prints the total number and lists the filenames
# 3. optionally replaces the 0 byte files with a file from the specified folder matching the filename

# Set the folder to search
$folder = ".\images\HW"
# Set the folder to search for replacement files
$replacementFolder = ".\images\goodphotos"
# do replacement?
$replace = $true

# Set the number of files to find
$number = 3

# Find the N biggest files in the folder
$biggest = Get-ChildItem $folder -Recurse -File | Sort-Object -Property Length -Descending | Select-Object -First $number

# Print the N biggest files
Write-Host "The $number biggest files in $folder are:"
$biggest | Format-Table -AutoSize

# Find the files that are 0 bytes in size
$zero = Get-ChildItem $folder -Recurse -File | Where-Object {$_.Length -eq 0}

# Print the number of files that are 0 bytes in size
Write-Host "There are $($zero.Count) files that are 0 bytes in size in $folder"

# Print the filenames of the files that are 0 bytes in size
Write-Host "The files that are 0 bytes in size are:"
$zero | Format-Table -AutoSize

# Replace the 0 byte files with a file from the specified folder matching the filename
if ($replace) {
    foreach ($file in $zero) {
        $replacementFile = Get-ChildItem $replacementFolder -Recurse -File | Where-Object {$_.Name -eq $file.Name}
        if ($replacementFile) {
            Write-Host "Replacing $file with $replacementFile"
            Copy-Item $replacementFile.FullName $file.FullName -Force
        }
    }
}