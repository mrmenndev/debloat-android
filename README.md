# debloat-android

An interactive `powershell` script to uninstall bloatware via `adb`.

---

It's has been tested on following devices:

### samsung
device | version
----------|----------
S10      | 10, 11
S10 Plus | 10, 11
Note 9   | 10
Note 20  | 11
S6       | 7

### sony
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
C:\Users[User]\Documents\platform-tools\
```
apk folder
```
C:\Users[User]\Downloads\
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

Path of the current `bloat-file`
```
$bloat_file
```