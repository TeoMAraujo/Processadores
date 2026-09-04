library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_barramento is
end tb_barramento;

architecture behavior of tb_barramento is

    component barramento
        port (
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
    signal data  : std_logic_vector(7 downto 0);
    signal readw : std_logic := '0';

    signal tb_data_driver : std_logic_vector(7 downto 0) := (others => 'Z');
    constant CLK_period   : time := 10 ns;

begin

    uut: barramento port map (
          CLK   => CLK,
          RST   => RST,
          addr  => addr,
          data  => data,
          readw => readw
        );

    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    data <= tb_data_driver when readw = '0' else (others => 'Z');

    stim_proc: process
        variable i : integer;
    begin		
        RST <= '1';
        wait for CLK_period*2;
        RST <= '0';
        wait for CLK_period;

        readw <= '0'; 
        
        for i in 0 to 7 loop
            addr <= std_logic_vector(to_unsigned(i, 3));
            tb_data_driver <= std_logic_vector(to_unsigned(i + 10, 8)); 
            wait for CLK_period;
        end loop;

        tb_data_driver <= (others => 'Z');
        
        readw <= '1';

        for i in 0 to 7 loop
            addr <= std_logic_vector(to_unsigned(i, 3));
            wait for CLK_period; 
        end loop;

        wait;
    end process;

end behavior;