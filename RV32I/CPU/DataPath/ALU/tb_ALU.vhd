library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ALU is
end entity;

architecture sim of tb_ALU is
    constant W : integer := 32;
    signal A, B, ALUResult : std_logic_vector(W-1 downto 0);
    signal ALUControl      : std_logic_vector(3 downto 0);

    type int_array is array (natural range <>) of integer;
    constant as : int_array := ( 5, -7, 100, -1, 0 );
    constant bs : int_array := ( 3,  4, -50,  1, 9 );
begin

    dut: entity work.ALU
        generic map ( W => W )
        port map ( A => A, B => B, ALUControl => ALUControl, ALUResult => ALUResult );

    process
    begin
        for i in as'range loop
            A <= std_logic_vector(to_signed(as(i), W));
            B <= std_logic_vector(to_signed(bs(i), W));
            for k in 0 to 9 loop
                ALUControl <= std_logic_vector(to_unsigned(k, 4));
                wait for 10 ns;
            end loop;
        end loop;
        wait;
    end process;

end architecture;
