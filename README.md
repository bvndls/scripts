## xray (macOS-specific)

### Setup

1. `git clone https://github.com/bvndls/scripts.git && cd scripts && chmod +x xray.sh && cp xray.sh raycast_scripts_directory`
2. Open Raycast, type `xray`, and select `Setup`

After the script is done you're good to go!\
Just select the config and the interface you want then press `return`\
Raycast will remember your last selections so it'll be even faster next time

> Tip: assign a shortcut for this script in Raycast settings for an even faster access

### Flow

Setup:
1. Makes a quick search inside of the `home` and `/opt` directories with maxdepth of 6 for any JSON files that contain the `inbounds` key\
    Gets the `path` and `address` key's value for each JSON matching the criteria
2. Gets the name of each network interface
3. Updates the script with the new data

Script:
1. Checks for xray binary using `which`
2. Starts (or stops if already running) the xray binary
3. Sets up proxy settings using `networksetup`

### To-Do
- [ ] Check if Spotlight index has the same configs as the find command without maxdepth and use it if so
- [ ] Rethink build_dropdown and update_dropdowns (possible title_override)
- [ ] Add sciprt update toasts or auto update
- [ ] Optimize jq and make it more readable
- [ ] Add apps back. Find more common binary args for proxy servers first. Or will be limited to Chromium only

### App situation
App proxying was removed because it was available only for Chromium apps.\
If you need this feature, roll back to commit 8687871 or file a PR if you have a more elegant and readable solution.

### Feedback
Please file an Issue or a PR if you have any ideas or fixes
