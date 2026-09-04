library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Vector is
    generic (
        W    : positive := 32;
        VLEN : positive := 128
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
end entity Vector;

architecture structural of Vector is

    component VectorControlUnit is
        generic (
            W : positive := 32
        );
        port (
            opcode      : in  std_logic_vector(6 downto 0);
            funct3      : in  std_logic_vector(2 downto 0);
            bit25       : in  std_logic;
            bits3130    : in  std_logic_vector(1 downto 0);
            rs1         : in  std_logic_vector(4 downto 0);
            rd          : in  std_logic_vector(4 downto 0);
            VRegWrite   : out std_logic;
            VImmSrc     : out std_logic;
            AVLSrc      : out std_logic;
            VtypeSrc    : out std_logic;
            VLtoRF      : out std_logic;
            VtypeE      : out std_logic;
            VALUControl : out std_logic;
            VXI         : out std_logic_vector(1 downto 0);
            VResultSrc  : out std_logic;
            VLx0        : out std_logic;
            VlE         : out std_logic;
            VM          : out std_logic
        );
    end component VectorControlUnit;

    component VectorDataPath is
        generic (
            W    : positive := 32;
            VLEN : positive := 128
        );
        port (
            clk, rst     : in  std_logic;
            Instr        : in  std_logic_vector(W-1 downto 0);
            PCE          : out std_logic;
            Rs1          : in  std_logic_vector(W-1 downto 0);
            Rs2          : in  std_logic_vector(W-1 downto 0);
            ResultSrcin  : in  std_logic_vector(W-1 downto 0);
            ResultSrcout : out std_logic_vector(W-1 downto 0);
            VLtoRF       : in  std_logic;
            VtypeSrc     : in  std_logic;
            AVLSrc       : in  std_logic;
            VtypeE       : in  std_logic;
            VlE          : in  std_logic;
            VLx0         : in  std_logic;
            VALUcontrol  : in  std_logic;
            VM           : in  std_logic;
            VRegWrite    : in  std_logic;
            VImmrSrc     : in  std_logic;
            VXI          : in  std_logic_vector(1 downto 0);
            VResultSrc   : in  std_logic
        );
    end component VectorDataPath;

    -- fios de controle: ControlUnit -> VectorDataPath
    signal s_VRegWrite   : std_logic;
    signal s_VImmSrc     : std_logic;
    signal s_AVLSrc      : std_logic;
    signal s_VtypeSrc    : std_logic;
    signal s_VLtoRF      : std_logic;
    signal s_VtypeE      : std_logic;
    signal s_VALUControl : std_logic;
    signal s_VXI         : std_logic_vector(1 downto 0);
    signal s_VResultSrc  : std_logic;
    signal s_VLx0        : std_logic;
    signal s_VlE         : std_logic;
    signal s_VM          : std_logic;

begin

    cu : VectorControlUnit
        generic map (W => W)
        port map (
            opcode      => Instr(6 downto 0),
            funct3      => Instr(14 downto 12),
            bit25       => Instr(25),
            bits3130    => Instr(31 downto 30),
            rs1         => Instr(19 downto 15),
            rd          => Instr(11 downto 7),
            VRegWrite   => s_VRegWrite,
            VImmSrc     => s_VImmSrc,
            AVLSrc      => s_AVLSrc,
            VtypeSrc    => s_VtypeSrc,
            VLtoRF      => s_VLtoRF,
            VtypeE      => s_VtypeE,
            VALUControl => s_VALUControl,
            VXI         => s_VXI,
            VResultSrc  => s_VResultSrc,
            VLx0        => s_VLx0,
            VlE         => s_VlE,
            VM          => s_VM
        );

    dp : VectorDataPath
        generic map (W => W, VLEN => VLEN)
        port map (
            clk          => clk,
            rst          => rst,
            Instr        => Instr,
            PCE          => PCE,
            Rs1          => Rs1,
            Rs2          => Rs2,
            ResultSrcin  => ResultSrcin,
            ResultSrcout => ResultSrcout,
            VLtoRF       => s_VLtoRF,
            VtypeSrc     => s_VtypeSrc,
            AVLSrc       => s_AVLSrc,
            VtypeE       => s_VtypeE,
            VlE          => s_VlE,
            VLx0         => s_VLx0,
            VALUcontrol  => s_VALUControl,
            VM           => s_VM,
            VRegWrite    => s_VRegWrite,
            VImmrSrc     => s_VImmSrc,
            VXI          => s_VXI,
            VResultSrc   => s_VResultSrc
        );

end architecture structural;
