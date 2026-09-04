library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end ALU_tb;

architecture behavior of ALU_tb is

    component ALU
    generic( W : positive := 8 );
    port(
        A, B   : in  std_logic_vector(W-1 downto 0);
        opcode : in  std_logic_vector(2 downto 0);
        Y      : out std_logic_vector(W-1 downto 0)
    );
    end component;

    constant W_tb : positive := 8;
    signal s_A      : std_logic_vector(W_tb-1 downto 0) := (others => '0');
    signal s_B      : std_logic_vector(W_tb-1 downto 0) := (others => '0');
    signal s_opcode : std_logic_vector(2 downto 0) := (others => '0');
    signal s_Y      : std_logic_vector(W_tb-1 downto 0);

begin

    uut: ALU generic map (W => W_tb)
    port map (A => s_A, B => s_B, opcode => s_opcode, Y => s_Y);

    stim_proc: process
    begin
        report "Starting Simulation..." severity note;

        s_A <= std_logic_vector(to_signed(10, W_tb));
        s_B <= std_logic_vector(to_signed(-5, W_tb));
        
        s_opcode <= "000";
        wait for 10 ns;
        assert(signed(s_Y) = -5) report "Error: 000 failed" severity error;

        s_opcode <= "001"; 
        wait for 10 ns;
        assert(signed(s_Y) = -5) report "Error: 001 failed" severity error;

        s_opcode <= "010";
        wait for 10 ns;
        assert(s_Y = not s_A) report "Error: 010 failed" severity error;

        s_opcode <= "011";
        wait for 10 ns;
        assert(s_Y = not s_A) report "Error: 010 failed" severity error;
		  
        s_opcode <= "100";
        wait for 10 ns;
        assert(signed(s_Y) = 5) report "Error: Add failed" severity error;

        s_opcode <= "101";
        wait for 10 ns;
        assert(signed(s_Y) = 15) report "Error: Sub failed" severity error;

        s_opcode <= "110";
        wait for 10 ns;
        assert(signed(s_Y) = 20) report "Error: Shift Left failed" severity error;

        s_opcode <= "111";
        wait for 10 ns;
        assert(signed(s_Y) = 5) report "Error: Shift Right failed" severity error;

        report "Success! All tests passed." severity note;
        wait;
    end process;

end behavior;
