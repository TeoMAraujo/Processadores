library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_D_EN_flip_flop is
end tb_D_EN_flip_flop;

architecture test of tb_D_EN_flip_flop is

    component D_EN_flip_flop
        generic( W : positive := 1 );
        port(
            D   : in  std_logic_vector(W-1 downto 0);
            CLK : in  std_logic;
            RST : in  std_logic;
            EN  : in  std_logic;
            Q   : out std_logic_vector(W-1 downto 0);
            Qn  : out std_logic_vector(W-1 downto 0)
        );
    end component;

    constant W_TB : positive := 4; 
    constant CLK_PERIOD : time := 10 ns;

    signal D_tb   : std_logic_vector(W_TB-1 downto 0) := (others => '0');
    signal CLK_tb : std_logic := '0';
    signal RST_tb : std_logic := '0';
    signal EN_tb  : std_logic := '0';
    signal Q_tb   : std_logic_vector(W_TB-1 downto 0);
    signal Qn_tb  : std_logic_vector(W_TB-1 downto 0);

begin

    uut: D_EN_flip_flop
        generic map (
            W => W_TB
        )
        port map (
            D   => D_tb,
            CLK => CLK_tb,
            RST => RST_tb,
            EN  => EN_tb,
            Q   => Q_tb,
            Qn  => Qn_tb
        );

    clk_process : process
    begin
        CLK_tb <= '0';
        wait for CLK_PERIOD/2;
        CLK_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin
        RST_tb <= '1';
        EN_tb  <= '0';
        D_tb   <= "1010"; 
        wait for CLK_PERIOD * 2;

        assert Q_tb = "0000" report "Error: Reset failed to clear Output" severity error;
        RST_tb <= '0';
        wait for CLK_PERIOD;

        D_tb <= "1111";
        EN_tb <= '0';
        wait for CLK_PERIOD;
        assert Q_tb = "0000" report "Error: Q changed while Enable was LOW" severity error;

        EN_tb <= '1';
        wait for CLK_PERIOD;
        assert Q_tb = "1111" report "Error: Q failed to update when Enable was HIGH" severity error;
        assert Qn_tb = "0000" report "Error: Qn (inverted) is incorrect" severity error;

        D_tb <= "0101";
        wait for CLK_PERIOD;
        assert Q_tb = "0101" report "Error: Q failed to update new value" severity error;

        RST_tb <= '1';
        wait for 2 ns; 
        assert Q_tb = "0000" report "Error: Async Reset failed during operation" severity error;
        
        wait for CLK_PERIOD;
        RST_tb <= '0';

        report "Simulation Finished successfully";
        wait;
    end process;

end architecture test;