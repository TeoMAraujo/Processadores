library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic( W : positive := 8 );
    port(
        A, B   : in  std_logic_vector (W-1 downto 0);
        opcode : in  std_logic_vector (2 downto 0);
        Y      : out std_logic_vector (W-1 downto 0)
    );
end ALU;

architecture data_flow of ALU is 
begin
    process(A, B, opcode)
    begin
        case opcode is
            when "000" => Y <= B;                           -- acumulator
            when "001" => Y <= A;                           -- actually memory
            when "010" => Y <= NOT(A);                      -- NOT
            when "011" => Y <= A AND B;                     -- AND
            when "100" => Y <= std_logic_vector(signed(A) + signed(B)); -- ADD
            when "101" => Y <= std_logic_vector(signed(A) - signed(B)); -- SUB
            when "110" => Y <= std_logic_vector(shift_left(signed(B), 1)); -- sll
            when "111" => Y <= std_logic_vector(shift_right(signed(B), 1)); --srl
            when others => Y <= (others => '0');
        end case;
    end process;
end data_flow;
