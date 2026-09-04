library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    generic (
        W : positive := 1
    );
    port (
        A     : in  std_logic_vector(W - 1 downto 0);
        B     : in  std_logic_vector(W - 1 downto 0);
        equal : out std_logic
    );
end entity comparator;

architecture data_flow of comparator is
begin
    equal <= '1' when A = B else '0';
end architecture data_flow;
