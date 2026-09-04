library ieee;
use ieee.std_logic_1164.all;

entity tb_comparator is
end entity tb_comparator;

architecture tb_arch of tb_comparator is

    -- Component Declaration
    component comparator
        generic (
            W : positive := 1
        );
        port (
            A     : in  std_logic_vector(W-1 downto 0);
            B     : in  std_logic_vector(W-1 downto 0);
            equal : out std_logic
        );
    end component;

    -- Signals
    signal s_A     : std_logic_vector(3 downto 0) := (others => '0');
    signal s_B     : std_logic_vector(3 downto 0) := (others => '0');
    signal s_equal : std_logic;

begin

    -- Device Under Test (DUT) Instantiation
    DUT : comparator
        generic map (
            W => 4  -- Setting width to 4 bits
        )
        port map (
            A     => s_A,
            B     => s_B,
            equal => s_equal
        );

    -- Stimulus Process
    stim_proc : process
    begin
        -- Case 1: Equal (0101 == 0101) -> Expect equal = '1'
        s_A <= "0101";
        s_B <= "0101";
        wait for 10 ns;

        -- Case 2: Not Equal (0101 != 1010) -> Expect equal = '0'
        s_A <= "0101";
        s_B <= "1010";
        wait for 10 ns;

        -- Case 3: Equal (1111 == 1111) -> Expect equal = '1'
        s_A <= "1111";
        s_B <= "1111";
        wait for 10 ns;

        -- Case 4: Not Equal (1000 != 0000) -> Expect equal = '0'
        s_A <= "1000";
        s_B <= "0000";
        wait for 10 ns;

        -- Case 5: Equal (0000 == 0000) -> Expect equal = '1'
        s_A <= "0000";
        s_B <= "0000";
        wait for 10 ns;

        -- Stop simulation
        wait;
    end process;

end architecture tb_arch;