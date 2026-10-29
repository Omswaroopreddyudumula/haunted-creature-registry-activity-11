"""Run Android integration checks and save actual emulator screenshots."""
import os
import pathlib
import re
import subprocess
import sys
root = pathlib.Path(__file__).resolve().parents[1]
os.chdir(root)
adb = pathlib.Path(os.environ.get('ANDROID_HOME', str(pathlib.Path.home() / 'Library/Android/sdk'))) / 'platform-tools/adb'
output = root / 'evidence'
(output / 'screenshots').mkdir(parents=True, exist_ok=True)
process = subprocess.Popen(['flutter', 'test', 'integration_test/app_test.dart', '-d', 'emulator-5554', '--reporter', 'expanded'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
with (output / 'android-integration.txt').open('w') as log:
 for line in process.stdout:
  print(line, end='', flush=True)
  log.write(line); log.flush()
  match = re.search(r'EVIDENCE:([\w-]+)', line)
  if match:
   image = subprocess.run([str(adb), 'exec-out', 'screencap', '-p'], capture_output=True, check=True).stdout
   (output / 'screenshots' / (match[1] + '.png')).write_bytes(image)
sys.exit(process.wait())
