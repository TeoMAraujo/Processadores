library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Required for arithmetic comparisons

entity tb_CPU is
    -- Testbench has no ports
end tb_CPU;

architecture Behavioral of tb_CPU is

    -- 1. COMPONENT DECLARATION
    -- Matches your CPU entity with Display Ports
    component CPU
        port (
            OPCODE   : in  std_logic_vector(2 downto 0);
            OPERAND1 : in  std_logic_vector(7 downto 0);
            OPERAND2 : in  std_logic_vector(2 downto 0);
            CLK      : in  std_logic;
            RST      : in  std_logic;
            OUTP     : out std_logic_vector(7 downto 0);
            HEX0     : out std_logic_vector(6 downto 0);
            HEX1     : out std_logic_vector(6 downto 0);
            HEX2     : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Inputs
    signal OPCODE   : std_logic_vector(2 downto 0) := (others => '0');
    signal OPERAND1 : std_logic_vector(7 downto 0) := (others => '0');
    signal OPERAND2 : std_logic_vector(2 downto 0) := (others => '0');
    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '0';

    -- Outputs
    signal OUTP     : std_logic_vector(7 downto 0);
    signal HEX0     : std_logic_vector(6 downto 0);
    signal HEX1     : std_logic_vector(6 downto 0);
    signal HEX2     : std_logic_vector(6 downto 0);

    -- Clock period definitions
    constant CLK_period : time := 10 ns;

begin

    -- 2. PORT MAPPING
    uut: CPU port map (
        OPCODE   => OPCODE,
        OPERAND1 => OPERAND1,
        OPERAND2 => OPERAND2,
        CLK      => CLK,
        RST      => RST,
        OUTP     => OUTP,
        HEX0     => HEX0,
        HEX1     => HEX1,
        HEX2     => HEX2
    );

    -- Clock Generation Process
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin		
        -- =========================================================
        -- RESET SEQUENCE
        -- =========================================================
        report "--- RESETTING ---";
        RST <= '1';
        wait for CLK_period * 4; 
        RST <= '0';
        wait for CLK_period;

        report "--- STARTING SIMULATION ---";

        -- =========================================================
        -- PHASE 1: INITIALIZATION (WRITE)
        -- =========================================================
        
        -- Store 7 into Address 1
        -- (Value is 7 because CPU masks input to 3 bits)
        OPCODE   <= "000"; 
        OPERAND1 <= "00000111"; -- Data: 7
        OPERAND2 <= "001";      -- Addr: 1
        wait for CLK_period * 2; 
        
        -- Store 5 into Address 2
        OPCODE   <= "000"; 
        OPERAND1 <= "00000101"; -- Data: 5
        OPERAND2 <= "010";      -- Addr: 2
        wait for CLK_period * 2; 


        -- =========================================================
        -- PHASE 2: EXECUTION (TESTING ALL OPCODES)
        -- Note: OPERAND1 acts as the "Address to Read" here
        -- =========================================================

        -- TEST OPCODE 001
        OPCODE   <= "001"; 
        OPERAND1 <= "00000001"; -- Read Address 1
        OPERAND2 <= "010";      
        wait for CLK_period * 2;
        
        if OUTP /= "UUUUUUUU" then
            assert unsigned(OUTP) = 7 report "Error: Opcode 001 failed" severity note;
        end if;

        -- TEST OPCODE 010
        OPCODE   <= "010"; 
        OPERAND1 <= "00000001"; 
        wait for CLK_period * 2;
        
        if OUTP /= "UUUUUUUU" then
            assert unsigned(OUTP) = 7 report "Error: Opcode 010 failed" severity note;
        end if;

        -- TEST OPCODE 011
        OPCODE   <= "011"; 
        OPERAND1 <= "00000001"; 
        wait for CLK_period * 2;
        
        if OUTP /= "UUUUUUUU" then
            assert unsigned(OUTP) = 7 report "Error: Opcode 011 failed" severity note;
        end if;

        -- TEST OPCODE 100
        OPCODE   <= "100"; 
        OPERAND1 <= "00000001"; 
        wait for CLK_period * 2;
        
        if OUTP /= "UUUUUUUU" then
            assert unsigned(OUTP) = 7 report "Error: Opcode 100 failed" severity note;
        end if;

        -- TEST OPCODE 101
        OPCODE   <= "101"; 
        OPERAND1 <= "00000001"; 
        wait for CLK_period * 2;
        
        if OUTP /= "UUUUUUUU" then
            assert unsigned(OUTP) = 7 report "Error: Opcode 101 failed" severity note;
        end if;

        -- TEST OPCODE 110
        OPCODE   <= "110"; 
        OPERAND1 <= "00000001"; 
        wait for CLK_period * 2;
        
        if OUTP /= "UUUUUUUU" then
            assert unsigned(OUTP) = 7 report "Error: Opcode 110 failed" severity note;
        end if;

        -- TEST OPCODE 111
        OPCODE   <= "111"; 
        OPERAND1 <= "00000001"; 
        wait for CLK_period * 2;
        
        if OUTP /= "UUUUUUUU" then
            assert unsigned(OUTP) = 7 report "Error: Opcode 111 failed" severity note;
        end if;

        report "--- SIMULATION SUCCESS ---";
        wait;
    end process;

end Behavioral;