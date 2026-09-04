 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_FSM is
end tb_FSM;

architecture sim of tb_FSM is

    component FSM
    port (
        CLK    : in  std_logic;
        Opcode : in  std_logic_vector(2 downto 0);
        READW  : out std_logic;
        outALU : out std_logic_vector(7 downto 0)
    );
    end component;

    signal s_CLK    : std_logic := '0';
    signal s_Opcode : std_logic_vector(2 downto 0) := (others => '0');
    signal s_READW  : std_logic;
    signal s_outALU : std_logic_vector(7 downto 0);

    constant clk_period : time := 20 ns;

begin

    uut: FSM
    port map (
        CLK    => s_CLK,
        Opcode => s_Opcode,
        READW  => s_READW,
        outALU => s_outALU
    );

    clk_process: process
    begin
        s_CLK <= '0';
        wait for clk_period/2;
        s_CLK <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        wait for 100 ns;

        s_Opcode <= "000";
        wait for clk_period * 2;

        s_Opcode <= "101";
        wait for clk_period * 2;

        s_Opcode <= "000";
        wait for clk_period * 2;

        wait;
    end process;

end sim;
