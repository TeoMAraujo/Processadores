library IEEE;
use IEEE.STD_LOGIC_1164.ALL;    

entity CPU is
port (
        OPCODE                     : in    std_logic_vector(2 downto 0);
        OPERAND1                   : in    std_logic_vector(7 downto 0);
        OPERAND2                   : in    std_logic_vector(2 downto 0);
        CLK                        : in    std_logic;
        RST                        : in    std_logic; 
        OUTP                       : out   std_logic_vector(7 downto 0)
    );
end CPU;

architecture structural of CPU is
    signal toADDR   : std_logic_vector(2 downto 0);
    signal toDATA   : std_logic_vector(7 downto 0);
    signal toREADW  : std_logic;
begin
    U_AC : entity work.arithmetic_control 
        port map (
            OPCODE   => OPCODE,
            OPERAND1 => OPERAND1,        
            OPERAND2 => OPERAND2,       
            CLK      => CLK, 
            RST      => RST,    
            OUTP     => OUTP,  
            ADDR     => toADDR,
            DATA     => toDATA,
            READW    => toREADW
        );

    U_REG : entity work.barramento
        port map (
            CLK   => CLK,
            RST   => RST, 
            addr  => toADDR,
            data  => toDATA,
            readw => toREADW
        );
end structural;
