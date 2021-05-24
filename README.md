# debloat

A interactive script to uninstall bloatware via `adb`.

It's has been tested for `samsung` devices but with little modifications it should work for other Android devices too.

---

## Usage
start script
```
.\debloat.ps1
```
make sure `adb` is in 

```
C:\Users\[User]\Documents\platform-tools\
```
otherwise just change `$adb_path`.

If you want to use a different bloat file just change `$bloat_file`.