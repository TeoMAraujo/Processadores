library IEEE;
use IEEE.std_logic_1164.all;

entity D_flip_flop_tb is
end D_flip_flop_tb;

architecture behavior of D_flip_flop_tb is 

    component D_flip_flop
        generic( W : positive := 1 );
        port(
            D     : in  std_logic_vector(W-1 downto 0);
            CLK   : in  std_logic;
            RST   : in  std_logic;
            Q, Qn : out std_logic_vector(W-1 downto 0)
        );
    end component;

    constant W_TB : positive := 4; 
    constant CLK_PERIOD : time := 10 ns;

    signal D   : std_logic_vector(W_TB-1 downto 0) := (others => '0');
    signal CLK : std_logic := '0';
    signal RST : std_logic := '0';

    signal Q   : std_logic_vector(W_TB-1 downto 0);
    signal Qn  : std_logic_vector(W_TB-1 downto 0);

begin

    uut: D_flip_flop 
        generic map (
            W => W_TB
        )
        port map (
            D   => D,
            CLK => CLK,
            RST => RST,
            Q   => Q,
            Qn  => Qn
        );

    CLK_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
    begin        
        RST <= '1';
        D   <= "0000";
        wait for 20 ns;
        
        RST <= '0';
        wait for CLK_PERIOD;

        D <= "1010";
        wait for CLK_PERIOD;
        
        D <= "0101";
        wait for CLK_PERIOD;
        
        D <= "1111";
        wait for CLK_PERIOD;

        RST <= '1';
        wait for 15 ns; 
        RST <= '0';
        
        D <= "1100";
        wait for CLK_PERIOD;
        
        wait;
    end process;

end behavior;
