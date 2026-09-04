library IEEE;
use IEEE.std_logic_1164.all;

entity CPU is
    generic (
        W : positive := 32
    );
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
end CPU;

architecture structural of CPU is

    component ControlUnit is
        generic (W : positive);
        port (
            opcode      : in  STD_LOGIC_VECTOR(6 downto 0);
            funct3      : in  STD_LOGIC_VECTOR(2 downto 0);
            funct7_5    : in  STD_LOGIC;
            Btake       : in  STD_LOGIC;
            PCSrc       : out STD_LOGIC;
            ALUtoPC     : out STD_LOGIC;
            ResultSrc   : out STD_LOGIC_VECTOR(1 downto 0);
            MemWrite    : out STD_LOGIC;
            ALUControl  : out STD_LOGIC_VECTOR(3 downto 0);
            ALUSrc      : out STD_LOGIC;
            PCtoALU     : out STD_LOGIC;
            ImmSrc      : out STD_LOGIC_VECTOR(2 downto 0);
            RegWrite    : out STD_LOGIC
        );
    end component;

    component DataPath is
        generic (W : positive);
        port (
            clk, rst    : in  STD_LOGIC;
            Instr       : in  STD_LOGIC_VECTOR(W-1 downto 0);
            PCSrc       : in  STD_LOGIC;
            ALUtoPC     : in  STD_LOGIC;
            ResultSrc   : in  STD_LOGIC_VECTOR(1 downto 0);
            ALUControl  : in  STD_LOGIC_VECTOR(3 downto 0);
            ALUSrc      : in  STD_LOGIC;
            PCtoALU     : in  STD_LOGIC;
            ImmSrc      : in  STD_LOGIC_VECTOR(2 downto 0);
            RegWrite    : in  STD_LOGIC;
            Btake       : out STD_LOGIC;
            ReadData    : in  STD_LOGIC_VECTOR(W-1 downto 0);
            ALUResult   : out STD_LOGIC_VECTOR(W-1 downto 0);
            PC          : out STD_LOGIC_VECTOR(W-1 downto 0);
            WriteData   : out STD_LOGIC_VECTOR(W-1 downto 0)
        );
    end component;

    signal sBtake      : STD_LOGIC;
    signal sPCSrc      : STD_LOGIC;
    signal sALUtoPC    : STD_LOGIC;
    signal sResultSrc  : STD_LOGIC_VECTOR(1 downto 0);
    signal sALUControl : STD_LOGIC_VECTOR(3 downto 0);
    signal sALUSrc     : STD_LOGIC;
    signal sPCtoALU    : STD_LOGIC;
    signal sImmSrc     : STD_LOGIC_VECTOR(2 downto 0);
    signal sRegWrite   : STD_LOGIC;

begin

    Funct3 <= Instr(14 downto 12);

    CU : ControlUnit
        generic map (W => W)
        port map (
            opcode      => Instr(6 downto 0),
            funct3      => Instr(14 downto 12),
            funct7_5    => Instr(30),
            Btake       => sBtake,
            PCSrc       => sPCSrc,
            ALUtoPC     => sALUtoPC,
            ResultSrc   => sResultSrc,
            MemWrite    => MemWrite,
            ALUControl  => sALUControl,
            ALUSrc      => sALUSrc,
            PCtoALU     => sPCtoALU,
            ImmSrc      => sImmSrc,
            RegWrite    => sRegWrite
        );

    DP : DataPath
        generic map (W => W)
        port map (
            clk         => CLK,
            rst         => rst,
            Instr       => Instr,
            PCSrc       => sPCSrc,
            ALUtoPC     => sALUtoPC,
            ResultSrc   => sResultSrc,
            ALUControl  => sALUControl,
            ALUSrc      => sALUSrc,
            PCtoALU     => sPCtoALU,
            ImmSrc      => sImmSrc,
            RegWrite    => sRegWrite,
            Btake       => sBtake,
            ReadData    => ReadData,
            ALUResult   => ALUResult,
            PC          => PC,
            WriteData   => WriteData
        );

end structural;
