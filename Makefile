.PHONY: \
	softwareblink \
	hardwareblink \
	bubblesort \
	competition \
	clean

softwareblink:
	cd softwareblink; make clean; make; make install
	cd processor; make

hardwareblink:
	cd hardwareblink; make clean; make;

bubblesort:
	cd bubblesort; make clean; make; make install
	cd processor; make

competition:
	cd competition; make clean; make; make install
	cd processor; make

clean:
	cd softwareblink; make clean
	cd hardwareblink; make clean
	cd bubblesort; make clean
	cd processor; make clean
	rm -f build/*.bin
