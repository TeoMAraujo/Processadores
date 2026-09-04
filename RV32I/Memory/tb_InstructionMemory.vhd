library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_InstructionMemory is
end tb_InstructionMemory;

architecture sim of tb_InstructionMemory is

    constant W      : positive := 32;
    constant ADDR_W : positive := 10;

    signal PC          : std_logic_vector(W-1 downto 0) := (others => '0');
    signal instruction : std_logic_vector(W-1 downto 0);

begin
    dut : entity work.InstructionMemory
        generic map (
            W      => W,
            ADDR_W => ADDR_W
        )
        port map (
            PC          => PC,
            instruction => instruction
        );

    stim : process
    begin
        for i in 0 to 9 loop
            PC <= std_logic_vector(to_unsigned(i * 4, W));
            wait for 10 ns;
            report "PC=" & integer'image(i*4) &
                   "  instruction=" & to_hstring(instruction)
                severity note;
        end loop;

        report "Fim da simulacao" severity note;
        wait; 
    end process;

end sim;
