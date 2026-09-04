library IEEE;
use IEEE.std_logic_1164.all;

-- Top level: scalar RVI core + Vector coprocessor sharing the register
-- operand / writeback bus. Instruction and data memory stay external.
entity CPU is
    generic (
        W    : positive := 32;
        VLEN : positive := 128
    );
    port (
        clk, rst  : in  STD_LOGIC;
        -- instruction memory interface
        Instr     : in  STD_LOGIC_VECTOR(W-1 downto 0);
        PC        : out STD_LOGIC_VECTOR(W-1 downto 0);
        -- data memory interface
        ReadData  : in  STD_LOGIC_VECTOR(W-1 downto 0);
        ALUResult : out STD_LOGIC_VECTOR(W-1 downto 0);
        WriteData : out STD_LOGIC_VECTOR(W-1 downto 0);
        Funct3    : out STD_LOGIC_VECTOR(2 downto 0);
        MemWrite  : out STD_LOGIC
    );
end entity CPU;

architecture structural of CPU is

    component RVI is
        generic (W : positive);
        port (
            CLK, rst  : in  STD_LOGIC;
            ReadData  : in  STD_LOGIC_VECTOR(W-1 downto 0);
            Instr     : in  STD_LOGIC_VECTOR(W-1 downto 0);
            PC        : out STD_LOGIC_VECTOR(W-1 downto 0);
            ALUResult : out STD_LOGIC_VECTOR(W-1 downto 0);
            WriteData : out STD_LOGIC_VECTOR(W-1 downto 0);
            Funct3    : out STD_LOGIC_VECTOR(2 downto 0);
            MemWrite  : out STD_LOGIC;
            PCE       : in  STD_LOGIC;
            ResultIn  : in  STD_LOGIC_VECTOR(W-1 downto 0);
            ResultOut : out STD_LOGIC_VECTOR(W-1 downto 0);
            Rs1       : out STD_LOGIC_VECTOR(W-1 downto 0);
            Rs2       : out STD_LOGIC_VECTOR(W-1 downto 0)
        );
    end component RVI;

    component Vector is
        generic (
            W    : positive;
            VLEN : positive
        );
        port (
            clk, rst     : in  std_logic;
            Instr        : in  std_logic_vector(W-1 downto 0);
            Rs1          : in  std_logic_vector(W-1 downto 0);
            Rs2          : in  std_logic_vector(W-1 downto 0);
            ResultSrcin  : in  std_logic_vector(W-1 downto 0);
            ResultSrcout : out std_logic_vector(W-1 downto 0);
            PCE          : out std_logic
        );
    end component Vector;

    -- scalar core -> vector coprocessor
    signal sRs1       : std_logic_vector(W-1 downto 0);
    signal sRs2       : std_logic_vector(W-1 downto 0);
    signal sResultOut : std_logic_vector(W-1 downto 0);
    -- vector coprocessor -> scalar core
    signal sResultIn  : std_logic_vector(W-1 downto 0);
    signal sPCE       : std_logic;

begin

    scalar_core : RVI
        generic map (W => W)
        port map (
            CLK       => clk,
            rst       => rst,
            ReadData  => ReadData,
            Instr     => Instr,
            PC        => PC,
            ALUResult => ALUResult,
            WriteData => WriteData,
            Funct3    => Funct3,
            MemWrite  => MemWrite,
            PCE       => sPCE,
            ResultIn  => sResultIn,
            ResultOut => sResultOut,
            Rs1       => sRs1,
            Rs2       => sRs2
        );

    vector_coproc : Vector
        generic map (W => W, VLEN => VLEN)
        port map (
            clk          => clk,
            rst          => rst,
            Instr        => Instr,
            Rs1          => sRs1,
            Rs2          => sRs2,
            ResultSrcin  => sResultOut,
            ResultSrcout => sResultIn,
            PCE          => sPCE
        );

end architecture structural;
