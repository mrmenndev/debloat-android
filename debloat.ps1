# config

$bloat_name = "samsung.txt"
#$bloat_name = "sony_tv.txt"
#$remote_ip = "192.168.1.40"

$path = Get-Location
$user_path = $env:USERPROFILE 

$installed_file = Join-Path $path "installed.txt"
$bloat_file = Join-Path $path "\config\$bloat_name"
$adb_path = Join-Path $path "\adb"
$apk_path = Join-Path $user_path "Downloads\*.apk"

$adb = Join-Path $adb_path adb.exe
$name = $MyInvocation.MyCommand.Name
$version = "1.6.0"

#==========functions==========

function parseFile {
    $bloat_list = @()
    $raw = Get-Content $bloat_file

    $raw.ForEach({
        if ($_.startswith("#")){
        }
        elseif ($_.Length -lt 3){
        }
        else{
            $bloat_list += $_
        }
    })

    return $bloat_list
}

function listPackages {
    Write-Host "Read ADB packages"

    $packages = @()
    $packages_raw = (& $adb shell "pm list packages")

    if ($packages_raw -eq $null){
        Write-Host $packages_raw
        killADB
    }

    # cleanup package result
    $packages_raw.ForEach({
        $packages += $_.Replace("package:","")
    })

    return $packages
}

function connectRemote {
    Write-Host "Connect to $remote_ip"

    $adb_message = [string] (& $adb connect $remote_ip ) 2>$null

    if($adb_message.startswith("connected to")){
        Write-Host "Connected to $remote_ip"
    }
    else{
        Write-Host $adb_message
        killADB
    }
}

function killADB {
    Write-Host "Kill Adb-Server" -f blue

    & $adb kill-server
    Exit
}

function promtBack {
    $promt = Read-Host 'Press enter to go back or press 0 to exit'

    if ($promt -eq 0) {
        killADB
    }
    else {
        Clear-Host
    }
}

#==========init==========

Write-Host "read $bloat_name"

# check if bloat-file is there
if (-not ($bloat_file | Test-Path)){
    Write-Host "$bloat_file can't be found"
    Exit
}

# read bloat-file
$bloat_list = parseFile

#----------
# check if ADB path is correct
Write-Host "Check if ADB path is correct"

if (-not ($adb | Test-Path)){
    Write-Host "ADB can't be found"
    Write-Host "Use '.\download_adb.ps1' to download ADB"
    Exit
}

$adb_info = (& $adb version)

# connect to remote if remote_ip is available
if (-not ($remote_ip -eq $Null)){
    connectRemote
}

#----------
# check if ADB can list packages
$test_packages = listPackages

Write-Host "Initial setup complete"

#==========menu==========

function showInfo {
    Write-Host $name
    Write-Host "version: $version"
    Write-Host "path: $path"
    Write-Host "bloat-file: $bloat_name"
    Write-Host "--------------------------"
    Write-Host "ADB:"
    $adb_info.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
}

function installAPKs {
    # list apks
    $apk_files = Get-ChildItem -Path $apk_path
    $apk_path_raw = Split-Path -Path $apk_path

    Write-Host "Following apks has been found in:"
    Write-Host $apk_path_raw
    Write-Host "========================================"
    $apk_files.ForEach({
        Write-Host $_.Basename
    })
    Write-Host "========================================"
    $promt = Read-Host 'Press 1 to install or press enter to go back'
    
    # install apks
    if (($promt -eq 1) -and ($apk_files.Count -gt 0)) {
        $apk_files.Foreach({
            Write-Host "Install $($_.Basename)"
            & $adb install $_
        })
        promtBack
    }
    else{
        Clear-Host
    }
}

function showBloatInstalled {
    $packages = listPackages
    $bloat_installed = $bloat_list | Where {$packages -Contains $_}

    Write-Host "========================================"
    Write-Host "Following bloatware are installed:"
    Write-Host "========================================"
    $bloat_installed.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
    Write-Host "Count: $($bloat_installed.Count)"
    Write-Host "========================================"
}

function showBloatNotInstalled {
    $packages = listPackages
    $bloat_not_installed = $bloat_list | Where {$packages -NotContains $_}

    Write-Host "========================================"
    Write-Host "Following bloatware found in $bloat_file" 
    Write-Host "but are not installed:"
    Write-Host "========================================"
    $bloat_not_installed.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
    Write-Host "Count: $($bloat_not_installed.Count)"
    Write-Host "========================================"
}

function showInstalledPackages {
    $packages = listPackages

    Write-Host "========================================"
    Write-Host "Installed packages can be found in"
    Write-Host $installed_file -f yellow
    $packages | Out-File -FilePath $installed_file
    Write-Host "========================================"
    Write-Host "Count: $($packages.Count)"
    Write-Host "========================================"
}

function uninstallBloat {
    $packages = listPackages
    $bloat_installed = $bloat_list | Where {$packages -Contains $_}
    
    Write-Host "========================================"
    Write-Host "Uninstall bloatware..."
    Write-Host "========================================"
    $success = 0
    $count = $bloat_installed.Count
    $bloat_installed.Foreach({
        $adb_message = [string] (& $adb shell "pm uninstall --user 0" $_ ) 2>$null
        if ($adb_message -eq "Success"){
            $success += 1
            Write-Host "($success/$count) Uninstalled: $_ "
        }
        else{
            Write-Host "Failed to uninstall: $_"
        }
    })
    Write-Host "========================================"
    Write-Host "Bloatware uninstalled: $success"
    Write-Host "========================================"
}

while ($true){
    Write-Host "========================================"
    Write-Host "Menu:"
    Write-Host "1.) bloatware - installed"
    Write-Host "2.) bloatware - not installed"
    Write-Host "3.) bloatware - uninstall all"
    Write-Host "4.) list installed packages"
    Write-Host "5.) install apks"
    Write-Host "6.) info"
    Write-Host "0.) exit"
    Write-Host "========================================"

    $promt = Read-Host 'Go to'
    Clear-Host

    switch ($promt){
        1{
            showBloatInstalled
            promtBack
        }
        2{
            showBloatNotInstalled
            promtBack
        }
        3{
            uninstallBloat
            promtBack
        }
        4{
            showInstalledPackages
            promtBack
        }
        5{
            installAPKs
        }
        6{
            showInfo
            promtBack
        }
        0{
            killADB
        }
    }
}