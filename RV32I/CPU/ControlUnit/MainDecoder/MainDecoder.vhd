library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MainDecoder is
    port (
        opcode      : in  STD_LOGIC_VECTOR(6 downto 0);
        Jump        : out STD_LOGIC;
        Branch      : out STD_LOGIC;
        ALUtoPC     : out STD_LOGIC;
        ALUOp       : out STD_LOGIC;
        ResultSrc   : out STD_LOGIC_VECTOR(1 downto 0);
        MemWrite    : out STD_LOGIC;
        ALUSrc      : out STD_LOGIC;
        PCtoALU     : out STD_LOGIC;
        ImmSrc      : out STD_LOGIC_VECTOR(2 downto 0);
        RegWrite    : out STD_LOGIC;
        isRtype     : out STD_LOGIC
    );
end MainDecoder;

architecture behavioural of MainDecoder is
    signal control : std_logic_vector(12 downto 0);
begin
    process (opcode) begin
        case opcode is
            when "0000011" => control <= "1" & "000" & "0" & "1" & "0" & "01" & "0" & "0" & "0" & "0"; -- lw
            when "0100011" => control <= "0" & "001" & "0" & "1" & "1" & "00" & "0" & "0" & "0" & "0"; -- sw
            when "0110011" => control <= "1" & "000" & "0" & "0" & "0" & "00" & "0" & "1" & "0" & "0"; -- R-type
            when "0010011" => control <= "1" & "000" & "0" & "1" & "0" & "00" & "0" & "1" & "0" & "0"; -- I-type
            when "1100011" => control <= "0" & "010" & "0" & "0" & "0" & "00" & "0" & "0" & "1" & "0"; -- B-type
            when "1101111" => control <= "1" & "011" & "0" & "0" & "0" & "10" & "0" & "0" & "0" & "1"; -- jal
            when "1100111" => control <= "1" & "000" & "0" & "1" & "0" & "10" & "1" & "0" & "0" & "1"; -- jalr
            when "0110111" => control <= "1" & "100" & "0" & "1" & "0" & "11" & "0" & "0" & "0" & "0"; -- lui
            when "0010111" => control <= "1" & "100" & "1" & "1" & "0" & "00" & "0" & "0" & "0" & "0"; -- auipc
            when others    => control <= (others => '0');
        end case;
    end process;

    (RegWrite, ImmSrc(2), ImmSrc(1), ImmSrc(0), PCtoALU,
     ALUSrc, MemWrite, ResultSrc(1), ResultSrc(0), ALUtoPC,
     ALUOp,  Branch,  Jump) <= control;

    isRtype <= '1' when opcode = "0110011" else '0';
end architecture behavioural;
