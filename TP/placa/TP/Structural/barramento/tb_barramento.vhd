library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_barramento is
end tb_barramento;

architecture sim of tb_barramento is

    signal tb_CLK   : std_logic := '0';
    signal tb_addr  : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_readw : std_logic := '0';
    signal tb_data  : std_logic_vector(7 downto 0) := (others => 'Z'); -- Initialize to High-Z

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 1. Instantiate the Unit Under Test (UUT)
    DUT: entity work.barramento
    port map (
        CLK   => tb_CLK,
        addr  => tb_addr,
        data  => tb_data,   -- This is the bidirectional wire
        readw => tb_readw
    );

    -- 2. Clock Generation Process
    clk_process : process
    begin
        tb_CLK <= '0';
        wait for CLK_PERIOD / 2;
        tb_CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 3. Stimulus Process (The main logic)
    stim_proc: process
    begin
        -- Initial Wait
        wait for 20 ns;

        ------------------------------------------------------------
        -- WRITE CYCLE
        ------------------------------------------------------------
        report "Starting WRITE Cycle...";
        
        -- Write 0xAA (10101010) to Register 0 ("000")
        tb_readw <= '1';            -- Set to Write mode
        tb_addr  <= "000";          -- Select Register 0
        tb_data  <= x"AA";          -- Drive data onto bus
        wait for CLK_PERIOD;        -- Wait for clock edge to capture data

        -- Write 0xBB (10111011) to Register 3 ("011")
        tb_addr  <= "011";          -- Select Register 3
        tb_data  <= x"BB";          -- Drive data
        wait for CLK_PERIOD;

        -- Write 0xFF (11111111) to Register 7 ("111")
        tb_addr  <= "111";          -- Select Register 7
        tb_data  <= x"FF";          -- Drive data
        wait for CLK_PERIOD;

        ------------------------------------------------------------
        -- TURN AROUND (Release Bus)
        ------------------------------------------------------------
        -- IMPORTANT: The Testbench must stop driving the bus 
        -- before asking the peripherals to drive it.
        tb_readw <= '0';            -- Switch to Read mode
        tb_data  <= (others => 'Z'); -- Release the bus (High Impedance)
        wait for CLK_PERIOD;

        ------------------------------------------------------------
        -- READ CYCLE
        ------------------------------------------------------------
        report "Starting READ Cycle...";

        -- Read Register 0 (Expect 0xAA)
        tb_addr <= "000";
        wait for CLK_PERIOD; 
        assert (tb_data = x"AA") report "Error: Reg 0 mismatch!" severity error;

        -- Read Register 3 (Expect 0xBB)
        tb_addr <= "011";
        wait for CLK_PERIOD; 
        assert (tb_data = x"BB") report "Error: Reg 3 mismatch!" severity error;

        -- Read Register 7 (Expect 0xFF)
        tb_addr <= "111";
        wait for CLK_PERIOD; 
        assert (tb_data = x"FF") report "Error: Reg 7 mismatch!" severity error;
        
        -- Read Register 1 (We never wrote to it, expect 0x00 or previous state)
        -- Since your register initializes to 0, we expect 0x00.
        tb_addr <= "001";
        wait for CLK_PERIOD;
        assert (tb_data = x"00") report "Error: Reg 1 mismatch (should be 0)!" severity error;

        report "Simulation Completed Successfully.";
        wait; -- Stop simulation
    end process;

end sim;
