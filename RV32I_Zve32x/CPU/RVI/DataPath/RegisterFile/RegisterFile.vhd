library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package RegFile_pkg is
    type reg_array is array (natural range <>) of std_logic_vector; -- tb_TOP
end package RegFile_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.RegFile_pkg.all;
entity RegisterFile is
    generic (
        W    : positive := 32;
        ADDR : positive := 5
    );
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        WE3 : in  STD_LOGIC;
        A1  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
        A2  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
        A3  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
        WD3 : in  STD_LOGIC_VECTOR(W-1 downto 0);
        RD1 : out STD_LOGIC_VECTOR(W-1 downto 0);
        RD2 : out STD_LOGIC_VECTOR(W-1 downto 0)
    );
end RegisterFile;
architecture Behavioral of RegisterFile is
    signal matrix : reg_array(2**ADDR - 1 downto 0)(W-1 downto 0)
                  := (2 => std_logic_vector(to_unsigned(512, 2**ADDR)), -- inicializa o sp mas poderia variar conforme tamanho da stack
                              others => (others => '0'));
begin
    process (clk)
    begin
    if rising_edge(clk) then
        if rst = '1' then
            matrix <= (others => (others => '0'));
        elsif WE3 = '1' and unsigned(A3) /= 0 then --x0
             matrix(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;
    RD1 <= matrix(to_integer(unsigned(A1)));
    RD2 <= matrix(to_integer(unsigned(A2)));
end Behavioral;
