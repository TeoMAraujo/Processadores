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
 
## coisas a se melhorar:
- implentação de grande parte das instruções vetoriais
- Universalizar unidades de controle e extenders
- Diminuir unidades de controle
- atribuição de pipelines?
- atribuição de superescalares?
- atribuição de Csrs e de flags para o intended result
