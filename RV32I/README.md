# Descrition:
this is a simple single cycle, with full RISC-V 32I ISA, 
whereas with some commands, you can input a C program, which will be returned a0 and a1 registers to check i'ts validity

also all the packages used are included on nix-shell, with 3 types of argumments

> `bash sh/crosscomp.sh` -> to compile to elf

to get the specifcs packages to test vhdl:
> `nix-shell -A riscv shell.nix`

then 
>`bash sh/tests.sh` -> to test any module
>`bash sh/assembly.sh` -> to view the assembly

