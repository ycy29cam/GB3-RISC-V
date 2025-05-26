## Terminal, WSL, Docker Shortcuts

This is a markdown document containing frequently used commands for easier access.

&nbsp;

### Entering WSL
In Windows terminal
```
wsl
```
&nbsp;

### Shortcut to directory
```
cd C:\Users\user\Documents\IIA-GB3\GB3-RISC-V
```
&nbsp;

### Opening a Docker container (before using Docker tools for building)
In Docker terminal
```
docker run --rm -it -v /c/Users/user/Documents/IIA-GB3/GB3-RISC-V:/gb3-resources ghcr.io/f-of-e/gb3-tools:latest /bin/bash
```
&nbsp;

### Design synthesis (textual description to digital logic design, step 1 of 3 in building)
In Docker terminal, in Docker container
```
yosys -p "synth_ice40 -blif <file_name>.blif; write_json <file_name>.json" <file_name>.v
```
&nbsp;

### Design place and route for the iCE40 Ultra FPGA (netlist to logic blocks, step 2 of 3 in building)
In Docker terminal, in Docker container, after design synthesis
```
nextpnr-ice40 --up5k --package uwg30 --json <file_name>.json --pcf <file_name>.pcf --asc <file_name>.asc
```
&nbsp;

### Converting the ASCII file into a bitstream (step 3 of 3 in building)
In Docker terminal, in Docker container, after place and route
```
icepack <file_name>.asc <file_name>.bin
```
&nbsp;

### Read USB Port (before and after plugging in FPGA)
In Windows terminal
```
usbipd list
```
&nbsp;

### Attach USB Port
In Windows terminal
```
usbipd attach --busid <bus_ID> --wsl Ubuntu
```

### Load the built binary to the MDP
In Windows terminal with WSL
```
sudo iceprog -S <file_name>.bin
```