library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ControlUnit is
end entity;

architecture sim of tb_ControlUnit is
    signal opcode   : std_logic_vector(6 downto 0) := (others => '0');
    signal funct3   : std_logic_vector(2 downto 0) := (others => '0');
    signal funct7_5 : std_logic := '0';
    signal Btake    : std_logic := '0';

    signal PCSrc, ALUtoPC, MemWrite, ALUSrc, PCtoALU, RegWrite : std_logic;
    signal ResultSrc : std_logic_vector(1 downto 0);
    signal ALUControl : std_logic_vector(3 downto 0);
    signal ImmSrc    : std_logic_vector(2 downto 0);
begin
    dut : entity work.ControlUnit
        port map (opcode=>opcode, funct3=>funct3, funct7_5=>funct7_5, Btake=>Btake,
                  PCSrc=>PCSrc, ALUtoPC=>ALUtoPC, ResultSrc=>ResultSrc,
                  MemWrite=>MemWrite, ALUControl=>ALUControl, ALUSrc=>ALUSrc,
                  PCtoALU=>PCtoALU, ImmSrc=>ImmSrc, RegWrite=>RegWrite);

    stim : process
        procedure apply(op : std_logic_vector(6 downto 0);
                        f3 : std_logic_vector(2 downto 0);
                        f7 : std_logic; bt : std_logic; nome : string) is
        begin
            opcode <= op; funct3 <= f3; funct7_5 <= f7; Btake <= bt;
            wait for 1 ns;
            report nome &
                   ": RegWrite=" & std_logic'image(RegWrite)(2) &
                   " ALUSrc="    & std_logic'image(ALUSrc)(2) &
                   " MemWrite="  & std_logic'image(MemWrite)(2) &
                   " PCSrc="     & std_logic'image(PCSrc)(2) &
                   " ResultSrc=" & to_string(ResultSrc) &
                   " ImmSrc="    & to_string(ImmSrc) &
                   " ALUControl="& to_string(ALUControl) severity note;
        end procedure;
    begin
        apply("0110011","000",'0','0', "R-type ADD ");
        apply("0110011","000",'1','0', "R-type SUB ");
        apply("0010011","000",'0','0', "I-type ADDI");
        apply("0000011","010",'0','0', "LW         ");
        apply("0100011","010",'0','0', "SW         ");
        apply("1100011","000",'0','1', "BEQ (taken)");

        report "fim dos estimulos" severity note;
        std.env.stop;
    end process;
end architecture sim;
