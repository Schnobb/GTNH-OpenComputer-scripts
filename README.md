# GTNH-OpenComputer Scripts

This is just a collection of OC computer scripts for my GTNH run. Mostly experiments for learning OC and have fun.

### mainmon

***Requires a tier 2 redstone card***

Maintenance Monitor

Sweeps wireless redstone channels using a tier 2 redstone card and raises an alarm when a signal is detected on a monitored channel. 

The module enables a redstone signal in the back of the computer if an alert is detected, this can be used to trigger an howler alarm or a lamp or whatever. 

Comes with an optional rc.d daemon called mainmond in the rc sub-directory if you want to install it as a service.

Check out mainmon/config.lua to configure monitored channel and name them.

## Requirements

Python on (Windows) host machine, internet card in your OC machine. I play single-player so everything runs on the same machine, the server.bat starts a simple http file server hosted on `127.0.0.1:8000`. Would not recommend opening that to the internet probably.

## Usage

### Installation

1. Run `py build.py` to generate setup.lua and uninstall.lua
2. Run `server.bat` to host a quick file server from the local repo
3. In game on your OC machine run `wget -f http://127.0.0.1:8000/setup.lua && setup`

### Autorun

Two options are available to autorun some scripts (only mainmon for now)

#### rc.d

Uses the runcommand service module in OpenOS. This loads before the shell and _might_ save a bit of RAM


1. Copy the daemon script (e.g. `mainmon/rc/mainmond.lua`) to `/etc/rc.d/`
2. Run `rc <daemon name> enable` (e.g. `rc mainmond enable`) to autorun at boot

#### .shrc

Shell autorun script located in `/home/`

1. Run `edit .shrc` (in your home directory)
2. Add `<module directory>/<module name>` (e.g. `mainmon/mainmon`) and save