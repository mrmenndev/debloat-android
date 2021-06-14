# debloat-android

An interactive `powershell` script to uninstall bloatware via `adb`.

For Mac and Linux user I recommend using [Universal Android Debloater](https://gitlab.com/W1nst0n/universal-android-debloater)

---

It can debloat following devices:

Samsung:

-   Android 10
-   Android 11

Sony TV

-   Android 09

If your device is not in the list

-   create a new debloat file at `.\config`
-   list all packages you want to be removed
-   modify the `$bloat_name` value inside `.\debloat.ps1` to the name of your file

---

## Usage

Start script

```
.\debloat.ps1
```

Download `adb`

```
.\download_adb.ps1
```

Config file

```
.\config\config.json
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

# Config file

Default

```json
  "remote_ip": "",
  "bloat_name": "samsung.txt",
  "installed_list_file": "$path\\installed.txt",
  "apk_path": "$user_path\\Downloads\\",
  "adb_path": "$path\\adb\\"
}

```

## Keys

If not empty adb tries to connect to this ip, otherwise it uses USB

```
remote_ip
```

Name of the bloat file (always with extension)

```
bloat_name
```

Where the installed application list will be created

```
installed_list_file
```

Path of all apks

```
apk_path
```

Path of `adb`

```
adb_path
```

---

## Dynamic values

local path of the script

```powershell
$path
```

User path

```powershell
$user_path
```
