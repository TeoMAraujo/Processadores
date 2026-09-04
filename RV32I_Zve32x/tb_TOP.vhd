library IEEE;
use IEEE.std_logic_1164.all;

entity tb_TOP is
end entity tb_TOP;

architecture sim of tb_TOP is
    component TOP is
        generic (
            W : positive := 32
        );
        port (
            CLK : in STD_LOGIC;
            RST : in STD_LOGIC
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    signal CLK : STD_LOGIC := '0';
    signal RST : STD_LOGIC := '0';
begin
    UUT : TOP
        generic map (W => 32)
        port map (
            CLK => CLK,
            RST => RST
        );
    clk_gen : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_gen;
    process
        variable regs : work.RegFile_pkg.reg_array(31 downto 0)(31 downto 0);
    begin
        wait for 100 us;
        regs := << signal .tb_TOP.UUT.U_CPU.scalar_core.DP.registerF.matrix
                   : work.RegFile_pkg.reg_array(31 downto 0)(31 downto 0) >>;
        report "a0 = " &
            to_hstring(regs(10));
        report "a1 = " &
            to_hstring(regs(11));
        wait;
    end process;
end architecture sim;
