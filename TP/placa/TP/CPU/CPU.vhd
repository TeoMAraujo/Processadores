library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPU is
port (
        OPCODE   : in    std_logic_vector(2 downto 0);
        OPERAND1 : in    std_logic_vector(7 downto 0);
        OPERAND2 : in    std_logic_vector(2 downto 0);
        CLK      : in    std_logic;
        RST      : in    std_logic; 
        OUTP     : out   std_logic_vector(7 downto 0);
        
        -- The 3 Displays
        HEX0     : out   std_logic_vector(6 downto 0);
        HEX1     : out   std_logic_vector(6 downto 0);
        HEX2     : out   std_logic_vector(6 downto 0)
    );
end CPU;

architecture structural of CPU is
    signal toADDR        : std_logic_vector(2 downto 0);
    signal toDATA        : std_logic_vector(7 downto 0);
    signal toREADW       : std_logic;
    signal OUTP_internal : std_logic_vector(7 downto 0);

    -- [NEW] Internal signal to hold the modified OPERAND1
    signal op1_masked    : std_logic_vector(7 downto 0);

begin
    OUTP <= OUTP_internal;

    -- [NEW] Logic to force bits 7-3 to '0'
    -- We take 5 zeros and stick them to the bottom 3 bits of the input
    op1_masked <= "00000" & OPERAND1(2 downto 0);

    -- Control Unit
    U_AC : entity work.arithmetic_control 
        port map (
            OPCODE   => OPCODE, 
            -- [CHANGED] We map the masked signal here instead of the raw input
            OPERAND1 => op1_masked, 
            OPERAND2 => OPERAND2,        
            CLK      => CLK, 
            RST      => not(RST), 
            OUTP     => OUTP_internal, 
            ADDR     => toADDR, 
            DATA     => toDATA, 
            READW    => toREADW
        );

    -- Memory
    U_REG : entity work.barramento
        port map (
            CLK   => CLK, 
            RST   => not(RST), 
            addr  => toADDR, 
            data  => toDATA, 
            readw => toREADW
        );

    -- Single Display Driver
    U_DISPLAY : entity work.decimal_display_driver
        port map (
            val_in => OUTP_internal, 
            hex0   => HEX0,
            hex1   => HEX1,
            hex2   => HEX2
        );

end structural;