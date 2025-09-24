#!/bin/bash
# Mac-iphone-ULC: Unified Log Collector for iOS
# License: MIT (see https://opensource.org/licenses/MIT)

echo "========== Mac-iPhone Unified Log Collector =========="
echo "This script will collect full unified logs from a connected iPhone."
echo "------------------------------------------------------"
echo "IMPORTANT:"
echo " - Run this script with sudo (sudo ./Mac-iphone-ULC.sh)."
echo " - Start BEFORE connecting the iPhone."
echo " - iPhone must be unlocked and Trusted to this computer."
echo " - Stolen Device Protection (SDP) must be DISABLED beforehand,"
echo "   otherwise the trust prompt cannot be completed."
echo " - Requires libimobiledevice (brew install libimobiledevice 
usbmuxd)."
echo " - Works on macOS only."
echo "------------------------------------------------------"

# Prompt user for case and evidence numbers
read -p "Enter Case #: " CASE
read -p "Enter Evidence #: " EVIDENCE

# Timestamp
DATE=$(date +%F_%H%M)

# Case-specific output path
OUTDIR_BASE=~/Desktop/Case-${CASE}/Evidence-${EVIDENCE}
mkdir -p "$OUTDIR_BASE"

# Transcript filename
LOGFILE="${CASE}-${EVIDENCE}-UnifiedLogsCollection-${DATE}.txt"

# Start transcript
echo "[*] Starting session log: $LOGFILE"
script -q "$OUTDIR_BASE/$LOGFILE" <<'EOF_SCRIPT'
EOF_SCRIPT

# Re-open log file to continue appending commands
exec > >(tee -a "$OUTDIR_BASE/$LOGFILE") 2>&1

echo "[*] Waiting for iPhone connection..."
UDID=""

# Loop until device detected
while [ -z "$UDID" ]; do
  UDID=$(idevice_id -l | head -n 1)
  if [ -z "$UDID" ]; then
    sleep 3
  fi
done

echo "[+] Device detected with UDID: $UDID"

# Verify trust status
echo "[*] Checking trust status..."
while ! ideviceinfo -u "$UDID" >/dev/null 2>&1; do
  echo "[!] Device is connected but not trusted."
  echo "    -> Unlock iPhone and tap 'Trust This Computer'."
  echo "    -> If trust prompt never appears, check if Stolen Device 
Protection is enabled."
  sleep 5
done

echo "[+] Device is trusted and ready."

# Run log collect
LOGARCHIVE="$OUTDIR_BASE/iPhone-${UDID}-${DATE}.logarchive"
echo "[*] Collecting unified logs to $LOGARCHIVE (this may take several 
minutes)..."
sudo log collect --device-udid "$UDID" --output "$LOGARCHIVE"

if [ ! -d "$LOGARCHIVE" ]; then
  echo "[!] logarchive not created. Exiting."
  exit 1
fi

# Tarball it
TARFILE="$OUTDIR_BASE/iPhone-${UDID}-${DATE}.tar"
echo "[*] Creating tarball: $TARFILE"
tar -cvf "$TARFILE" -C "$OUTDIR_BASE" "iPhone-${UDID}-${DATE}.logarchive"

# Save a copy of the script itself
SCRIPT_COPY="$OUTDIR_BASE/${CASE}-${EVIDENCE}-Mac-iphone-ULC-${DATE}.sh"
echo "[*] Saving a copy of the script as: $SCRIPT_COPY"
cp "$0" "$SCRIPT_COPY"

# Generate MD5 hashes for each artifact
echo "[*] Generating MD5 hashes..."
HASH_TAR="$OUTDIR_BASE/${CASE}-${EVIDENCE}-Tarball-${DATE}-MD5.txt"
HASH_LOG="$OUTDIR_BASE/${CASE}-${EVIDENCE}-SessionLog-${DATE}-MD5.txt"
HASH_SCRIPT="$OUTDIR_BASE/${CASE}-${EVIDENCE}-Script-${DATE}-MD5.txt"
SUMMARY_HASH="$OUTDIR_BASE/${CASE}-${EVIDENCE}-AllArtifacts-${DATE}-MD5.txt"

md5 "$TARFILE" > "$HASH_TAR"
md5 "$OUTDIR_BASE/$LOGFILE" > "$HASH_LOG"
md5 "$SCRIPT_COPY" > "$HASH_SCRIPT"

# Build summary file
echo "[*] Creating summary MD5 file: $SUMMARY_HASH"
{
  echo "MD5 Summary for Case $CASE / Evidence $EVIDENCE ($DATE)"
  echo "------------------------------------------------------"
  cat "$HASH_TAR"
  cat "$HASH_LOG"
  cat "$HASH_SCRIPT"
} > "$SUMMARY_HASH"

echo "------------------------------------------------------"
echo "[+] Unified log collection complete."
echo "Artifacts created in: $OUTDIR_BASE"
echo "  Session log:        $OUTDIR_BASE/$LOGFILE"
echo "  Tarball:            $TARFILE"
echo "  Script copy:        $SCRIPT_COPY"
echo "Hashes:"
echo "  $HASH_TAR"
echo "  $HASH_LOG"
echo "  $HASH_SCRIPT"
echo "Summary:"
echo "  $SUMMARY_HASH"
echo "------------------------------------------------------"
echo "Verify and preserve all files in your evidence folder."

