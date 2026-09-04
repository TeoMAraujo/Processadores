# Projeto ControlUnit RISC-V — simulacao com GHDL

## Arquivos

Fontes de design (o seu circuito):
  - MainDecoder.vhd     decodifica opcode -> sinais de controle do datapath
  - MiniDecoder.vhd     decodifica funct3/funct7_5 + ALUOp -> ALUControl
  - ControlUnit.vhd     topo: instancia os dois + logica de branch/jump

Testbenches (so imprimem a tabela, conferencia visual):
  - tb_MainDecoder.vhd
  - tb_MiniDecoder.vhd
  - tb_ControlUnit.vhd

## Como rodar (GHDL)

O ciclo e sempre: analisar (-a) -> elaborar (-e) -> rodar (-r).
O -a recebe ARQUIVOS (dependencias primeiro). O -e/-r recebem o nome
da ENTIDADE do testbench (nao o nome do arquivo).

### MiniDecoder
    ghdl -a --std=08 MiniDecoder.vhd tb_MiniDecoder.vhd
    ghdl -e --std=08 tb_MiniDecoder
    ghdl -r --std=08 tb_MiniDecoder

### MainDecoder
    ghdl -a --std=08 MainDecoder.vhd tb_MainDecoder.vhd
    ghdl -e --std=08 tb_MainDecoder
    ghdl -r --std=08 tb_MainDecoder

### ControlUnit (precisa dos 3 fontes, pois instancia os outros dois)
    ghdl -a --std=08 MainDecoder.vhd MiniDecoder.vhd ControlUnit.vhd tb_ControlUnit.vhd
    ghdl -e --std=08 tb_ControlUnit
    ghdl -r --std=08 tb_ControlUnit

## Dicas

- Sempre use o MESMO --std em todos os comandos de um projeto (aqui: --std=08).
- Se aparecer "cannot find entity": confira se voce passou o nome da ENTIDADE
  (ex: tb_MiniDecoder), nao o nome do arquivo.
- Se algo der erro estranho sem motivo: rode  rm -f *.cf  e recompile do zero
  (o *.cf guarda o estado da biblioteca de trabalho).
- Para ver formas de onda:  acrescente --wave=onda.ghw  no comando -r,
  depois abra com:  gtkwave onda.ghw   (precisa instalar o gtkwave).

## Observacao importante

Estes testbenches MOSTRAM o que cada modulo produz; a conferencia contra a
especificacao RISC-V do seu projeto e sua. Eles foram validados apenas no
sentido de que compilam, rodam, e a saida e coerente com a logica escrita nos
fontes — nao que a tabela de verdade esteja "correta" segundo a sua disciplina.
