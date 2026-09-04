library IEEE;
use IEEE.std_logic_1164.all;

entity tb_demux is
end entity tb_demux;

architecture tb_demux_arch of tb_demux is

    component Demux_1x2
    generic (
        W : positive := 1
    );
    port(
        A  : in  std_logic_vector(W-1 downto 0);
        S  : in  std_logic;
        Y0 : out std_logic_vector(W-1 downto 0);
        Y1 : out std_logic_vector(W-1 downto 0)
    );
    end component;

    signal S_tb : std_logic := '0';
    signal D_tb : std_logic_vector(3 downto 0) := "0000";
    signal Y0_tb : std_logic_vector(3 downto 0);
    signal Y1_tb : std_logic_vector(3 downto 0);

begin

    DUT : Demux_1x2
    generic map (
        W => 4
    )
    port map (
        A  => D_tb,
        S  => S_tb,
        Y0 => Y0_tb,
        Y1 => Y1_tb
    );

    stimulus_process : process
    begin

        D_tb <= "1100";
        S_tb <= '0'; 
        wait for 10 ns;

        D_tb <= "1010";
        S_tb <= '0'; 
        wait for 10 ns;

        D_tb <= "0011";
        S_tb <= '1'; 
        wait for 10 ns;
        
        D_tb <= "0001";
        S_tb <= '0';
        wait for 10 ns;
        
        wait;
    end process stimulus_process;
    
end architecture tb_demux_arch;
