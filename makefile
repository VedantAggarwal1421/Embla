simulate: sim_compile sim_run

sim_compile:
	verilator --binary --top-module embla_tb --trace-vcd -f files.f
sim_run:
	./obj_dir/Vembla_tb

build_test: obj bin hex clean

obj:
	riscv64-linux-gnu-as -march=rv32i tests/test.s -o tests/test.o
bin:
	riscv64-linux-gnu-objcopy -O binary tests/test.o tests/test.bin
hex:
	hexdump -v -e '1/4 "%08x\n"' tests/test.bin > tests/program.hex
clean:
	rm -f tests/test.o tests/test.bin

build_fpga: synth pnr gen

synth:
	yosys -m slang synth.ys
pnr:
	nextpnr-himbaechel --json build/synth.json --write build/routed.json --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=src/tangnano20k.cst
gen:
	gowin_pack -d GW2AR-LV18QN88C8/I7 -o build/pack.fs build/routed.json

load_fpga:
	openFPGALoader -b tangnano20k build/pack.fs