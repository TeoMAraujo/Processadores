set -e  

PREFIX=riscv32-none-elf-   
TYPE=rv32i # extensions
HANDLER=ilp32 # how types are treated

SRC=program.c 
ASS=program.s

bash sh/crosscomp.sh 

${PREFIX}gcc -march=${TYPE} -mabi=${HANDLER} -S -O0 ${SRC} -o ${ASS}


echo "Done -> ${ASS}"
