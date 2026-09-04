library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VectorDataPath is
    generic (
        W    : positive := 32;
        VLEN : positive := 128
    );
    port (
        clk, rst    : in  std_logic;
        -- to general
        Instr       : in  std_logic_vector(W-1 downto 0);
        PCE         : out std_logic;                        -- stall pc  
        Rs1         : in std_logic_vector(W-1 downto 0);  
        Rs2         : in std_logic_vector(W-1 downto 0);   
        ResultSrcin   : in std_logic_vector(W-1 downto 0);       
        ResultSrcout   : out std_logic_vector(W-1 downto 0);       
        -- Control
        VLtoRF      : in  std_logic;
        VtypeSrc    : in  std_logic;
        AVLSrc      : in  std_logic;
        VtypeE      : in  std_logic;
        VlE         : in  std_logic;
        VLx0        : in  std_logic;
        VALUcontrol : in  std_logic;                      
        VM          : in std_logic;
        VRegWrite      : in std_logic;
        VImmrSrc     : in  std_logic;                    
        VXI         : in  std_logic_vector (1 downto 0);
        VResultSrc  : in std_logic
    );
end entity VectorDataPath;

architecture structural of VectorDataPath is
--
--     component VectorRegisterFile is
--         generic (W : positive; ADDR : positive);
--         port (
--             clk : in  STD_LOGIC;
--             rst : in  STD_LOGIC;
--             WE3 : in  STD_LOGIC;
--             A1  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
--             A2  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
--             A3  : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
--             WD3 : in  STD_LOGIC_VECTOR(W-1 downto 0);
--             RD1 : out STD_LOGIC_VECTOR(W-1 downto 0);
--             RD2 : out STD_LOGIC_VECTOR(W-1 downto 0)
--         );
--     end component RegisterFile;
--
    component VectorExtend is
        generic(
            W : integer := 32
        );
        port (
            InstrImm : in  std_logic_vector(31 downto 7);
            ImmSrcV  : in  std_logic;
            ImmExt   : out std_logic_vector(W-1 downto 0)
        );
    end component VectorExtend;

    component VsetControl is
        generic (
            W    : integer := 32;
            ELEN : integer := 32; --sew neq 011
            VLEN : integer := 128
        );
        port (
            VLx0     : in  std_logic;
            AVL      : in  std_logic_vector(W-1 downto 0);
            VTYPEin  : in  std_logic_vector(W-1 downto 0);
            VLout    : out std_logic_vector(W-1 downto 0);
            VTYPEout : out std_logic_vector(W-1 downto 0)
        );
    end component VsetControl;

    component VCSR is
        generic (
            W   : integer := 32;
            CSR : integer := 12
        );
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            ADDR     : in  std_logic_vector(CSR - 1 downto 0);
            VLin     : in  std_logic_vector(W - 1 downto 0);
            Vtypein  : in  std_logic_vector(W - 1 downto 0);
            VLout    : out std_logic_vector(W - 1 downto 0);
            Vtypeout : out std_logic_vector(W - 1 downto 0);
            VtypeE   : in  std_logic;
            VLE      : in  std_logic
        );
    end component VCSR;
--
--     component ALU is
--         generic (W : positive);
--         port (
--             A          : in  STD_LOGIC_VECTOR(W-1 downto 0);
--             B          : in  STD_LOGIC_VECTOR(W-1 downto 0);
--             ALUControl : in  STD_LOGIC_VECTOR(3 downto 0);
--             ALUResult  : out STD_LOGIC_VECTOR(W-1 downto 0)
--         );
--     end component ALU;
--
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

    signal ImmExt      : std_logic_vector(W-1 downto 0);
    signal AVL_mux     : std_logic_vector(W-1 downto 0);
    signal VTYPE_mux   : std_logic_vector(W-1 downto 0);
    signal VL_out_s    : std_logic_vector(W-1 downto 0);
    signal VTYPE_out_s : std_logic_vector(W-1 downto 0);

begin

-- fetch

-- decode
--
-- registerF : VectorRegisterFile
--     generic map (W => W, ADDR => 5)
--     port map (
--         clk => clk,
--         rst => rst,
--         WE3 => RegWrite,
--         A1  => Instr(19 downto 15),
--         A2  => Instr(24 downto 20),
--         A3  => Instr(11 downto 7),
--         WD3 => Result,
--         RD1 => RD1,
--         RD2 => RD2
--     );
-- 
extendU : VectorExtend
    generic map (W => W)
    port map (
        InstrImm => Instr(31 downto 7),
        ImmSrcV  => VImmrSrc,
        ImmExt   => ImmExt
    );

-- Execute
    
    AVL_mux   <= Mux_2x1(Rs1, (W-1 downto 5 => '0') & Instr(19 downto 15), AVLSrc);
    VTYPE_mux <= Mux_2x1(RS2, ImmExt, VtypeSrc);

    vset_inst : VsetControl
        generic map (
            W    => W,
            ELEN => 32,
            VLEN => VLEN
        )
        port map (
            VLx0     => VLx0,
            AVL      => AVL_mux,
            VTYPEin  => VTYPE_mux,
            VLout    => VL_out_s,
            VTYPEout => VTYPE_out_s
        );
--
-- toALUB    <= Mux_2x1(RD2, ImmExt, ALUSrc);
-- WriteData <= RD2;
--
-- ALU_inst : ALU
--     generic map (W => W)
--     port map (
--         A          => toALUA,
--         B          => toALUB,
--         ALUControl => ALUControl,
--         ALUResult  => ALUResult_int
--     );
--
-- ALUResult  <= ALUResult_int;
--
--
ResultSrcout   <= Mux_2x1( ResultSrcin, VL_out_s ,VResultSrc);
-- Writeback
    vcsr_inst : VCSR
        generic map (
            W   => W,
            CSR => 12
        )
        port map (
            clk      => clk,
            rst      => rst,
            ADDR     => Instr(31 downto 20),
            VLin     => VL_out_s,
            Vtypein  => VTYPE_out_s,
            VLout    => open,
            Vtypeout => open,
            VtypeE   => VtypeE,
            VLE      => VlE
        );


end architecture structural;
