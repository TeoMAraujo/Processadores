library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Extend is
end entity;

architecture sim of tb_Extend is
    signal InstrImm : std_logic_vector(31 downto 7);
    signal ImmSrc   : std_logic_vector(2 downto 0);
    signal ImmExt   : std_logic_vector(31 downto 0);

    -- a few 25-bit instruction-field patterns (bits 31..7)
    type imm_array is array (natural range <>) of std_logic_vector(31 downto 7);
    constant imms : imm_array := (
        "1111111111100000000000000", 
        "0000000000100000000000000",
        "1010101010101010101010101"
    );

    type src_array is array (natural range <>) of std_logic_vector(2 downto 0);
    constant srcs : src_array := ( "000","001","010","011","100" );
begin

    dut: entity work.Extend
        generic map ( W => 32 )
        port map ( InstrImm => InstrImm, ImmSrc => ImmSrc, ImmExt => ImmExt );

    process
    begin
        for i in imms'range loop
            InstrImm <= imms(i);
            for k in srcs'range loop
                ImmSrc <= srcs(k);
                wait for 10 ns;
            end loop;
        end loop;
        wait;
    end process;

end architecture;
