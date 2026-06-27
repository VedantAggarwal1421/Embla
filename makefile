simulate: sim_compile sim_run

sim_compile:
	verilator --binary --top-module embla_tb -f files.f
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