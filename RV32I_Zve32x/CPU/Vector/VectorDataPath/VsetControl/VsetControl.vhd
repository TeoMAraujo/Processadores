library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity VsetControl is
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
end entity VsetControl;

architecture rtl of VsetControl is
    signal VL         : std_logic_vector(W-1 downto 0);
    signal sew_code   : std_logic_vector(2 downto 0);
    signal vlmul_code : std_logic_vector(2 downto 0);
    signal vlmax      : unsigned(W - 1 downto 0); -- se for pra otimizar poderia usar log(VLEN)
    signal vill       : std_logic;
begin
    -- Ajuste dos indices conforme o padrao RISC-V Vector (LMUL=[2:0], SEW=[5:3])
    vlmul_code <= VTYPEin(2 downto 0);
    sew_code   <= VTYPEin(5 downto 3);
    -- o 6 e o 7 são de vta e vma

    -- calculo VLMAX
    process(sew_code, vlmul_code)
        variable base : unsigned(W-1 downto 0);
    begin
        base := shift_right(to_unsigned(VLEN, W),
                            to_integer(unsigned(sew_code)) + 3);
        if (vlmul_code(2) = '1') then
            vlmax <= shift_right(base,
                        4 - to_integer(unsigned(vlmul_code(1 downto 0)))); -- frac
        else
            vlmax <= shift_left(base,
                        to_integer(unsigned(vlmul_code(1 downto 0)))); -- mul
        end if;
    end process;

    -- logica vill
    process(sew_code, vlmul_code)
    begin
        vill <= '0';
        if (sew_code = "011" or vlmul_code = "100") then -- como o VLEN é 128 comporta todos os casos não reservados de lmul com exceção do de baixo, mas se fosse vlen 32 n poderia ser 1/8
            vill <= '1';
        elsif (sew_code(2) = '1') then
            vill <= '1';
        elsif (vlmul_code = "101" and sew_code = "010") then   -- mf8 (16) + SEW=32
            vill <= '1';
        end if;
    end process;

-- fazer um assembly de riscv apenass testando as intruções 

    -- logica VL e VLx0
    process(VLx0, AVL, vlmax) -- a lógica do x0 para rd é implicita, além disso é feita na unidade de controle a validade onde o Vlx0 é gerado pra lê-lo como vmax, onde a na parte onde ' rs1 = x0 e rd neq x0' faz um não enable no csr
    begin
        if (VLx0 = '1') then
            VL <= std_logic_vector(vlmax);
        elsif (unsigned(AVL) < vlmax) then -- faixa flexivel não ta implementado
            VL <= AVL;
        else
            VL <= std_logic_vector(vlmax);
        end if;
    end process;

    -- logica de saida
    process(vill, VTYPEin, VL)
        variable vtype_illegal : std_logic_vector(W-1 downto 0);
    begin
        if (vill = '1') then
            vtype_illegal := (others => '0');
            vtype_illegal(W-1) := '1'; 
            VTYPEout <= vtype_illegal; 
            VLout    <= (others => '0');
        else
            VTYPEout <= VTYPEin;
            VLout    <= VL;
        end if;
    end process;
end architecture rtl;
