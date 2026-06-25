# tree [![Build](https://github.com/qnx-ports/build-files/actions/workflows/tree.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/tree.yml)

# Compile the port for QNX

**Note**: QNX ports are only supported from a **Linux host** operating system

Use `$(nproc)` instead of `4` after `JLEVEL=` and `-j` if you want to use the maximum number of cores to build this project.
32GB of RAM is recommended for using `JLEVEL=$(nproc)` or `-j$(nproc)`.

# Compile the port for QNX in a Docker container

Pre-requisite: Install Docker on Ubuntu https://docs.docker.com/engine/install/ubuntu/

```bash
# Create a workspace
mkdir -p ~/qnx_workspace && cd ~/qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Build the Docker image and create a container
cd build-files/docker
./docker-build-qnx-image.sh
./docker-create-container.sh

# Now you are in the Docker container

# Source qnxsdp-env.sh in
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone tree
git clone https://github.com/Old-Man-Programmer/tree.git
cd tree
git checkout 2.3.2
cd ..

# Build tree
#QNX_PROJECT_ROOT=<source_path>
make -C build-files/ports/tree/  install
```

# Compile the port for QNX on Ubuntu host

```bash
# Clone the repos
mkdir -p ~/qnx_workspace && cd qnx_workspace
git clone https://github.com/qnx-ports/build-files.git

# Source SDP environment
source ~/qnx800/qnxsdp-env.sh
cd ~/qnx_workspace

# Clone tree
git clone https://github.com/Old-Man-Programmer/tree.git
cd tree
git checkout 2.3.2
cd ..

# Build tree
#QNX_PROJECT_ROOT=<source_path>
make -C build-files/ports/tree/  install
```


# Testing :

After building tree for your QNX target, validation is straightforward. The make process already compiles test binaries and copies test data to the CPU-specific directory (nto-<cpudir>). Deploy and run tests on your target device (RPi/x86 QNX machine).

Prerequisites:
    1. Built tree artifacts in build-files/ports/tree/nto-<cpudir>/
    2. Write permissions on target /tmp (or use TMPDIR=/fs/hd0/temp)
    3. SSH access to target device

1. Deploy to Target Device
```bash
TARGET_HOST=<target-ip-or-hostname>

#creating ~/guests directory on target
ssh qnxuser@$TARGET_HOST "mkdir -p ~/guests"

# Copy entire CPU directory to target
scp -r ./build-files/ports/tree/nto-aarch64-le qnxuser@$TARGET_HOST:~/guests/guests/
```
2. SSH to Target and Setup Environment
```bash
ssh qnxuser@<TARGET_HOST>
cd ~/guests/guests/nto-aarch64-le
```
3. Run Validation Tests
```bash
# Execute tree utill
./tree --help
```
4. Expected Results
```text
===============================================================================
[qnxuser@qnxqemu /home/qnxuser/guests/nto-aarch64-le]$ ./tree --help
usage: tree [-acdfghilnpqrstuvxACDFJQNSUX] [-L level [-R]] [-H [-]baseHREF]
	[-T title] [-o filename] [-P pattern] [-I pattern] [--gitignore]
	[--gitfile[=]file] [--matchdirs] [--metafirst] [--ignore-case]
	[--nolinks] [--hintro[=]file] [--houtro[=]file] [--inodes] [--device]
	[--sort[=]name] [--dirsfirst] [--filesfirst] [--filelimit[=]#] [--si]
	[--du] [--prune] [--charset[=]X] [--timefmt[=]format] [--fromfile]
	[--fromtabfile] [--fflinks] [--info] [--infofile[=]file] [--noreport]
	[--hyperlink] [--scheme[=]schema] [--authority[=]host] [--opt-toggle]
	[--compress[=]#] [--condense] [--version] [--help]
	[--] [directory ...]
  ------- Listing options -------
  -a            All files are listed.
  -d            List directories only.
  -l            Follow symbolic links like directories.
  -f            Print the full path prefix for each file.
  -x            Stay on current filesystem only.
  -L level      Descend only level directories deep.
  -R            Rerun tree when max dir level reached.
  -P pattern    List only those files that match the pattern given.
  -I pattern    Do not list files that match the given pattern.
  --gitignore   Filter by using .gitignore files.
  --gitfile X   Explicitly read a gitignore file.
  --ignore-case Ignore case when pattern matching.
  --matchdirs   Include directory names in -P pattern matching.
  --metafirst   Print meta-data at the beginning of each line.
  --prune       Prune empty directories from the output.
  --info        Print information about files found in .info files.
  --infofile X  Explicitly read info file.
  --noreport    Turn off file/directory count at end of tree listing.
  --charset X   Use charset X for terminal/HTML and indentation line output.
  --filelimit # Do not descend dirs with more than # files in them.
  --condense    Condense directory singletons to a single line of output.
  -o filename   Output to file instead of stdout.
  ------- File options -------
  -q            Print non-printable characters as '?'.
  -N            Print non-printable characters as is.
  -Q            Quote filenames with double quotes.
  -p            Print the protections for each file.
  -u            Displays file owner or UID number.
  -g            Displays file group owner or GID number.
  -s            Print the size in bytes of each file.
  -h            Print the size in a more human readable way.
  --si          Like -h, but use in SI units (powers of 1000).
  --du          Compute size of directories by their contents.
  -D            Print the date of last modification or (-c) status change.
  --timefmt fmt Print and format time according to the format fmt.
  -F            Appends '/', '=', '*', '@', '|' or '>' as per ls -F.
  --inodes      Print inode number of each file.
  --device      Print device ID number to which each file belongs.
  ------- Sorting options -------
  -v            Sort files alphanumerically by version.
  -t            Sort files by last modification time.
  -c            Sort files by last status change time.
  -U            Leave files unsorted.
  -r            Reverse the order of the sort.
  --dirsfirst   List directories before files (-U disables).
  --filesfirst  List files before directories (-U disables).
  --sort X      Select sort: name,version,size,mtime,ctime,none.
  ------- Graphics options -------
  -i            Don't print indentation lines.
  -A            Print ANSI lines graphic indentation lines.
  -S            Print with CP437 (console) graphics indentation lines.
  -n            Turn colorization off always (-C overrides).
  -C            Turn colorization on always.
  --compress #  Compress indentation lines.
  ------- XML/HTML/JSON/HYPERLINK options -------
  -X            Prints out an XML representation of the tree.
  -J            Prints out an JSON representation of the tree.
  -H baseHREF   Prints out HTML format with baseHREF as top directory.
  -T string     Replace the default HTML title and H1 header with string.
  --nolinks     Turn off hyperlinks in HTML output.
  --hintro X    Use file X as the HTML intro.
  --houtro X    Use file X as the HTML outro.
  --hyperlink   Turn on OSC 8 terminal hyperlinks.
  --scheme X    Set OSC 8 hyperlink scheme, default file://
  --authority X Set OSC 8 hyperlink authority/hostname.
  ------- Input options -------
  --fromfile    Reads paths from files (.=stdin)
  --fromtabfile Reads trees from tab indented files (.=stdin)
  --fflinks     Process link information when using --fromfile.
  ------- Miscellaneous options -------
  --opt-toggle  Enable option toggling.
  --version     Print version and exit.
  --help        Print usage and this help message and exit.
  --            Options processing terminator.
```
