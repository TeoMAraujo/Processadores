library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MiniDecoder is
    Port (
        funct3      : in  STD_LOGIC_VECTOR(2 downto 0);
        funct7_5    : in  STD_LOGIC;
        ALUOp       : in  STD_LOGIC;
        isRtype     : in  STD_LOGIC;
        ALUControl  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end MiniDecoder;

architecture behavourial of MiniDecoder is
begin
    process(funct3, ALUOp, funct7_5, isRtype) begin
        if ALUOp = '1' then
            case funct3 is
                when "000" =>
                    if isRtype = '1' and funct7_5 = '1' then -- treat immediates
                        ALUControl <= "0001"; -- sub
                    else
                        ALUControl <= "0000"; --add
                    end if;
                when "001" => ALUControl <= "0010"; --sll
                when "010" => ALUControl <= "1000"; --slt
                when "011" => ALUControl <= "1001"; --sltu
                when "100" => ALUControl <= "0111"; --xor
                when "101" =>
                    if funct7_5 = '1' then
                        ALUControl <= "0100"; --sra
                    else
                        ALUControl <= "0011"; --srl
                    end if;
                when "110" => ALUControl <= "0110"; --or
                when "111" => ALUControl <= "0101"; --and
                when others => ALUControl <= "0000"; -- against latching
            end case;  
        else
            ALUControl <= "0000";
        end if;
    end process;
end architecture behavourial;
