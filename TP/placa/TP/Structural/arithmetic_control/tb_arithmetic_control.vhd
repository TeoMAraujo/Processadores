library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_arithmetic_control is
    -- Testbench has no ports
end tb_arithmetic_control;

architecture behavior of tb_arithmetic_control is

    -- Component Declaration for the Unit Under Test (UUT)
    component arithmetic_control
    port(
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

    -- Inputs
    signal tb_OPCODE   : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_OPERAND1 : std_logic_vector(7 downto 0) := (others => '0');
    signal tb_OPERAND2 : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_CLK      : std_logic := '0';
    signal tb_RST      : std_logic := '0';

    -- Outputs
    signal tb_OUTP     : std_logic_vector(7 downto 0);
    signal tb_ADDR     : std_logic_vector(2 downto 0);
    signal tb_READW    : std_logic;

    -- Bidirectional Bus
    signal tb_DATA     : std_logic_vector(7 downto 0);

    -- Simulation Signals
    signal mem_data_to_drive : std_logic_vector(7 downto 0) := (others => '0');
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: arithmetic_control port map (
        OPCODE   => tb_OPCODE,
        OPERAND1 => tb_OPERAND1,
        OPERAND2 => tb_OPERAND2,
        CLK      => tb_CLK,
        RST      => tb_RST,
        OUTP     => tb_OUTP,
        ADDR     => tb_ADDR,
        DATA     => tb_DATA,
        READW    => tb_READW
    );

    -- Clock Process definitions
    clk_process : process
    begin
        tb_CLK <= '0';
        wait for CLK_PERIOD/2;
        tb_CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- =========================================================
    -- MEMORY BUS MODEL
    -- =========================================================
    -- This process simulates the external RAM. 
    -- If the CPU (UUT) sets READW = '0' (Read Mode), the Testbench drives the bus.
    -- If the CPU sets READW = '1' (Write Mode), the Testbench goes High-Z.
    mem_proc: process(tb_READW, mem_data_to_drive)
    begin
        if tb_READW = '0' then
            tb_DATA <= mem_data_to_drive;
        else
            tb_DATA <= (others => 'Z');
        end if;
    end process;

    -- =========================================================
    -- STIMULUS PROCESS
    -- =========================================================
    stim_proc: process
    begin
        -- 1. Reset the system
        tb_RST <= '1';
        wait for CLK_PERIOD * 2;
        tb_RST <= '0';
        wait for CLK_PERIOD;

        ------------------------------------------------------------
        -- SETUP: 
        -- Based on your structural code, there is a 3-4 cycle pipeline delay.
        -- Inputs at T0 -> Result at Output at T3/T4.
        ------------------------------------------------------------

        -- TEST 1: LOAD / PASS B (Opcode "001")
        -- Let's pretend "001" passes the memory data to the output.
        report "TEST 1: LOAD value from Memory";
        tb_OPCODE <= "001"; 
        mem_data_to_drive <= x"0A"; -- Value 10
        
        -- Hold input for 1 cycle to latch into Stage 1
        wait for CLK_PERIOD; 
        
        -- Wait for Pipeline propagation (Stage 2 -> 3 -> 4)
        wait for CLK_PERIOD * 3; 
        
        assert tb_OUTP = x"0A" 
            report "Error: Expected x0A (10), got " & integer'image(to_integer(unsigned(tb_OUTP)))
            severity error;


        -- TEST 2: ADD (Opcode "100")
        -- Previous Output (Accumulator?): 10
        -- New Memory Value: 5
        -- Expectation: 10 + 5 = 15 (x0F)
        report "TEST 2: ADD (10 + 5)";
        tb_OPCODE <= "100";
        mem_data_to_drive <= x"05"; -- Value 5
        
        wait for CLK_PERIOD; -- Latch Input
        wait for CLK_PERIOD * 3; -- Wait for Pipeline
        
        assert tb_OUTP = x"0F" 
            report "Error: Expected x0F (15), got " & integer'image(to_integer(unsigned(tb_OUTP)))
            severity error;


        -- TEST 3: SUBTRACT (Opcode "101")
        -- Previous Output (Accumulator?): 15
        -- New Memory Value: 5
        -- Expectation: 15 - 5 = 10 (x0A)
        report "TEST 3: SUB (15 - 5)";
        tb_OPCODE <= "101";
        mem_data_to_drive <= x"05"; -- Value 5
        
        wait for CLK_PERIOD; 
        wait for CLK_PERIOD * 3; 
        
        assert tb_OUTP = x"0A" 
            report "Error: Expected x0A (10), got " & integer'image(to_integer(unsigned(tb_OUTP)))
            severity error;

        
        -- TEST 4: LOGICAL AND (Opcode "011")
        -- Previous Output: 10 (binary 0000 1010)
        -- New Memory Value: 7  (binary 0000 0111)
        -- Expectation: 10 AND 7 = 2 (binary 0000 0010)
        report "TEST 4: AND (10 & 7)";
        tb_OPCODE <= "011";
        mem_data_to_drive <= x"07"; 
        
        wait for CLK_PERIOD;
        wait for CLK_PERIOD * 3; 
        
        assert tb_OUTP = x"02" 
            report "Error: Expected x02 (2), got " & integer'image(to_integer(unsigned(tb_OUTP)))
            severity error;

        -- TEST 5: SHIFT LEFT (Opcode "110")
        -- Previous: 2
        -- Shift Left logical: 4
        report "TEST 5: SLL (2 << 1)";
        tb_OPCODE <= "110";
        -- Memory value usually ignored for shift, but we drive 0 just in case
        mem_data_to_drive <= x"00"; 
        
        wait for CLK_PERIOD;
        wait for CLK_PERIOD * 3; 
        
        assert tb_OUTP = x"04" 
            report "Error: Expected x04 (4), got " & integer'image(to_integer(unsigned(tb_OUTP)))
            severity error;


        report "Simulation Completed Successfully";
        wait;
    end process;

end behavior;