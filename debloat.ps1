# config
$version = "1.0.0"
$bloat_file = "samsung.txt"
$user_path = Join-Path $env:USERPROFILE "Documents\platform-tools"
$adb_path = $user_path
#==========initial setup==========
$name = $MyInvocation.MyCommand.Name
$running = $true
$packages = @()
$bloat_list = @()

#----------
# check if adb path is correct
Write-Host "check if adb path is correct"

$adb = Join-Path $adb_path adb.exe
if (-not ($adb | Test-Path)){
    Write-Host "adb can't be found"
    Exit
}

#----------
# check if debloat_list.txt is there
Write-Host "check if the bloat list called '$bloat_file' is there"

if (-not ($bloat_file | Test-Path)){
    Write-Host "'$bloat_file' can't be found"
    Exit
}

#----------
# list adb packages
Write-Host "read adb packages"
$adb_info =  & $adb version
$adb_out_packages = & $adb shell "pm list packages"

if ($adb_out_packages -eq $null){
    Write-Host $adb_out_packages
    Exit
}

# cleanup package result
$adb_out_packages.ForEach({
    $packages += $_.Replace("package:","")
})

#----------
# read bloat file
Write-Host "read bloat list"

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

$bloat_installed = $bloat_list | Where {$packages -Contains $_}

Write-Host "Initial setup complete"

#==========functions==========

Function Bloat_Installed {
    Write-Host "========================================"
    Write-Host "Following bloatware are installed: "
    Write-Host "========================================"
    $bloat_installed.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
    Write-Host "Count: $($bloat_installed.Count)"
    Write-Host "========================================"
    
}

Function Bloat_Not_Installed {
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
    Write-Host "========================================"
}

Function List_Installed_Packages {
    Write-Host "========================================"
    Write-Host "Following packages are installed: "
    Write-Host "========================================"
    $packages.Foreach({
        Write-Host $_
    })
    Write-Host "========================================"
    Write-Host "Count: $($packages.Count)"
    Write-Host "========================================"
}

Function Uninstall_Bloat {
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
    Write-Host "========================================"
}

Function Clear_Bloat_Data{
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
    Write-Host "========================================"
}

Function Show_Info {
    Write-Host "========================================"
    Write-Host $name
    Write-Host "Version: $version"
    Write-Host "--------------------------"
    Write-Host "adb:"
    $adb_info.Foreach({
        Write-Host $_
    }) 
    Write-Host "========================================"
}

Function Promt_Back {
    $promt_inner = Read-Host 'Press any key to go back or press 0 to exit'
    if ($promt_inner -eq 0) {
        Exit
    }
    else {
        Clear-Host
    }
}

#==========menu==========

while ($running -eq $true){
    Write-Host "========================================"
    Write-Host "Menu:"
    Write-Host "1.) bloatware - installed"
    Write-Host "2.) bloatware - not installed"
    Write-Host "3.) bloatware - uninstall all"
    Write-Host "4.) bloatware - clear data"
    Write-Host "5.) list installed packages"
    Write-Host "6.) info"
    Write-Host "0.) exit"

    $promt = Read-Host 'Go to'
    Clear-Host

    switch ($promt){
        1{
            Bloat_Installed
        }
        2{
            Bloat_Not_Installed
        }
        3{
            Uninstall_Bloat
        }
        4{
            Clear_Bloat_Data
        }
        5{
            List_Installed_Packages
        }
        6{
            Show_Info
        }
        0{
            Exit
        }
    }

    Promt_Back
}