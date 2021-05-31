$source = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"

$path = Get-Location
$adb_path = Join-Path $path "\adb"

$zip_file = Join-Path $adb_path "platform-tools.zip"
$extracted_path = Join-Path $adb_path "\platform-tools"

$adb = Join-Path $adb_path adb.exe

#==========functions==========

function writeBorder {
    Write-Host "========================================" -f blue
}

# download ADB
function download {
    # check if file is already downloaded
    if ($zip_file | Test-Path){
        Write-Host "Skip download"
        return
    }
    # download file
    try{
        Write-Host "Download ADB"
        Start-BitsTransfer -Source $source -Destination $zip_file 
    }catch{
        Write-Host "Failed to download" -f red
        Write-Host $source -f red 
        Write-Warning $Error[0]
        Exit
    }
}

function extract {
    Write-Host "Extract zip"
    writeBorder
    try{
        # 7z method
        (& 7z e $zip_file "-o$adb_path" "platform-tools\*adb*")
        writeBorder
    }catch{
        # powershell method
        extractSlow
    }
}

# extract zip and cleanup
function extractSlow {
    Write-Warning "7z is not installed"
    Write-Warning "Fallback to powershell method"
    try{
        Expand-Archive -LiteralPath $zip_file -DestinationPath $adb_path
    }catch{
        Write-Host "Failed to extract" -f red
        Write-Host $zip_file -f red
        Write-Warning $Error[0]
        Exit
    }
}

function cleanup {
    Write-Host "Cleanup"

    # search for adb files
    if ($extracted_path|Test-Path){
        $adb_files = Get-ChildItem -Path $extracted_path | Where{$_.Name -Match "adb"}
        # move them
        $adb_files.Foreach{
            Move-Item -Path $_.FullName -Destination $adb_path
        }
        # delete folder
        Remove-Item $extracted_path -Recurse
    }
    
    # delete zip
    Remove-Item $zip_file
}

#==========init==========

# check if adb is there
if ($adb | Test-Path){
    Write-Host "ADB is already there"
    Write-Host "No need to download"
    Exit
}

# create ADB folder (if not available)
if (-not($adb_path | Test-Path)){
    New-Item -Path $adb_path -Type Directory
}

download
extract
cleanup

Write-Host "ADB sucessfully downloaded"
Write-Host "Exit" -f blue