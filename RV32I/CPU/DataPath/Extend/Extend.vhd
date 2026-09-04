library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Extend is
    generic(
        W : integer := 32
    );
    Port (
        InstrImm : in  STD_LOGIC_VECTOR(31 downto 7);
        ImmSrc   : in  STD_LOGIC_VECTOR(2 downto 0);
        ImmExt   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Extend;

architecture Behavioral of Extend is
begin
    process (InstrImm, ImmSrc)
    begin
        case ImmSrc is
            when "000" => 
                ImmExt <= (31 downto 11 => InstrImm(31)) & InstrImm(30 downto 20); -- I-Type
            when "001" => 
                ImmExt <= (31 downto 11 => InstrImm(31)) & InstrImm(30 downto 25) & InstrImm(11 downto 7); -- S-Type
            when "010" => 
                ImmExt <= (31 downto 12 => InstrImm(31)) & InstrImm(7) & InstrImm(30 downto 25) & InstrImm(11 downto 8) & '0'; -- B-Type
            when "011" => 
                ImmExt <= (31 downto 20 => InstrImm(31)) & InstrImm(19 downto 12) & InstrImm(20) & InstrImm(30 downto 21) & '0';  -- J-Type
            when "100" => 
                ImmExt <= InstrImm(31 downto 12) & "000000000000"; -- U-Type
            when others =>
                ImmExt <= (others => '0'); 
        end case;
    end process;
end Behavioral;
