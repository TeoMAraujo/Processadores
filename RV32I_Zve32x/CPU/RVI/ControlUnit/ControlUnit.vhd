library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ControlUnit is
    generic (
        W : positive := 32
    );
    Port (
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
end ControlUnit;
architecture Behavioral of ControlUnit is
    component MainDecoder is
        port (
            opcode      : in  STD_LOGIC_VECTOR(6 downto 0);
            Jump        : out STD_LOGIC;
            Branch      : out STD_LOGIC;
            ALUtoPC     : out STD_LOGIC;
            ALUOp       : out STD_LOGIC;
            ResultSrc   : out STD_LOGIC_VECTOR(1 downto 0);
            MemWrite    : out STD_LOGIC;
            ALUSrc      : out STD_LOGIC;
            PCtoALU     : out STD_LOGIC;
            ImmSrc      : out STD_LOGIC_VECTOR(2 downto 0);
            RegWrite    : out STD_LOGIC;
            isRtype     : out STD_LOGIC
        );
    end component;
    component MiniDecoder is
        Port (
            funct3      : in  STD_LOGIC_VECTOR(2 downto 0);
            funct7_5    : in  STD_LOGIC;
            ALUOp       : in  STD_LOGIC;
            isRtype     : in  STD_LOGIC;
            ALUControl  : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    signal btemp   : std_logic;
    signal branch  : std_logic;
    signal jump    : std_logic;
    signal ALUOp   : std_logic;
    signal isRtype : std_logic;
begin
    u_main : MainDecoder
        port map (
            opcode    => opcode,
            Jump      => jump,
            Branch    => btemp,
            ALUtoPC   => ALUtoPC,
            ALUOp     => ALUOp,
            ResultSrc => ResultSrc,
            MemWrite  => MemWrite,
            ALUSrc    => ALUSrc,
            PCtoALU   => PCtoALU,
            ImmSrc    => ImmSrc,
            RegWrite  => RegWrite,
            isRtype   => isRtype
        );
    u_mini : MiniDecoder
        port map (
            funct3     => funct3,
            funct7_5   => funct7_5,
            ALUOp      => ALUOp,
            isRtype    => isRtype,
            ALUControl => ALUControl
        );
    branch <= btemp and Btake;
    PCSrc  <= branch or jump;
end Behavioral;
