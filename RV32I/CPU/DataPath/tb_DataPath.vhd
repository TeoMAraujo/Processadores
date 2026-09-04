library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_DataPath is
end entity;

architecture sim of tb_DataPath is
    constant W    : positive := 32;
    constant Tclk : time     := 10 ns;

    signal clk, rst   : std_logic := '0';
    signal Instr      : std_logic_vector(W-1 downto 0) := (others => '0');
    signal PCSrc      : std_logic := '0';
    signal ALUtoPC    : std_logic := '0';
    signal ResultSrc  : std_logic_vector(1 downto 0) := "00";
    signal ALUControl : std_logic_vector(3 downto 0) := "0000";
    signal ALUSrc     : std_logic := '0';
    signal PCtoALU    : std_logic := '0';
    signal ImmSrc     : std_logic_vector(2 downto 0) := "000";
    signal RegWrite   : std_logic := '0';
    signal Btake      : std_logic;
    signal ReadData   : std_logic_vector(W-1 downto 0) := (others => '0');
    signal ALUResult  : std_logic_vector(W-1 downto 0);
    signal PC         : std_logic_vector(W-1 downto 0);
    signal WriteData  : std_logic_vector(W-1 downto 0);

    function addi(rd, imm : integer) return std_logic_vector is
        variable i : std_logic_vector(W-1 downto 0) := (others => '0');
    begin
        i(31 downto 20) := std_logic_vector(to_signed(imm, 12));
        i(11 downto  7) := std_logic_vector(to_unsigned(rd, 5));
        return i;
    end function;

    function rtype(rd, rs1, rs2 : integer) return std_logic_vector is
        variable i : std_logic_vector(W-1 downto 0) := (others => '0');
    begin
        i(24 downto 20) := std_logic_vector(to_unsigned(rs2, 5));
        i(19 downto 15) := std_logic_vector(to_unsigned(rs1, 5));
        i(11 downto  7) := std_logic_vector(to_unsigned(rd, 5));
        return i;
    end function;
begin
    dut : entity work.DataPath
        generic map (W => W)
        port map (clk=>clk, rst=>rst, Instr=>Instr, PCSrc=>PCSrc,
                  ALUtoPC=>ALUtoPC, ResultSrc=>ResultSrc, ALUControl=>ALUControl,
                  ALUSrc=>ALUSrc, PCtoALU=>PCtoALU, ImmSrc=>ImmSrc,
                  RegWrite=>RegWrite, Btake=>Btake, ReadData=>ReadData,
                  ALUResult=>ALUResult, PC=>PC, WriteData=>WriteData);

    clk <= not clk after Tclk/2;

    stim : process
        procedure load(rd, imm : integer) is
        begin
            Instr     <= addi(rd, imm);
            ImmSrc    <= "000";
            ResultSrc <= "11";
            ALUSrc    <= '1';
            RegWrite  <= '1';
            wait until rising_edge(clk);
        end procedure;

        procedure run(rd, rs1, rs2 : integer; op : std_logic_vector(3 downto 0);
                      nome : string) is
        begin
            Instr      <= rtype(rd, rs1, rs2);
            ALUControl <= op;
            ALUSrc     <= '0';
            ResultSrc  <= "00";
            RegWrite   <= '0';
            wait for 1 ns;
            report nome & " -> ALUResult = " &
                   integer'image(to_integer(signed(ALUResult))) &
                   "  (0x" & to_hstring(ALUResult) & ")" severity note;
        end procedure;
    begin
        rst <= '1'; wait until rising_edge(clk); rst <= '0';

        load(1, 20);      -- x1 = 20
        load(2, 7);       -- x2 = 7

        run(3, 1, 2, "0000", "ADD 20+7");
        run(3, 1, 2, "0001", "SUB 20-7");
        run(3, 1, 2, "0101", "AND 20&7");
        run(3, 1, 2, "0110", "OR  20|7");

        std.env.stop;
    end process;
end architecture sim;
