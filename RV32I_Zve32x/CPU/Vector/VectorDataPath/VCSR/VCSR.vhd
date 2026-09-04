library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VCSR is
    generic (
        W   : integer := 32;
        CSR : integer := 12
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        ADDR     : in std_logic_vector(CSR - 1 downto 0);
        VLin     : in std_logic_vector(W - 1 downto 0);
        Vtypein  : in std_logic_vector(W - 1 downto 0);

        VLout    : out std_logic_vector(W - 1 downto 0);
        Vtypeout : out std_logic_vector(W - 1 downto 0);

        VtypeE : in std_logic;
        VLE    : in std_logic
    );
end entity VCSR;

architecture rtl of VCSR is
    signal VTYPE : std_logic_vector(W - 1 downto 0);
    signal VL    : std_logic_vector(W - 1 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                VTYPE <= (others => '0');
                VL    <= (others => '0');
            elsif std_logic_vector'(VtypeE & VLE) = "11" then
                VTYPE <= Vtypein;
                VL    <= VLin;
            elsif std_logic_vector'(VtypeE & VLE) = "10" then -- o caso de 01 não é contemplado
                VTYPE <= Vtypein;
                VL <= VL;
            else 
                VTYPE <= VTYPE; --explicito
                VL <=VL;
            end if;
        end if;
    end process;

    VLout    <= VL;
    Vtypeout <= VTYPE;

end architecture rtl;
