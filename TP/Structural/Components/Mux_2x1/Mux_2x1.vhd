library ieee; 
use ieee.std_logic_1164.all;

entity Mux_2x1 is
    generic (
        W : positive := 1
    );
    port(  
        A, B : in std_logic_vector(W - 1 downto 0);
        S    : in std_logic;
        Y    : out std_logic_vector(W-1 downto 0)  
    );
end Mux_2x1;

architecture data_flow of Mux_2x1 is
begin
    with S select
        Y <= A when '0',
             B when '1',
             (others => '0') when others;
end data_flow;
