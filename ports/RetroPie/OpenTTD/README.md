# OpenTTD
An open-source re-implementation of Transport Tycoon Deluxe. Now available on QNX!

**Repository:** https://github.com/qnx-ports/OpenTTD \
**Upstream:** https://github.com/OpenTTD/OpenTTD \
**Website:** https://www.openttd.org/ \

## Dependencies
You will need:
- SDL2, available to build at https://github.com/qnx-ports/build-files at ports/SDL
- Font Packages, available from QNX Software Centre with package ID com.qnx.qnx800.target.screen.fonts.engine

You will also want `curl` and `unzip` installed as utilities for your host system.

## Some Notes
Currently, only mouse controls are fully supported in-game on QNX. Keyboard keybinds do work, however text entry needs to use the mouse compatible keyboard (double click on the input box).

Also note than on Raspberry Pi, higher graphics resolutions may crash the game due to insufficient vram.

## Building
Once you have the required dependencies (SDL2 and the font package from QNX Software Centre, see above) you can build OpenTTD for QNX. \
**NOTE:** It is recommended to install OpenTTD as part of the RetroPie project. If you do not, make sure to also install a graphics package manually https://www.openttd.org/downloads/opengfx-releases/latest 

```bash
#1. Make a working directory
mkdir -p ~/working_dir
cd ~/working_dir

#2. Clone the required repos
git clone https://github.com/qnx-ports/build-files
git clone https://github.com/qnx-ports/OpenTTD

#3. [OPTIONAL] Start the docker image
cd build-files/docker
./docker-build-qnx-image
./docker-create-container
cd ~/working_dir

#4. Build OpenTTD 
cd build-files/ports/RetroPie/OpenTTD
make staged

#5. Grab and install base graphics
# Pick from a set at this link: https://www.openttd.org/downloads/opengfx-releases/latest
# Download it in browser or via curl
# unzip it and move the .tar to staging/baseset
#Example:
curl <your link here> --output opengfx-7.1-all.zip
unzip opengfx-7.1-all.zip
cp opengfx-7.1.tar staging/baseset/

#6. Install to your device via ssh
scp -r staging <username>@<ip>:~/path/to/install/
```

## Running OpenTTD
If installed via RetroPie, you can launch it from the main menu or manually via script: 
```bash
ssh <target user>@<target ip>
cd retropie/OpenTTD
./startopenttd.sh
```
(Note that via script is significantly faster)

If installed via the process above, navigateto your installation and run the startopenttd script:
```bash
ssh <target user>@<target ip>
cd path/to/install
./startopenttd.sh
```