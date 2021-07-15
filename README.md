# debloat-android

An interactive `powershell` script to uninstall bloatware via `adb`.

For Mac and Linux users use [Universal Android Debloater](https://gitlab.com/W1nst0n/universal-android-debloater)

---

It can debloat following devices:

Samsung:

-   Android 10
-   Android 11

Sony TV

-   Android 09

If your device is not listed:

-   create a new debloat file at `.\config`
-   list all packages you want to be removed
-   modify the `bloat_name` value inside `\config\config.json` to the name of your file

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
{
    "remote_ip": "",
    "bloat_name": "samsung.txt",
    "installed_list_file": "$path\\installed.txt",
    "apk_path": "$user_path\\Downloads\\",
    "adb_path": "$path\\adb\\"
}
```

## Keys

If not empty adb tries to connect to the defined ip, otherwise it uses USB connection

```
remote_ip
```

Name of the bloat file (with extension)

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

Local path of the script

```powershell
$path
```

User path

```powershell
$user_path
```
