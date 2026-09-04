library IEEE;
use IEEE.std_logic_1164.all;

entity D_EN_flip_flop is
    generic( W : positive := 1 );
    port(    
        D   : in  std_logic_vector(W-1 downto 0);
        CLK : in  std_logic;
        RST : in  std_logic; 
        EN  : in  std_logic;
        Q   : out std_logic_vector(W-1 downto 0);
        Qn  : out std_logic_vector(W-1 downto 0) 
    );
end D_EN_flip_flop;

architecture behavioral of D_EN_flip_flop is
    signal internal_Q : std_logic_vector(W-1 downto 0) := (others => '0');
begin
    
    process (CLK, RST)
    begin
        if RST = '1' then
            internal_Q <= (others => '0'); 
        elsif rising_edge(CLK) then 
            if EN = '1' then
                internal_Q <= D;
            end if;
        end if;
    end process;
    
    Q  <= internal_Q;
    Qn <= not internal_Q;

end architecture behavioral;