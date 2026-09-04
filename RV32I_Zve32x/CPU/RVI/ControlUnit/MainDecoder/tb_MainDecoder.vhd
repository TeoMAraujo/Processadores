library IEEE;
use IEEE.std_logic_1164.all;

entity tb_MainDecoder is
end entity;

architecture sim of tb_MainDecoder is
    signal opcode : std_logic_vector(6 downto 0) := (others => '0');
    signal Jump, Branch, ALUtoPC, ALUOp, MemWrite, ALUSrc, PCtoALU, RegWrite, isRtype : std_logic;
    signal ResultSrc : std_logic_vector(1 downto 0);
    signal ImmSrc    : std_logic_vector(2 downto 0);
begin
    dut : entity work.MainDecoder
        port map (opcode=>opcode, Jump=>Jump, Branch=>Branch, ALUtoPC=>ALUtoPC,
                  ALUOp=>ALUOp, ResultSrc=>ResultSrc, MemWrite=>MemWrite,
                  ALUSrc=>ALUSrc, PCtoALU=>PCtoALU, ImmSrc=>ImmSrc,
                  RegWrite=>RegWrite, isRtype=>isRtype);

    stim : process
        procedure apply(op : std_logic_vector(6 downto 0); nome : string) is
        begin
            opcode <= op;
            wait for 1 ns;
            report nome &
                   ": RegWrite=" & std_logic'image(RegWrite)(2) &
                   " ImmSrc="    & to_string(ImmSrc) &
                   " ALUSrc="    & std_logic'image(ALUSrc)(2) &
                   " MemWrite="  & std_logic'image(MemWrite)(2) &
                   " ResultSrc=" & to_string(ResultSrc) &
                   " Branch="    & std_logic'image(Branch)(2) &
                   " Jump="      & std_logic'image(Jump)(2) &
                   " ALUOp="     & std_logic'image(ALUOp)(2) &
                   " isRtype="   & std_logic'image(isRtype)(2) severity note;
        end procedure;
    begin
        apply("0000011", "LW   ");
        apply("0100011", "SW   ");
        apply("0110011", "Rtype");
        apply("0010011", "Itype");
        apply("1100011", "Bry  ");
        apply("1101111", "JAL  ");
        apply("1100111", "JALR ");
        apply("0110111", "LUI  ");
        apply("0010111", "AUIPC");

        std.env.stop;
    end process;
end architecture sim;
