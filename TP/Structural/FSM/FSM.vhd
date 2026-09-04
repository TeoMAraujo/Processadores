library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    port (
        CLK    : in  std_logic;
        RST    : in  std_logic;
        OPCODE : in  std_logic_vector(2 downto 0);
        READW  : out std_logic;
        ENABLE : out std_logic -- vai ser usado no S
    );
end FSM;

architecture behavioral of FSM is
    type state_type is (zero, um);
    signal CS, NS : state_type;
begin

    process(CLK, RST)
    begin
        if RST = '1' then
            CS <= zero;
        elsif rising_edge(CLK) then
            CS <= NS;
        end if;
    end process;

    process(CS, OPCODE)
    begin
        NS <= CS;

        case CS is
            when zero =>
                if OPCODE = "000" or OPCODE = "001" then
                    NS <= zero;
                else
                    NS <= um;
                end if;

            when um =>
                NS <= zero;

            when others =>
                NS <= zero;
        end case;
		end process;
		--output logic
		process(CS, OPCODE)
		begin
        case CS is
            when zero =>
                if OPCODE = "000" then
                    READW <= '1';
                    ENABLE <= '0';
                else
                    READW <= '0';
                end if;

            when um =>
                READW <= '0';
                ENABLE <= '1';

            when others =>
                null;
        end case;
    end process;

end behavioral;