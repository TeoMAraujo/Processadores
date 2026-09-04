library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all;   -- para o finish

entity tb_RegisterFile is
end entity;

architecture sim of tb_RegisterFile is
    constant W    : positive := 32;
    constant ADDR : positive := 5;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal WE3 : std_logic := '0';
    signal A1, A2, A3 : std_logic_vector(ADDR-1 downto 0) := (others => '0');
    signal WD3 : std_logic_vector(W-1 downto 0) := (others => '0');
    signal RD1, RD2 : std_logic_vector(W-1 downto 0);

    constant PERIOD : time := 10 ns;

    procedure write_reg(
        constant reg_idx : in integer;
        constant data    : in integer;
        signal A3s  : out std_logic_vector(ADDR-1 downto 0);
        signal WD3s : out std_logic_vector(W-1 downto 0);
        signal WEs  : out std_logic
    ) is
    begin
        A3s  <= std_logic_vector(to_unsigned(reg_idx, ADDR));
        WD3s <= std_logic_vector(to_signed(data, W));
        WEs  <= '1';
        wait for PERIOD;
        WEs  <= '0';
    end procedure;
begin

    dut: entity work.RegisterFile
        generic map ( W => W, ADDR => ADDR )
        port map (
            clk => clk, rst => rst, WE3 => WE3,
            A1 => A1, A2 => A2, A3 => A3,
            WD3 => WD3, RD1 => RD1, RD2 => RD2
        );

    clk <= not clk after PERIOD/2;

    process
    begin
        rst <= '1';
        wait for PERIOD;
        rst <= '0';

        write_reg(1,  100, A3, WD3, WE3);
        write_reg(2, -50,  A3, WD3, WE3);
        write_reg(5,  777, A3, WD3, WE3);
        write_reg(0,  999, A3, WD3, WE3);  -- x0

        A1 <= std_logic_vector(to_unsigned(1, ADDR));
        A2 <= std_logic_vector(to_unsigned(2, ADDR));
        wait for PERIOD;

        A1 <= std_logic_vector(to_unsigned(5, ADDR));
        A2 <= std_logic_vector(to_unsigned(0, ADDR));
        wait for PERIOD;

        finish;   -- encerra a simulação aqui
    end process;

end architecture;
