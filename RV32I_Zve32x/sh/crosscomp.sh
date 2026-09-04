set -e

PREFIX=riscv32-none-elf-
TYPE=rv32i
HANDLER=ilp32

SRC=../c/program.c
ELF=../c/program.elf
BIN=../c/program.bin
TXT=../c/program.txt
HEX=../c/program.hex

nix-shell -A riscv shell.nix

${PREFIX}gcc -march=${TYPE} -mabi=${HANDLER} \
    -nostdlib -ffreestanding -O0 \
    -Wl,-Ttext=0x0 \
    -o ${ELF} ${SRC}

# visualize code
${PREFIX}objdump -d ${ELF} > ${TXT}

# VHDL
${PREFIX}objdump -d ${ELF} \
    | awk -F'\t' 'NF>=3 { s = $2; gsub(/ /, "", s); print s; }' > ${HEX}

rm -f ${BIN} ${ELF}
echo "Done -> ${TXT} e ${HEX}"
