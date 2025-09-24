# Mac-iPhone Unified Log Collector (ULC)

This script automates the collection of **full iOS unified logs** from a Mac.
It handles the entire workflow: prompting for case/evidence numbers, waiting for device connection and trust, running `log collect`, packaging the results, saving a copy of itself, and generating MD5 hashes for integrity.

---

## Why This Matters

Unified logs provide a richer picture than sysdiagnose bundles.

Apple doesn’t allow unified log export from Windows; you need macOS. This script simplifies the process so you don’t have to re-type long commands in the field.

---

## Requirements

* macOS (tested on Monterey)
* Xcode command line tools installed
* [Homebrew](https://brew.sh/)
* [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) and usbmuxd

Install prerequisites:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install libimobiledevice usbmuxd
```

---

## Usage

1. Download or clone this repo.

2. Make the script executable:

   ```bash
   chmod +x Mac-iphone-ULC.sh
   ```

3. Run it with sudo:

   ```bash
   sudo ./Mac-iphone-ULC.sh
   ```

4. Follow the prompts:

   * Enter Case # and Evidence #
   * Connect and unlock the iPhone
   * Approve the “Trust This Computer” prompt (Stolen Device Protection must be disabled)

---

## What It Does

* Waits for the device to connect and be trusted
* Runs `log collect` and saves the `.logarchive`
* Packages logs into a tarball (`.tar`)
* Saves a session transcript of all terminal activity
* Saves a copy of the script itself for reproducibility
* Generates MD5 hashes for each artifact (tarball, session log, script copy)
* Builds a summary file containing all MD5s together

---

## Outputs

Each run creates a case/evidence folder on your Desktop:

```
~/Desktop/Case-[Case#]/Evidence-[Evidence#]/
```

Inside, you’ll find:

* `[Case]-[Evidence]-UnifiedLogsCollection-[date].txt` (session log)
* `iPhone-[UDID]-[date].tar` (archived unified logs)
* `[Case]-[Evidence]-Mac-iphone-ULC-[date].sh` (script copy)

Hashes:

* `[Case]-[Evidence]-SessionLog-[date]-MD5.txt`
* `[Case]-[Evidence]-Tarball-[date]-MD5.txt`
* `[Case]-[Evidence]-Script-[date]-MD5.txt`
* `[Case]-[Evidence]-AllArtifacts-[date]-MD5.txt` (summary file with all MD5s)

---

## Example Workflow

```
[*] Waiting for iPhone connection...
[+] Device detected with UDID: 00008101-0012345678901A
[*] Checking trust status...
[+] Device is trusted and ready.
[*] Collecting unified logs to .../iPhone-00008101-0012345678901A-2025-09-24.logarchive
[*] Creating tarball...
[*] Saving a copy of the script...
[*] Generating MD5 hashes...
[*] Creating summary MD5 file...
[+] Unified log collection complete.
```

---

## Notes

* Always run as **sudo** or the log collection will fail.
* If Stolen Device Protection (SDP) is enabled, you cannot establish trust.
* MD5 hashes are used for compatibility; if you need SHA-256, adapt the hash commands.
* The script creates a transcript (`script` command) that logs all steps for documentation.

---

## License

MIT License — see [LICENSE](https://opensource.org/licenses/MIT).
Use responsibly and in accordance with applicable law and policy.
