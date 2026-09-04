library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VectorControlUnit is
    generic (
        W : positive := 32
    );
    Port (
        opcode    : in  STD_LOGIC_VECTOR(6 downto 0); --0:7
        funct3    : in  STD_LOGIC_VECTOR(2 downto 0); -- 14 12
        bit25     : in  STD_LOGIC;
        bits3130  : in  STD_LOGIC_VECTOR(1 downto 0);
        rs1       : in  STD_LOGIC_VECTOR(4 downto 0);
        rd        : in  STD_LOGIC_VECTOR(4 downto 0);
        -- Control (vetoriais) -- saídas, placeholder
        VRegWrite   : out std_logic;
        VImmSrc     : out std_logic;
        AVLSrc      : out std_logic;
        VtypeSrc    : out std_logic;
        VLtoRF      : out std_logic;
        VtypeE      : out std_logic;
        VALUControl  : out std_logic; -- add and max
        VXI         : out std_logic_vector(1 downto 0);
        VResultSrc  : out std_logic;
        VLx0        : out std_logic;
        VlE         : out std_logic;
        VM          : out std_logic
    );
end VectorControlUnit;

architecture Behavioral of VectorControlUnit is
    -- MainDecoder inlined (case opcode -> control)
    signal control : std_logic_vector(6 downto 0);
    signal rs1_is_x0 : std_logic;
    signal rd_is_x0  : std_logic;
    signal is_opv  : std_logic;
    signal is_vset : std_logic;
    signal is_vsetreg  : std_logic; -- vsetvli or vsetvl: AVL comes from rs1
begin

    rs1_is_x0 <= '1' when rs1 = "00000" else '0';
    rd_is_x0  <= '1' when rd = "00000" else '0';

    is_opv  <= '1' when opcode = "1010111" else '0';
    is_vset <= '1' when (is_opv = '1' and funct3 = "111") else '0';
    -- vsetivli has bits[31:30]="11"; its rs1 field is a uimm, not a register,
    -- so the rs1=x0 special cases apply only to vsetvli/vsetvl (is_vsetreg).
    is_vsetreg  <= '1' when (is_vset = '1' and bits3130 /= "11") else '0';

    process (is_opv, funct3, bits3130) begin
        if (is_opv = '1') then
            if (funct3 = "111") then
                if (bits3130 = "00") then --vsetvli   (VImmSrc=0: 11-bit zimm[10:0])
                    control <= '0' & '0' & '0' & '1' & '1' & '1' & '0';
                elsif (bits3130 = "11") then --vsetivli (VImmSrc=1: 10-bit zimm[9:0])
                    control <= '0' & '1' & '1' & '1' & '1' & '1' & '0';
                else --vsetvl   (vtype from rs2; immediate unused)
                    control <= '0' & '0' & '0' & '0' & '1' & '1' & '0';
                end if;
            else -- r-type
                control <= (others => '0');
            end if;
        else
            control <= (others => '0');
        end if;
    end process;

    (VRegWrite, VImmSrc, AVLSrc, VtypeSrc, VLtoRF, VtypeE, VALUControl) <= control;

    -- rs1=x0, rd!=x0 -> AVL = ~0, write VLMAX. Only for vsetvli/vsetvl.
    VLx0 <= '1' when (is_vsetreg = '1' and rs1_is_x0 = '1' and rd_is_x0 = '0')
                 else '0';

    -- rs1=x0 and rd=x0 -> keep current vl (don't enable VL write). Only for
    -- vsetvli/vsetvl; vsetivli always updates vl.
    VlE  <= '0' when (is_vsetreg = '1' and rs1_is_x0 = '1' and rd_is_x0 = '1')
                 else '1' when is_vset = '1'
                 else '0';

    VM   <= '0'   when is_vset = '1'
                 else bit25 when is_opv = '1'
                 else '0';

    VXI  <= "00";
    VResultSrc <= is_vset; -- route computed vl to scalar regfile on vset

-- MiniDecoder logic (ALU op decode) reserved for future vector ALU:
--     if ALUOp = '1' then
--         case funct3 is
--             when "000" => sub/add depending on isRtype and funct7_5
--             when "001" => sll
--             when "010" => slt
--             when "011" => sltu
--             when "100" => xor
--             when "101" => sra/srl depending on funct7_5
--             when "110" => or
--             when "111" => and
--             when others => add (against latching)
--         end case;
--     else ALUControl <= add;
end Behavioral;
