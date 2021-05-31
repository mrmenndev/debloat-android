# debloat-android

An interactive `powershell` script to uninstall bloatware via `adb`.

---

It's has been tested on following devices:

### Samsung

device | version
----------|----------
S10 (Plus)      | 10, 11
Note 9          | 10
Note 20 (Ultra) | 11
S6              | 7

### Sony

device | version
----------|----------
TV      | 9

---


## Usage

start script
```
.\debloat.ps1
```

## Default location

adb
```
.\adb\
```

bloat files
```
.\config\
```

apk folder
```
C:\Users\[User]\Downloads\
```

## Variables

Uncomment if you want to connect to a remote device
```
$remote_ip
```

Path of `adb`
```
$adb_path
```

Path of `apk` folder
```
$apk_path
```

Path of the current `bloat-file`
```
$bloat_file
```