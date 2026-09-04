library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux is
end entity tb_mux;

architecture tb_mux_arch of tb_mux is

    component Mux_2x1
    generic (
        W : positive := 1
    );
    port(
        A, B : in std_logic_vector(W - 1 downto 0);
        S    : in std_logic;
        Y    : out std_logic_vector(W - 1 downto 0)
    );
    end component;

    signal D1_tb  : std_logic_vector(3 downto 0) := "0000";
    signal D0_tb  : std_logic_vector(3 downto 0) := "0000";
    signal SEL_tb : std_logic := '0';
    signal Y_tb   : std_logic_vector(3 downto 0);

begin

    DUT : Mux_2x1
    generic map (
        W => 4
    )
    port map (
        A   => D1_tb,
        B   => D0_tb,
        S   => SEL_tb,
        Y   => Y_tb
    );

    stimulus_process : process
    begin
        D1_tb <= "1010";
        D0_tb <= "0101"; 
        wait for 10 ns;

        SEL_tb <= '0';
        wait for 10 ns;

        D1_tb <= "1000";
        D0_tb <= "0011";
        SEL_tb <= '1';
        wait for 10 ns;

        D1_tb <= "1111";
        D0_tb <= "0000";
        wait for 10 ns;

        SEL_tb <= '0';
        wait for 10 ns;
       
        wait; 
    end process stimulus_process;

end architecture;
