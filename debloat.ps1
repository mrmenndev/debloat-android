# config

$bloat_file = "samsung.txt"
#$bloat_file = "tv_sony.txt"
#$remote_ip = "192.168.1.42"

$user_path = $env:USERPROFILE 
$apk_path = Join-Path $user_path "Downloads\*.apk"
$adb_path = Join-Path $user_path "Documents\platform-tools"

#==========functions==========
$version = "1.2.0"
$name = $MyInvocation.MyCommand.Name
$running = $true
$packages = @()
$bloat_list = @()

Function Read_Packages {
    $packages = @()
    
    Write-Host "read adb packages"
    $adb_out_packages = & $adb shell "pm list packages"

    if ($adb_out_packages -eq $null){
        Write-Host $adb_out_packages
        Kill_ADB
    }

    # cleanup package result
    $adb_out_packages.ForEach({
        $packages += $_.Replace("package:","")
    })

    # check installed bloatware
    $bloat_installed = $bloat_list | Where {$packages -Contains $_}
}

Function Kill_ADB {
    Write-Host "Kill Adb-Server"
    & $adb kill-server
    Exit
}

Function Promt_Back {
    Write-Host "========================================"
    $promt_inner = Read-Host 'Press enter to go back or press 0 to exit'
    if ($promt_inner -eq 0) {
        Kill_ADB
    }
    else {
        Clear-Host
    }
}

Function Bloat_Installed {
    Read_Packages
    Write-Host "========================================"
    Write-Host "Following bloatware are installed: "
    Write-Host "========================================"
    $bloat_installed.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
    Write-Host "Count: $($bloat_installed.Count)"
    
}

Function Bloat_Not_Installed {
    Read_Packages
    Write-Host "========================================"
    Write-Host "Following bloatware found in '$bloat_file'" 
    Write-Host "but are not installed: "
    Write-Host "========================================"
    $bloat_not_installed = $bloat_list | Where {$packages -NotContains $_}
    $bloat_not_installed.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
    Write-Host "Count: $($bloat_not_installed.Count)"
}

Function List_Installed_Packages {
    Read_Packages
    Write-Host "========================================"
    Write-Host "Following packages are installed: "
    Write-Host "========================================"
    $packages.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
    Write-Host "Count: $($packages.Count)"
}

Function Uninstall_Bloat {
    Read_Packages
    Write-Host "========================================"
    Write-Host "Uninstall bloatware"
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
}

Function Clear_Bloat_Data{
    Read_Packages
    Write-Host "========================================"
    Write-Host "Clear data from bloatware"
    Write-Host "========================================"
    $success = 0
    $count = $bloat_list.Count
    $bloat_list.Foreach({
        $adb_message = [string] (& $adb shell "pm clear" $_ ) 2>$null
        if ($adb_message -eq "Success"){
            $success += 1
            Write-Host "($success/$count) Cleared: $_ "
        }
        else {
            Write-Host "Failed to clear: $_"
        }
    })
    Write-Host "========================================"
    Write-Host "Bloatware cleared: $success"
}

Function Install_APKS(){
    # List apks

    $apk_list = Get-ChildItem -Path $apk_path
    $apk_path_raw = Split-Path -Path $apk_path
    
    Write-Host "Following apks are found in"
    Write-Host $apk_path_raw
    Write-Host "========================================"
    $apk_list.ForEach({
        Write-Host $_.Basename
    })
    # Propt to install apk
    Write-Host "========================================"
    $promt_inner = Read-Host 'Press 1 to install or press enter to go back'
    if ($promt_inner -eq 1) {
        $apk_list.Foreach({
            # install apks
            Write-Host "Install ${$_.Basename}"
            & $adb install $_
        })
    }
    else{
        Clear-Host
    }
}

Function Show_Info {
    Write-Host "========================================"
    Write-Host $name
    Write-Host "version: $version"
    Write-Host "bloat-file: $bloat_file"
    Write-Host "--------------------------"
    Write-Host "adb:"
    $adb_info.Foreach({
        Write-Host $_
    }) 
}


#==========initial setup==========

#----------
# check if adb path is correct
Write-Host "check if adb path is correct"

$adb = Join-Path $adb_path adb.exe
if (-not ($adb | Test-Path)){
    Write-Host "adb can't be found"
    Exit
}
$adb_info =  & $adb version

# connect to remote ip if available
if (-not ($remote_ip -eq $Null)){
    Write-Host "connect to $remote_ip"
    $adb_message = [string] (& $adb connect $remote_ip ) 2>$null
    if($adb_message.startswith("connected to")){
        Write-Host "connected to $remote_ip"
    }
    else{
        Write-Host $adb_message
        Kill_ADB
    }
}

#----------
# check if debloat_list.txt is there
Write-Host "check if the bloat list called $bloat_file is there"

if (-not ($bloat_file | Test-Path)){
    Write-Host "$bloat_file can't be found"
    Exit
}

#----------
# read bloat file
Write-Host "read $bloat_file"

$bloat_list_raw = Get-Content $bloat_file

$bloat_list_raw.ForEach({
    if ($_.startswith("#")){
    }
    elseif ($_.Length -lt 3){
    }
    else{
        $bloat_list += $_
    }
})

#----------
# list adb packages
Read_Packages

Write-Host "Initial setup complete"

#==========menu==========

while ($running -eq $true){
    Write-Host "========================================"
    Write-Host "Menu:"
    Write-Host "1.) bloatware - installed"
    Write-Host "2.) bloatware - not installed"
    Write-Host "3.) bloatware - uninstall all"
    Write-Host "4.) bloatware - clear data"
    Write-Host "5.) list installed packages"
    Write-Host "6.) install apks"
    Write-Host "7.) info"
    Write-Host "0.) exit"
    Write-Host "========================================"

    $promt = Read-Host 'Go to'
    Clear-Host

    switch ($promt){
        1{
            Bloat_Installed
            Promt_Back
        }
        2{
            Bloat_Not_Installed
            Promt_Back
        }
        3{
            Uninstall_Bloat
            Promt_Back
        }
        4{
            Clear_Bloat_Data
            Promt_Back
        }
        5{
            List_Installed_Packages
            Promt_Back
        }
        6{
            Install_APKS
        }
        7{
            Show_Info
            Promt_Back
        }
        0{
            Kill_ADB
        }
    }
}