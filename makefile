simulate: sim_compile sim_run

sim_compile:
	verilator --binary --top-module embla_tb --trace -f files.f
sim_run:
	./obj_dir/Vembla_tb

build_test: elf bin hex clean

elf:
	riscv64-unknown-elf-gcc \
    -march=rv32im_zicsr \
    -mabi=ilp32 \
    -nostdlib \
    -nostartfiles \
    -Ttext=0x0 \
    tests/test.s \
    -o tests/test.elf
bin:
	riscv64-unknown-elf-objcopy -O binary tests/test.elf tests/test.bin
hex:
	hexdump -v -e '1/4 "%08x\n"' tests/test.bin > tests/program.hex
clean:
	rm -f tests/test.elf tests/test.bin

build_fpga: cl_fp synth pnr gen

cl_fp:
	rm -f build/pack.fs build/routed.json build/synth.json 
synth:
	yosys -m slang synth.ys
pnr:
	nextpnr-himbaechel --json build/synth.json --write build/routed.json --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=src/tangnano20k.cst
gen:
	gowin_pack -d GW2A-18C -o build/pack.fs build/routed.json

load:
	openFPGALoader -b tangnano20k build/pack.fs