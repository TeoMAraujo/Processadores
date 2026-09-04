library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_reg_8bit is
end tb_reg_8bit;

architecture behavior of tb_reg_8bit is

    component reg_8bit
        generic(
            faddr: std_logic_vector(2 downto 0) := "000"
        );
        port(
            CLK   : in    std_logic;
            RST   : in    std_logic;
            addr  : in    std_logic_vector(2 downto 0);
            data  : inout std_logic_vector(7 downto 0);
            readw : in    std_logic
        );
    end component;

    signal CLK   : std_logic := '0';
    signal RST   : std_logic := '0';
    signal addr  : std_logic_vector(2 downto 0) := (others => '0');
    signal readw : std_logic := '0';

    signal data  : std_logic_vector(7 downto 0);
    signal tb_data_drive : std_logic_vector(7 downto 0) := (others => 'Z');

    constant CLK_period : time := 10 ns;
    constant MY_ADDR : std_logic_vector(2 downto 0) := "101"; 

begin

    uut: reg_8bit
    generic map (
        faddr => MY_ADDR
    )
    port map (
        CLK   => CLK,
        RST   => RST,
        addr  => addr,
        data  => data,
        readw => readw
    );

    data <= tb_data_drive;

    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    stim_proc: process
    begin
        RST <= '1';
        tb_data_drive <= (others => 'Z');
        wait for CLK_period * 2;
        RST <= '0';
        wait for CLK_period;

        addr <= MY_ADDR;
        readw <= '1';
        tb_data_drive <= x"AA";
        wait for CLK_period;

        tb_data_drive <= (others => 'Z'); 
        readw <= '0';
        wait for CLK_period;

        addr <= MY_ADDR;
        readw <= '0';
        wait for CLK_period;
        
        assert data = x"AA" severity failure;

        addr <= "000";
        readw <= '1';
        tb_data_drive <= x"FF";
        wait for CLK_period;

        tb_data_drive <= (others => 'Z');
        addr <= MY_ADDR;
        readw <= '0';
        wait for CLK_period;

        assert data = x"AA" severity failure;

        addr <= "000";
        readw <= '0';
        wait for CLK_period;

        if data /= "ZZZZZZZZ" then
            report "Error: Bus is not High-Z" severity failure;
        end if;

        RST <= '1';
        wait for CLK_period;
        RST <= '0';
        
        addr <= MY_ADDR;
        readw <= '0';
        wait for CLK_period;
        
        assert data = x"00" severity warning;

        wait;
    end process;

end behavior;
