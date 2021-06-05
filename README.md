# debloat-android

An interactive `powershell` script to uninstall bloatware via `adb`.

It can debloat following devices:

Samsung:
- Android 10
- Android 11

Sony TV
- Android 09

If your device is not in the list
- create a new debloat file at `.\config`
- list all packages you want to be removed
- modify the `$bloat_name` value inside `.\debloat.ps1` to the name of your file

---

## Usage

Start script
```
.\debloat.ps1
```

Connect to a remote device
- Uncomment `$remote_ip` inside `.\debloat.ps1`
- Edit the value to your device ip


Download `adb`
```
.\download_adb.ps1
```

---

## Default location

ADB
```
.\adb\
```

Bloat-Files
```
.\config\
```

APK folder
```
C:\Users\[User]\Downloads\
```

## Variables inside `.\debloat.ps1`

Remote device ip
```
# If commented out it use local USB device
$remote_ip
```

Name of the current `bloat-file`
```
$bloat_name
```

Path of `adb`
```
$adb_path
```

Path of `apk` folder
```
$apk_path
```

Path of the `installed` application list
```
$installed_file
```