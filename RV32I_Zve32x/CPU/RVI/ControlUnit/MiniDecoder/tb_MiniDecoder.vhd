library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity tb_MiniDecoder is end entity;

architecture sim of tb_MiniDecoder is
    signal funct3     : std_logic_vector(2 downto 0) := (others => '0');
    signal funct7_5   : std_logic := '0';
    signal ALUOp      : std_logic := '0';
    signal isRtype    : std_logic := '0';
    signal ALUControl : std_logic_vector(3 downto 0);

    component MiniDecoder is
        port (
            funct3     : in  std_logic_vector(2 downto 0);
            funct7_5   : in  std_logic;
            ALUOp      : in  std_logic;
            isRtype    : in  std_logic;
            ALUControl : out std_logic_vector(3 downto 0)
        );
    end component;
begin
    dut : MiniDecoder port map (funct3,funct7_5,ALUOp,isRtype,ALUControl);

    process
        variable l : line;
        procedure apply(name: string; f3: std_logic_vector(2 downto 0);
                        f75: std_logic; op: std_logic; rt: std_logic) is
        begin
            funct3 <= f3; funct7_5 <= f75; ALUOp <= op; isRtype <= rt;
            wait for 10 ns;
            write(l, name);                    write(l, string'(" | ALUOp="));
            write(l, ALUOp);
            write(l, string'(" isRtype="));    write(l, isRtype);
            write(l, string'(" funct3="));     write(l, funct3);
            write(l, string'(" funct7_5="));   write(l, funct7_5);
            write(l, string'("  ->  ALUControl=")); write(l, ALUControl);
            writeline(output, l);
        end procedure;
    begin
        -- ALUOp=0: deve ignorar funct e dar 0000 (soma p/ enderecos)
        apply("ALUOp0    ", "111", '1', '0', '0');
        -- R-type: decodifica de verdade
        apply("add  (R)  ", "000", '0', '1', '1');
        apply("sub  (R)  ", "000", '1', '1', '1'); 
        apply("addi (I)  ", "000", '1', '1', '0');  
        apply("sll  (R)  ", "001", '0', '1', '1');
        apply("slt  (R)  ", "010", '0', '1', '1');
        apply("sltu (R)  ", "011", '0', '1', '1');
        apply("xor  (R)  ", "100", '0', '1', '1');
        apply("srl       ", "101", '0', '1', '1');
        apply("sra       ", "101", '1', '1', '1');
        apply("or   (R)  ", "110", '0', '1', '1');
        apply("and  (R)  ", "111", '0', '1', '1');
        wait;
    end process;
end architecture;
