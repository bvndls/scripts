## xray (macOS-specific)

### Setup

1. `git clone https://github.com/bvndls/scripts.git && cd scripts && chmod +x xray.sh && cp xray.sh raycast_scripts_directory`
2. Open Raycast, type `xray`, and select `Setup`

After the script is done you're good to go!\
Just select the config, app, interface you want and press `return`\
Raycast will remember your last selections so it'll be even faster next time

> Tip: assign a shortcut for this script in Raycast settings for an even faster access

### Flow

Setup:
1. Makes a quick search inside of the `home` and `/opt` directories for any JSON files that contain the `inbounds` key\
    Gets the `path` and `address` key's value for each JSON matching the criteria
2. Gets the name of each app installed under `/Applications`
3. Gets the name of each network interface
4. Updates the script with these values

Script:
1. Gets the xray binary path using `which`
2. `grep`s the selected config and pulls host and port used
3. Starts (or stops if already running) the xray and uses appropriate proxy settings based on the selection\
    Setup – Restarts the setup process in case something has changed.\
    System – Proxies the entire system using `networksetup`\
    App – Proxies an app using the `--proxy-server` argument.

### To-Do

- [x] Merge `setup.sh` into the script with correct `sed` operation
- [x] Add defaults for arguments
- [x] Add verbosity and switch to `fullOutput` for the setup
- [x] Fix jq parse errors (does not affect operation)
- [x] Pull Raycast script directories from a plist?\
`possible with ~/Library/Preferences/com.raycast.macos > NSOSPLastRootDirectory value but highly unreliable`
- [ ] Fix `/System/Applications` breaking sed
- [ ] Fix sed tabs in swapped raycast arugments
- [ ] Check for new configs, apps and interfaces on each script run (background job)

### Feedback
Please file an Issue or a PR if you have any ideas or fixes
