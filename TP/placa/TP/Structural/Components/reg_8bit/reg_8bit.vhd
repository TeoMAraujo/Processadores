library IEEE;
use IEEE.std_logic_1164.all;

entity reg_8bit is
    generic(
        faddr: std_logic_vector(2 downto 0) := "000"
    );
    port(
        CLK   : in    std_logic;
        RST   : in    std_logic; 
        addr  : in    std_logic_vector(2 downto 0);
        data  : inout std_logic_vector(7 downto 0);
        readw : in    std_logic
    );
end reg_8bit;

architecture structural of reg_8bit is

    component D_flip_flop is
        generic( W : positive := 1 );
        port(   
            D     : in  std_logic_vector(W-1 downto 0);
            CLK   : in  std_logic;
            RST   : in  std_logic;
            Q, Qn : out std_logic_vector(W-1 downto 0) 
        );
    end component;

    signal stored_q     : std_logic_vector(7 downto 0);
    signal next_d       : std_logic_vector(7 downto 0);
    signal eq_addr      : std_logic;
    signal write_enable : std_logic;

begin

    eq_addr <= '1' when addr = faddr else '0';
    write_enable <= '1' when (readw = '1' and eq_addr = '1') else '0';

    process (write_enable, data, stored_q)
    begin
        if write_enable = '1' then
            next_d <= data;      
        else
            next_d <= stored_q; 
        end if;
    end process;

    my_storage_element : D_flip_flop
    generic map ( W => 8 )
    port map (
        CLK => CLK,
        RST => RST,
        D   => next_d,     
        Q   => stored_q,
        Qn  => open
    );
    
    -- Tri-state buffer 
    data <= stored_q when (readw = '0' and eq_addr = '1') else (others => 'Z');

end structural;
