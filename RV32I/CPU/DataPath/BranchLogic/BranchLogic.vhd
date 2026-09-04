library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BranchLogic is
    generic ( W : integer := 32 );
    port (
        A, B   : in  std_logic_vector(W-1 downto 0);
        funct3 : in  std_logic_vector(2 downto 0);
        Btake  : out std_logic
    );
end BranchLogic;

architecture dataflow of BranchLogic is
begin
    Btake <= '1' when (funct3 = "000" and signed(A) = signed(B))      else
             '1' when (funct3 = "001" and signed(A) /= signed(B))     else
             '1' when (funct3 = "100" and signed(A) < signed(B))      else
             '1' when (funct3 = "101" and signed(A) >= signed(B))     else
             '1' when (funct3 = "110" and unsigned(A) < unsigned(B))  else
             '1' when (funct3 = "111" and unsigned(A) >= unsigned(B)) else
             '0';
end dataflow;
