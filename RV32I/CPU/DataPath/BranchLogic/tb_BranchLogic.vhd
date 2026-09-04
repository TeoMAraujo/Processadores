library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_BranchLogic is
end tb_BranchLogic;

architecture sim of tb_BranchLogic is
    constant W : integer := 32;
    signal A, B   : std_logic_vector(W-1 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal Btake  : std_logic;

    type int_array is array (natural range <>) of integer;
    constant n : int_array := (5, 3);
begin
    DUT : entity work.BranchLogic
        generic map (W => W)
        port map (A => A, B => B, funct3 => funct3, Btake => Btake);

    stim : process
    begin
        A <= std_logic_vector(to_signed( n(0), W));
        B <= std_logic_vector(to_signed( n(1), W));
        for i in 0 to 7 loop
            funct3 <= std_logic_vector(to_unsigned(i, 3));
            wait for 10 ns;
        end loop;

        A <= std_logic_vector(to_signed( n(0), W));
        B <= std_logic_vector(to_signed(-n(1), W));
        for i in 0 to 7 loop
            funct3 <= std_logic_vector(to_unsigned(i, 3));
            wait for 10 ns;
        end loop;

        -- -+  (A negative, B positive)
        A <= std_logic_vector(to_signed(-n(0), W));
        B <= std_logic_vector(to_signed( n(1), W));
        for i in 0 to 7 loop
            funct3 <= std_logic_vector(to_unsigned(i, 3));
            wait for 10 ns;
        end loop;

        -- --  (A negative, B negative)
        A <= std_logic_vector(to_signed(-n(0), W));
        B <= std_logic_vector(to_signed(-n(1), W));
        for i in 0 to 7 loop
            funct3 <= std_logic_vector(to_unsigned(i, 3));
            wait for 10 ns;
        end loop;
        wait;
    end process;
end sim;
