library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TOP is
    generic (
        W : positive := 32
    );
    port (
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC
    );
end entity TOP;

architecture structural of TOP is

    component CPU is
        generic (W : positive);
        port (
            CLK, rst  : in  STD_LOGIC;
            ReadData  : in  STD_LOGIC_VECTOR(W-1 downto 0);
            Instr     : in  STD_LOGIC_VECTOR(W-1 downto 0);
            PC        : out STD_LOGIC_VECTOR(W-1 downto 0);
            ALUResult : out STD_LOGIC_VECTOR(W-1 downto 0);
            WriteData : out STD_LOGIC_VECTOR(W-1 downto 0);
            Funct3    : out STD_LOGIC_VECTOR(2 downto 0);
            MemWrite  : out STD_LOGIC
        );
    end component;

    component DataMemory is
        generic (
            W        : positive;
            NUM_REGS : integer
        );
        port (
            clk    : in  STD_LOGIC;
            rst    : in  STD_LOGIC;
            WE     : in  STD_LOGIC;
            funct3 : in  STD_LOGIC_VECTOR(2 downto 0);
            ADDR   : in  STD_LOGIC_VECTOR(9 downto 0);
            WD     : in  STD_LOGIC_VECTOR(W - 1 downto 0);
            RD     : out STD_LOGIC_VECTOR(W - 1 downto 0)
        );
    end component;

    component InstructionMemory is
        generic (
            W      : positive;
            ADDR_W : positive
        );
        port (
            PC          : in  STD_LOGIC_VECTOR(W-1 downto 0);
            instruction : out STD_LOGIC_VECTOR(W-1 downto 0)
        );
    end component;

    signal sPC        : STD_LOGIC_VECTOR(W-1 downto 0);
    signal sInstr     : STD_LOGIC_VECTOR(W-1 downto 0);
    signal sALUResult : STD_LOGIC_VECTOR(W-1 downto 0);
    signal sWriteData : STD_LOGIC_VECTOR(W-1 downto 0);
    signal sReadData  : STD_LOGIC_VECTOR(W-1 downto 0);
    signal sFunct3    : STD_LOGIC_VECTOR(2 downto 0);
    signal sMemWrite  : STD_LOGIC;

begin

    U_CPU : CPU
        generic map (W => W)
        port map (
            CLK       => CLK,
            rst       => RST,
            ReadData  => sReadData,
            Instr     => sInstr,
            PC        => sPC,
            ALUResult => sALUResult,
            WriteData => sWriteData,
            Funct3    => sFunct3,
            MemWrite  => sMemWrite
        );

    U_IMEM : InstructionMemory
        generic map (W => W, ADDR_W => 10)
        port map (
            PC          => sPC,
            instruction => sInstr
        );

    U_DMEM : DataMemory
        generic map (
            W        => W,
            NUM_REGS => 10
        )
        port map (
            clk    => CLK,
            rst    => RST,
            WE     => sMemWrite,
            funct3 => sFunct3,
            ADDR   => sALUResult(9 downto 0),
            WD     => sWriteData,
            RD     => sReadData
        );

end architecture structural;
