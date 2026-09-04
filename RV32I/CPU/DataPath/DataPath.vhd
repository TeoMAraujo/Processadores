library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataPath is
    generic (
        W : positive := 32
    );
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
end entity DataPath;

architecture structural of DataPath is

    component RegisterFile is
        generic (W : positive; ADDR : positive);
        port (
            clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            WE3 : in  STD_LOGIC;
            A1  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
            A2  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
            A3  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
            WD3 : in  STD_LOGIC_VECTOR(W-1 downto 0);
            RD1 : out STD_LOGIC_VECTOR(W-1 downto 0);
            RD2 : out STD_LOGIC_VECTOR(W-1 downto 0)
        );
    end component RegisterFile;

    component Extend is
        generic (W : positive);
        port (
            InstrImm : in  STD_LOGIC_VECTOR(24 downto 0);
            ImmSrc   : in  STD_LOGIC_VECTOR(2 downto 0);
            ImmExt   : out STD_LOGIC_VECTOR(W-1 downto 0)
        );
    end component Extend;

    component BranchLogic is
        generic (W : positive);
        port (
            A      : in  STD_LOGIC_VECTOR(W-1 downto 0);
            B      : in  STD_LOGIC_VECTOR(W-1 downto 0);
            funct3 : in  STD_LOGIC_VECTOR(2 downto 0);
            Btake  : out STD_LOGIC
        );
    end component BranchLogic;

    component ALU is
        generic (W : positive);
        port (
            A          : in  STD_LOGIC_VECTOR(W-1 downto 0);
            B          : in  STD_LOGIC_VECTOR(W-1 downto 0);
            ALUControl : in  STD_LOGIC_VECTOR(3 downto 0);
            ALUResult  : out STD_LOGIC_VECTOR(W-1 downto 0)
        );
    end component ALU;

    function Mux_2x1(
        A, B : STD_LOGIC_VECTOR(W - 1 downto 0);
        S    : STD_LOGIC
    ) return STD_LOGIC_VECTOR is
    begin
        case S is
            when '0'    => return A;
            when '1'    => return B;
            when others => return (A'range => '0');
        end case;
    end function Mux_2x1;

    function Mux_4x2(
        A, B, C, D : STD_LOGIC_VECTOR(W - 1 downto 0);
        S          : STD_LOGIC_VECTOR(1 downto 0)
    ) return STD_LOGIC_VECTOR is
    begin
        case S is
            when "00"   => return A;
            when "01"   => return B;
            when "10"   => return C;
            when "11"   => return D;
            when others => return (A'range => '0');
        end case;
    end function Mux_4x2;

    signal toPC          : std_logic_vector(W-1 downto 0);
    signal PCPlus4       : std_logic_vector(W-1 downto 0);
    signal ExtendSum     : std_logic_vector(W-1 downto 0) := (others => '0');
    signal toMuxPC       : std_logic_vector(W-1 downto 0);
    signal RD1, RD2      : std_logic_vector(W-1 downto 0);
    signal toALUA        : std_logic_vector(W-1 downto 0);
    signal toALUB        : std_logic_vector(W-1 downto 0);
    signal ImmExt        : std_logic_vector(W-1 downto 0);
    signal Result        : std_logic_vector(W-1 downto 0);
    signal PC_int        : std_logic_vector(W-1 downto 0) := (others => '0');
    signal jalrTarget    : std_logic_vector(W-1 downto 0);
    signal ALUResult_int : std_logic_vector(W-1 downto 0);

begin

-- fetch
toPC    <= Mux_2x1(PCPlus4, toMuxPC, PCSrc);
PCPlus4 <= std_logic_vector(unsigned(PC_int) + 4);

process (clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            PC_int <= (others => '0');
        else
            PC_int <= toPC;
        end if;
    end if;
end process; -- instrMemory outside
PC      <= PC_int;

-- decode
registerF : RegisterFile
    generic map (W => W, ADDR => 5)
    port map (
        clk => clk,
        rst => rst,
        WE3 => RegWrite,
        A1  => Instr(19 downto 15),
        A2  => Instr(24 downto 20),
        A3  => Instr(11 downto 7),
        WD3 => Result,
        RD1 => RD1,
        RD2 => RD2
    );

extendU : Extend
    generic map (W => W)
    port map (
        InstrImm => Instr(31 downto 7),
        ImmSrc   => ImmSrc,
        ImmExt   => ImmExt
    );

-- Execute
toALUA <= Mux_2x1(RD1, PC_int, PCtoALU); -- could be before the mux, actually is better, but as i already draw it
toALUB    <= Mux_2x1(RD2, ImmExt, ALUSrc);
WriteData <= RD2;

BranchL : BranchLogic
    generic map (W => W)
    port map (
        A      => toALUA,
        B      => toALUB,
        funct3 => Instr(14 downto 12),
        Btake  => Btake
    );

ALU_inst : ALU
    generic map (W => W)
    port map (
        A          => toALUA,
        B          => toALUB,
        ALUControl => ALUControl,
        ALUResult  => ALUResult_int
    );

ALUResult  <= ALUResult_int;
jalrTarget <= ALUResult_int(W-1 downto 1) & '0'; -- could be an mux before the sum, avoiding ALU
ExtendSum  <= std_logic_vector(unsigned(PC_int) + unsigned(ImmExt)); -- o tamanho da memória de instrução pode ser ate so 32 pq se n capa algumas instruções se for usando mt
toMuxPC    <= Mux_2x1(ExtendSum, jalrTarget, ALUtoPC); --jalr and extend

-- Writeback
Result <= Mux_4x2(ALUResult_int, ReadData, PCPlus4, ImmExt, ResultSrc);

end structural;
