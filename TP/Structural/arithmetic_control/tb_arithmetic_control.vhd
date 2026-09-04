library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_arithmetic_control is
end tb_arithmetic_control;

architecture behavior of tb_arithmetic_control is

    component arithmetic_control
        port (
            OPCODE   : in    std_logic_vector(2 downto 0);
            OPERAND1 : in    std_logic_vector(7 downto 0);
            OPERAND2 : in    std_logic_vector(2 downto 0);
            CLK      : in    std_logic;
            RST      : in    std_logic; 
            OUTP     : out   std_logic_vector(7 downto 0);
            ADDR     : out   std_logic_vector(2 downto 0);
            DATA     : inout std_logic_vector(7 downto 0);
            READW    : out   std_logic
        );
    end component;

    signal OPCODE   : std_logic_vector(2 downto 0) := (others => '0');
    signal OPERAND1 : std_logic_vector(7 downto 0) := (others => '0');
    signal OPERAND2 : std_logic_vector(2 downto 0) := (others => '0');
    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '0';

    signal DATA     : std_logic_vector(7 downto 0);

    signal OUTP     : std_logic_vector(7 downto 0);
    signal ADDR     : std_logic_vector(2 downto 0);
    signal READW    : std_logic;

    constant CLK_period : time := 10 ns;
    
    signal tb_data_driver : std_logic_vector(7 downto 0) := (others => 'Z');

begin

    uut: arithmetic_control port map (
          OPCODE   => OPCODE,
          OPERAND1 => OPERAND1,
          OPERAND2 => OPERAND2,
          CLK      => CLK,
          RST      => RST,
          OUTP     => OUTP,
          ADDR     => ADDR,
          DATA     => DATA,
          READW    => READW
        );

    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;
    
    data_bus_proc: process(READW, tb_data_driver)
    begin
        if READW = '0' then
            DATA <= tb_data_driver;
        else
            DATA <= (others => 'Z');
        end if;
    end process;

    stim_proc: process
    begin		
        RST <= '1';
        wait for CLK_period * 2;
        RST <= '0';
        wait for CLK_period;

        OPCODE <= "001"; 
        OPERAND1 <= "00000000";
        OPERAND2 <= "101"; 
        wait for CLK_period;
        
        tb_data_driver <= "00000101"; 
        wait for CLK_period * 2; 
        tb_data_driver <= (others => 'Z');

        OPCODE <= "010"; 
        OPERAND2 <= "011"; 
        wait for CLK_period;
        
        tb_data_driver <= "00000010"; 
        wait for CLK_period * 2;
        tb_data_driver <= (others => 'Z');

        OPCODE <= "100"; 
        wait for CLK_period;
        
        wait for CLK_period * 5;

        OPCODE <= "111";
        OPERAND1 <= "10101010";
        OPERAND2 <= "000";
        wait for CLK_period;
        
        wait for CLK_period * 2;

        wait;
    end process;

end behavior;