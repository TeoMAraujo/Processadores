#!/usr/bin/env bash

set -e

PREFIX=riscv32-none-elf-
MARCH=rv32i_zve32x       # instrucoes de config vetorial (vset*) exigem a extensao
MABI=ilp32

ASMDIR=../s             # escopo dos testes de assembly
NAME=${1:-program.s}
SRC=${ASMDIR}/${NAME}
HEX=../c/program.hex     # InstructionMemory.vhd le este arquivo
TXT=${ASMDIR}/${NAME%.s}.txt   # disassembly fica junto do fonte
ELF=$(mktemp --suffix=.elf)

# 1) montar + linkar no endereco 0 (asm puro, sem runtime C)
${PREFIX}gcc -march=${MARCH} -mabi=${MABI} \
    -nostdlib -ffreestanding -O0 \
    -Wl,-Ttext=0x0 \
    -o "${ELF}" "${SRC}"

# disassembly 
${PREFIX}objdump -d "${ELF}" > "${TXT}"

# 3) coluna de codigo de maquina -> uma palavra hex por linha
${PREFIX}objdump -d "${ELF}" \
    | awk -F'\t' 'NF>=3 { s=$2; gsub(/ /,"",s); print s; }' > "${HEX}"

rm -f "${ELF}"
echo "Done: ${SRC} -> ${HEX}  (disassembly em ${TXT})"
