library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_CPU is
    -- Testbench has no ports
end tb_CPU;

architecture Behavioral of tb_CPU is

    -- Component Declaration for the Unit Under Test (UUT)
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

    -- Inputs
    signal OPCODE   : std_logic_vector(2 downto 0) := (others => '0');
    signal OPERAND1 : std_logic_vector(7 downto 0) := (others => '0');
    signal OPERAND2 : std_logic_vector(2 downto 0) := (others => '0');
    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '0';

    -- Outputs
    signal OUTP     : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant CLK_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: CPU port map (
        OPCODE   => OPCODE,
        OPERAND1 => OPERAND1,
        OPERAND2 => OPERAND2,
        CLK      => CLK,
        RST      => RST,
        OUTP     => OUTP
    );

    -- Clock process definitions
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- 1. Hold Reset
        RST <= '1';
        wait for CLK_period * 2;
        RST <= '0';
        wait for CLK_period;

        report "--- STARTING SIMULATION (CPU) ---";

        -- =========================================================
        -- PHASE 1: STORE VALUES INTO REGISTERS
        -- =========================================================
        
        -- Step 1: Write 10 to Register 1
        OPCODE   <= "000"; -- Write Opcode
        OPERAND1 <= std_logic_vector(to_unsigned(10, 8)); -- Data Value (10)
        OPERAND2 <= "001"; -- Address (1)
        wait for CLK_period; 
        
        -- Step 2: Write 6 to Register 2
        OPCODE   <= "000"; -- Write Opcode
        OPERAND1 <= std_logic_vector(to_unsigned(6, 8)); -- Data Value (6)
        OPERAND2 <= "010"; -- Address (2)
        wait for CLK_period; 

        -- Clear Pipeline (Safe Step)
        OPCODE   <= "001"; -- Load
        OPERAND1 <= (others => '0'); -- Read Reg 0 (likely 0) to clear bus
        wait for CLK_period;

        report "--- VALUES STORED (Reg1=10, Reg2=6) ---";

        -- =========================================================
        -- PHASE 2: SEQUENCE ALL OPCODES (000 to 111)
        -- =========================================================
        -- Note: The CPU is pipelined. We can issue one instruction per clock
        -- cycle. The assertions check the combinational output (OUTP) which
        -- is valid at the end of the Execute cycle (1 cycle latency).
        
        -- 1. LOAD (001): Load Register 1 (Value 10)
        OPCODE   <= "001"; 
        OPERAND1 <= "00000001"; -- Address 1
        wait for CLK_period;
        assert unsigned(OUTP) = 10 
            report "Error: LOAD failed. Expected 10, got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        -- 2. ADD (100): Add Register 2 (Value 6)
        -- Accumulator (10) + Reg2 (6) = 16
        OPCODE   <= "100";
        OPERAND1 <= "00000010"; -- Address 2
        wait for CLK_period;
        assert unsigned(OUTP) = 16 
            report "Error: ADD failed. Expected 16, got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        -- 3. SUB (101): Subtract Register 2 (Value 6)
        -- Accumulator (16) - Reg2 (6) = 10
        OPCODE   <= "101";
        OPERAND1 <= "00000010"; -- Address 2
        wait for CLK_period;
        assert unsigned(OUTP) = 10 
            report "Error: SUB failed. Expected 10, got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        -- 4. AND (011): Bitwise AND with Register 2 (Value 6)
        -- Accumulator (10 = 1010) AND Reg2 (6 = 0110) = 2 (0010)
        OPCODE   <= "011";
        OPERAND1 <= "00000010"; -- Address 2
        wait for CLK_period;
        assert unsigned(OUTP) = 2 
            report "Error: AND failed. Expected 2, got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        -- 5. NOT (010): Bitwise NOT Accumulator
        -- Accumulator (2 = 00000010) -> NOT -> (11111101 = 253)
        OPCODE   <= "010";
        OPERAND1 <= "00000000"; -- Address ignored for Unary ops
        wait for CLK_period;
        assert unsigned(OUTP) = 253 
            report "Error: NOT failed. Expected 253, got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        -- 6. SLL (110): Shift Left Logical
        -- Accumulator (253 = 11111101) << 1 = (11111010 = 250)
        OPCODE   <= "110";
        OPERAND1 <= "00000000"; 
        wait for CLK_period;
        assert unsigned(OUTP) = 250 
            report "Error: SLL failed. Expected 250, got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        -- 7. SRL (111): Shift Right Logical
        -- Accumulator (250 = 11111010) >> 1 = (01111101 = 125)
        OPCODE   <= "111";
        OPERAND1 <= "00000000"; 
        wait for CLK_period;
        assert unsigned(OUTP) = 125 
            report "Error: SRL failed. Expected 125, got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        -- 8. HOLD (000): Verify Accumulator retains value (ALU Opcode 000 = B)
        -- Accumulator should stay 125.
        -- We write dummy data (255) to a dummy address (7) to trigger Opcode 000 in Control.
        -- ALU Input A will become 255, but ALU Input B is 125. Opcode 000 selects B.
        OPCODE   <= "000";
        OPERAND1 <= "11111111"; -- Data on Bus
        OPERAND2 <= "111";      -- Address 7
        wait for CLK_period;
        assert unsigned(OUTP) = 125
            report "Error: HOLD failed. Expected 125 (Accumulator), got " & integer'image(to_integer(unsigned(OUTP))) severity error;

        report "--- SIMULATION SUCCESS: All Opcodes Verified ---";
        wait;
    end process;

end Behavioral;