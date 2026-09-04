library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity InstructionMemory is
    generic (
        W         : positive := 32;
        ADDR_W    : positive := 10
    );
    port (
        PC          : in  std_logic_vector(W-1 downto 0);
        instruction : out std_logic_vector(W-1 downto 0)
    );
end InstructionMemory;

architecture behavioral of InstructionMemory is
    type rom_t is array (0 to 2**ADDR_W-1) of std_logic_vector(W-1 downto 0);
    
    impure function init_rom(filename : string) return rom_t is
        file     f    : text;
        variable l    : line;
        variable word : std_logic_vector(W-1 downto 0);
        variable r    : rom_t := (others => (others => '0'));
        variable i    : integer := 0;
    begin
        file_open(f, filename, read_mode);
        while not endfile(f) and i < 2**ADDR_W loop
            readline(f, l); 
            hread(l, word);
            r(i) := word;
            i := i + 1;
        end loop;
        file_close(f);
        return r;
    end function;

    signal rom : rom_t := init_rom("../c/program.hex");
begin
    
    instruction <= ROM(to_integer(unsigned(PC(ADDR_W-1 downto 2))));

end behavioral;
