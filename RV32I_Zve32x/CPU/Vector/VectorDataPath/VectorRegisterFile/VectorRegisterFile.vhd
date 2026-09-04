library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.RegFile_pkg.all;
entity VectorRegisterFile is
    generic (
        W    : positive := 128;
        ADDR : positive := 5
    );
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        
        VWE : in  STD_LOGIC;
        VM : in STD_LOGIC; -- masking

        VL    : out std_logic_vector(2**ADDR - 1 downto 0);
        Vtype : out std_logic_vector(2**ADDR - 1 downto 0);

        AV1  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
        AV2  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
        AV3  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
        VWD3 : in  STD_LOGIC_VECTOR(W-1 downto 0);
        VRD1 : out STD_LOGIC_VECTOR(W-1 downto 0);
        VRD2 : out STD_LOGIC_VECTOR(W-1 downto 0);
        V0   : out  STD_LOGIC_VECTOR(W-1 downto 0)
    );
end VectorRegisterFile;
architecture Behavioral of VectorRegisterFile is
    signal matrix : reg_array(2**ADDR - 1 downto 0)(W-1 downto 0)
              := (others => (others => '0'));
begin
    process (clk)
    begin
    if rising_edge(clk) then
        if rst = '1' then
            matrix <= (others => (others => '0'));
        elsif VWE = '1' then --x0
             matrix(to_integer(unsigned(AV3))) <= VWD3; -- considerar o vtype na vdd aq v0 e fazer logica de masking
            end if;
        end if;
    end process;
    VRD1 <= matrix(to_integer(unsigned(AV1)));
    VRD2 <= matrix(to_integer(unsigned(AV2)));
    V0 <= matrix(0); -- importante notar que NUNCA plmns ao que achei o v0 não pode ser ativo e sobreposto na mesma instrução ao menos que a proposição seja escrever o valor da mascara tenha tamanho de lmul 1 pq se tiver maior q 1 se tentasse tinha que levantar flag
    -- faltaria colocar os endereçps caso fosse endereçado para leitura por outro csr 
end Behavioral;
