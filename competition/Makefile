# Include external config
include /f-of-e-tools/tools/sunflower/conf/setup.conf

# Input/output files
SR_FILE     = program.sr
HEX_FILE    = program.hex
DATA_FILE   = data.hex
GB3_ROOT    = /gb3-resources
SREC2HEX    = srec2hex

# Default rule
all: $(HEX_FILE)

# Convert S-record to HEX
$(HEX_FILE): $(SR_FILE)
	$(SREC2HEX) -b 4096 $(SR_FILE)

# Install: copy files
install: all
	mkdir -p $(GB3_ROOT)/processor/programs/
	cp $(HEX_FILE) $(GB3_ROOT)/processor/programs/
	cp $(DATA_FILE) $(GB3_ROOT)/processor/programs/

# Clean up
clean:
	$(RM) $(HEX_FILE) $(DATA_FILE)
