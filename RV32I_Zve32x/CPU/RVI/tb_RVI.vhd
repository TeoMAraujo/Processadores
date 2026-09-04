library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_RVI is
end entity;

architecture sim of tb_RVI is
    constant W    : positive := 32;
    constant Tclk : time     := 10 ns;

    signal clk, rst : std_logic := '0';
    signal Instr    : std_logic_vector(W-1 downto 0);
    signal ReadData : std_logic_vector(W-1 downto 0);
    signal PC       : std_logic_vector(W-1 downto 0);
    signal ALUResult: std_logic_vector(W-1 downto 0);
    signal WriteData: std_logic_vector(W-1 downto 0);
    signal Funct3   : std_logic_vector(2 downto 0);
    signal MemWrite : std_logic;
begin
        dut : entity work.RVI
        generic map (W => W)
        port map (CLK=>clk, rst=>rst, ReadData=>ReadData, Instr=>Instr,
                  PC=>PC, ALUResult=>ALUResult, WriteData=>WriteData,
                  Funct3=>Funct3, MemWrite=>MemWrite);

    imem : entity work.InstructionMemory
        generic map (W => W, ADDR_W => 10)
        port map (PC => PC, instruction => Instr);

    dmem : entity work.DataMemory
        generic map (W => W, NUM_REGS => 10)
        port map (clk=>clk, rst=>rst, WE=>MemWrite, funct3=>Funct3,
                  ADDR=>ALUResult(9 downto 0), WD=>WriteData, RD=>ReadData);

    clk <= not clk after Tclk/2;

    stim : process
    begin
        rst <= '1'; wait until rising_edge(clk); rst <= '0';

        for k in 1 to 10 loop
            wait for 10 us;
            report "t=" & time'image(now) &
                   "  PC=0x"  & to_hstring(PC) &
                   "  ALUResult=0x" & to_hstring(ALUResult) severity note;
        end loop;

        std.env.stop;
    end process;
end architecture sim;
