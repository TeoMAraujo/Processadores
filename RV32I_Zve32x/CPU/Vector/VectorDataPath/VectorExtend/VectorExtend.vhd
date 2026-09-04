library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VectorExtend is
    generic(
        W : integer := 32
    );
    port (
        InstrImm : in  std_logic_vector(31 downto 7);
        ImmSrcV  : in  std_logic;
        ImmExt   : out std_logic_vector(W-1 downto 0)
    );
end entity VectorExtend;

architecture Behavioral of VectorExtend is
begin
    process(InstrImm, ImmSrcV)
    begin
        case ImmSrcV is

            when '0' =>
                -- vsetvli: zimm[10:0] = Instr(30 downto 20), zero-extended
                ImmExt <= (W-1 downto 11 => '0') & InstrImm(30 downto 20);

            when '1' =>
                -- vsetivli: zimm[9:0] = Instr(29 downto 20), zero-extended
                -- (Instr(30) is the constant '1' of the "11" selector, excluded)
                ImmExt <= (W-1 downto 10 => '0') & InstrImm(29 downto 20);

            when others =>
                ImmExt <= (others => '0');
        end case;
    end process;
end architecture Behavioral;
