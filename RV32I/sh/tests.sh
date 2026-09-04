set -e
DUT=$1
TB=tb_${DUT}
WAVE=${DUT}.ghw
ghdl --remove --std=08
ghdl -i --std=08 $(find . -name '*.vhd' -o -name '*.vhdl')
ghdl -m --std=08 ${TB}
ghdl -r --std=08 ${TB} --wave=${WAVE} --stop-time=1ms
gtkwave ${WAVE}
