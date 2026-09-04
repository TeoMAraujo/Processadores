library IEEE;
use IEEE.std_logic_1164.all;

entity D_flip_flop_tb is
-- Testbench entity is always empty
end D_flip_flop_tb;

architecture behavior of D_flip_flop_tb is 

    -- Component Declaration for the Unit Under Test (UUT)
    component D_flip_flop
        generic( W : positive := 1 );
        port(
            D     : in  std_logic_vector(W-1 downto 0);
            CLK   : in  std_logic;
            RST   : in  std_logic;
            Q, Qn : out std_logic_vector(W-1 downto 0)
        );
    end component;

    -- Constants
    constant W_TB : positive := 4; -- Testing with a 4-bit bus
    constant CLK_PERIOD : time := 10 ns;

    -- Inputs
    signal D   : std_logic_vector(W_TB-1 downto 0) := (others => '0');
    signal CLK : std_logic := '0';
    signal RST : std_logic := '0';

    -- Outputs
    signal Q   : std_logic_vector(W_TB-1 downto 0);
    signal Qn  : std_logic_vector(W_TB-1 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
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

    -- Clock process definitions
    CLK_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- 1. Initial Reset Check
        -- Hold reset state for 2 clock cycles to ensure clean start
        report "Starting Simulation: Applying Initial Reset";
        RST <= '1';
        D   <= "0000";
        wait for 20 ns;
        
        -- Release Reset
        RST <= '0';
        wait for CLK_PERIOD;

        -- 2. Data Latching Test
        -- Apply pattern "1010" (0xA)
        D <= "1010";
        wait for CLK_PERIOD;
        
        -- Apply pattern "0101" (0x5)
        D <= "0101";
        wait for CLK_PERIOD;
        
        -- Apply pattern "1111" (0xF)
        D <= "1111";
        wait for CLK_PERIOD;

        -- 3. Asynchronous Reset Test
        -- Assert Reset while data is held high to verify Q goes low immediately
        report "Testing Asynchronous Reset functionality";
        RST <= '1';
        wait for 15 ns; -- Wait slightly longer than a period to see effect
        RST <= '0';
        
        -- 4. Recovery
        -- Latch new data after reset release
        D <= "1100";
        wait for CLK_PERIOD;
        
        -- End of simulation
        report "Simulation Completed Successfully";
        wait;
    end process;

end behavior;