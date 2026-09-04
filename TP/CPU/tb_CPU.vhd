library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_CPU is
    -- Testbench has no ports
end tb_CPU;

architecture Behavioral of tb_CPU is

    component CPU
        port (
            OPCODE   : in  std_logic_vector(2 downto 0);
            OPERAND1 : in  std_logic_vector(7 downto 0);
            OPERAND2 : in  std_logic_vector(2 downto 0);
            CLK      : in  std_logic;
            RST      : in  std_logic;
            OUTP     : out std_logic_vector(7 downto 0)
        );
    end component;

    signal OPCODE   : std_logic_vector(2 downto 0) := (others => '0');
    signal OPERAND1 : std_logic_vector(7 downto 0) := (others => '0');
    signal OPERAND2 : std_logic_vector(2 downto 0) := (others => '0');
    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '0';
    signal OUTP     : std_logic_vector(7 downto 0);

    constant CLK_period : time := 10 ns;

begin

    uut: CPU port map (
        OPCODE   => OPCODE,
        OPERAND1 => OPERAND1,
        OPERAND2 => OPERAND2,
        CLK      => CLK,
        RST      => RST,
        OUTP     => OUTP
    );

    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    stim_proc: process
    begin		
        RST <= '1';
        wait for CLK_period * 2;
        RST <= '0';
        wait for CLK_period;

        report "--- STARTING SIMULATION ---";

        -- =========================================================
        -- PHASE 1: INITIALIZATION (WRITE MODE)
        -- Rule: For Opcode 000, ADDR comes from OPERAND2
        -- =========================================================
        
        -- Store 15 into Address 1
        OPCODE   <= "000"; 
        OPERAND1 <= std_logic_vector(to_unsigned(15, 8)); -- Data
        OPERAND2 <= "001";                                -- Address Port for Writes
        wait for CLK_period* 2; 
        
        -- Store 5 into Address 2
        OPCODE   <= "000"; 
        OPERAND1 <= std_logic_vector(to_unsigned(5, 8));  -- Data
        OPERAND2 <= "010";                                -- Address Port for Writes
        wait for CLK_period* 2; 


        -- =========================================================
        -- PHASE 2: EXECUTION (READ/ALU MODE)
        -- Rule: For Opcodes != 000, ADDR comes from OPERAND1
        -- =========================================================

        -- 1. LOAD from Address 1 (Value 15)
        OPCODE   <= "001"; 
        OPERAND1 <= "00000001"; -- Address Port for Reads (Must use Op1!)
        OPERAND2 <= "010";      -- Op2 is unused during reads
        wait for CLK_period;
        
        wait for CLK_period; 
        assert unsigned(OUTP) = 15 report "Error: LOAD failed." severity note;
			
		 

        OPCODE   <= "010"; 
        OPERAND1 <= "00000001"; -- Address Port for Reads (Must use Op1!)
        OPERAND2 <= "010";      -- Op2 is unused during reads
        wait for CLK_period;
        
        wait for CLK_period; 
        assert unsigned(OUTP) = 15 report "Error: LOAD failed." severity note;	
			
			
        OPCODE   <= "011"; 
        OPERAND1 <= "00000001"; -- Address Port for Reads (Must use Op1!)
        OPERAND2 <= "010";      -- Op2 is unused during reads
        wait for CLK_period;
        
        wait for CLK_period; 
        assert unsigned(OUTP) = 15 report "Error: LOAD failed." severity note;
		  
		  
        OPCODE   <= "100"; 
        OPERAND1 <= "00000001"; -- Address Port for Reads (Must use Op1!)
        OPERAND2 <= "010";      -- Op2 is unused during reads
        wait for CLK_period;
        
        wait for CLK_period; 
        assert unsigned(OUTP) = 15 report "Error: LOAD failed." severity note;
		  
		  
        OPCODE   <= "101"; 
        OPERAND1 <= "00000001"; -- Address Port for Reads (Must use Op1!)
        OPERAND2 <= "010";      -- Op2 is unused during reads
        wait for CLK_period;
        
        wait for CLK_period; 
        assert unsigned(OUTP) = 15 report "Error: LOAD failed." severity note;
		  
		  
        OPCODE   <= "111"; 
        OPERAND1 <= "00000001"; -- Address Port for Reads (Must use Op1!)
        OPERAND2 <= "010";      -- Op2 is unused during reads
        wait for CLK_period;
        
        wait for CLK_period; 
        assert unsigned(OUTP) = 15 report "Error: LOAD failed." severity note;
		  
		  
        report "--- SIMULATION SUCCESS ---";
        wait;
    end process;

end Behavioral;