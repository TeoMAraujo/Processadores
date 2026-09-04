library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reg_8bit is
end tb_reg_8bit;

architecture sim of tb_reg_8bit is

    component reg_8bit
    generic(
        faddr: std_logic_vector(2 downto 0)
    );
    port(
        CLK   : in    std_logic;
        addr  : in    std_logic_vector(2 downto 0);
        data  : inout std_logic_vector(7 downto 0);
        readw : in    std_logic
    );
    end component;

    constant PERIPHERAL_ADDR : std_logic_vector(2 downto 0) := "101";
    -- Address 5
    
    signal s_CLK   : std_logic := '0';
    signal s_addr  : std_logic_vector(2 downto 0) := (others => '0');
    signal s_readw : std_logic := '0';
    signal s_data  : std_logic_vector(7 downto 0); 
    signal s_data_driver : std_logic_vector(7 downto 0) := (others => 'Z');
    constant clk_period : time := 20 ns;

begin

    uut: reg_8bit 
    generic map (
        faddr => PERIPHERAL_ADDR
    )
    port map (
        CLK   => s_CLK,
        addr  => s_addr,
        data  => s_data,
        readw => s_readw
    );

    -- Bidirectional bus logic: TB drives when writing, releases (Z) when reading
    s_data <= s_data_driver when s_readw = '1' else (others => 'Z');

    clk_process: process
    begin
        s_CLK <= '0';
        wait for clk_period/2;
        s_CLK <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        report "Starting Register Testbench..." severity note;
        wait for 100 ns;

        -- Test 1: Write 0xAA to Address 5
        s_addr        <= "101";
        s_data_driver <= x"AA";
        s_readw       <= '1';
        wait for clk_period;

        -- Test 2: Write 0xFF to wrong Address 0 (Should ignore)
        s_addr        <= "000";
        s_data_driver <= x"FF";
        s_readw       <= '1';
        wait for clk_period;

        -- Test 3: Read from Address 5 (Expect 0xAA)
        s_readw       <= '0';
        s_addr        <= "101";
        wait for clk_period;

        assert(s_data = x"AA") 
            report "Error: Read failed. Expected AA, got " & integer'image(to_integer(unsigned(s_data)))
            severity error;

        -- Test 4: Read from Address 0 (Should be High-Z)
        s_addr        <= "000";
        wait for clk_period;
        
        if s_data /= "ZZZZZZZZ" then
            report "Warning: Bus is not High-Z." severity warning;
        end if;

        report "Testbench Completed Successfully" severity note;
        wait;
    end process;

end sim;
