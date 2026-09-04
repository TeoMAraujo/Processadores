library ieee; 
use ieee.std_logic_1164.all;

entity Demux_1x2 is
     generic (
        W : positive := 1
    );
    port(  
        A      : in std_logic_vector(W-1 downto 0);
        S      : in std_logic;
        Y0, Y1 : out std_logic_vector(W-1 downto 0)  
    );
end Demux_1x2;

architecture data_flow of Demux_1x2 is
begin
    Y0 <= A when S = '0' else (others => '0');
    Y1 <= A when S = '1' else (others => '0');
end data_flow;
