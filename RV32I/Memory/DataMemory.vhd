library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity DataMemory is
    generic (
        W        : positive := 32;
        NUM_REGS : integer  := 10
    );
    Port (
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        WE     : in  STD_LOGIC;
        funct3 : in  STD_LOGIC_VECTOR(2 downto 0);
        ADDR   : in  STD_LOGIC_VECTOR(NUM_REGS-1 downto 0);
        WD     : in  STD_LOGIC_VECTOR(W - 1 downto 0);
        RD     : out STD_LOGIC_VECTOR(W - 1 downto 0)
    );
end DataMemory;

architecture Behavioral of DataMemory is
    type array_t is array (0 to 2**NUM_REGS - 1+4) of std_logic_vector(7 downto 0);
    signal mem : array_t := (others => (others => '0'));

    signal RD_bus1 : STD_LOGIC_VECTOR(7 downto 0);
    signal RD_bus2 : STD_LOGIC_VECTOR(7 downto 0);
    signal RD_bus3 : STD_LOGIC_VECTOR(7 downto 0);
    signal RD_bus4 : STD_LOGIC_VECTOR(7 downto 0);
    signal word_d  : STD_LOGIC_VECTOR(W-1 downto 0);
    signal half_d  : STD_LOGIC_VECTOR(15 downto 0);
    signal byte_d  : STD_LOGIC_VECTOR(7 downto 0);
begin

    -- write
    process (clk)
        variable a : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mem <= (others => (others => '0'));
            elsif WE = '1' then
                a := to_integer(unsigned(ADDR));
                case funct3 is
                    when "000" =>                         -- sb
                        mem(a)     <= WD(7  downto 0);
                    when "001" =>                         -- sh
                        mem(a)     <= WD(7  downto 0);
                        mem(a + 1) <= WD(15 downto 8);
                    when "010" =>                         -- sw
                        mem(a)     <= WD(7  downto 0);
                        mem(a + 1) <= WD(15 downto 8);
                        mem(a + 2) <= WD(23 downto 16);
                        mem(a + 3) <= WD(31 downto 24);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    -- Load
    RD_bus1 <= mem(to_integer(unsigned(ADDR)));
    RD_bus2 <= mem(to_integer(unsigned(ADDR)) + 1);
    RD_bus3 <= mem(to_integer(unsigned(ADDR)) + 2);
    RD_bus4 <= mem(to_integer(unsigned(ADDR)) + 3);

    word_d <= RD_bus4 & RD_bus3 & RD_bus2 & RD_bus1;
    half_d <= RD_bus2 & RD_bus1;
    byte_d <= RD_bus1;

    with funct3 select RD <=
        std_logic_vector(resize(signed(byte_d),   W)) when "000",  -- lb
        std_logic_vector(resize(signed(half_d),   W)) when "001",  -- lh
        word_d                                        when "010",  -- lw
        std_logic_vector(resize(unsigned(byte_d), W)) when "100",  -- lbu
        std_logic_vector(resize(unsigned(half_d), W)) when "101",  -- lhu
        word_d                                        when others;

end Behavioral;
