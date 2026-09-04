library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_VsetControl is
end entity tb_VsetControl;

architecture sim of tb_VsetControl is
    constant W    : integer := 32;
    constant ELEN : integer := 32;
    constant VLEN : integer := 128;

    signal VLx0     : std_logic := '0';
    signal AVL      : std_logic_vector(W-1 downto 0) := (others => '0');
    signal VTYPEin  : std_logic_vector(W-1 downto 0) := (others => '0');
    signal VLout    : std_logic_vector(W-1 downto 0);
    signal VTYPEout : std_logic_vector(W-1 downto 0);
begin

    DUT: entity work.VsetControl
        generic map (
            W    => W,
            ELEN => ELEN,
            VLEN => VLEN
        )
        port map (
            VLx0     => VLx0,
            AVL      => AVL,
            VTYPEin  => VTYPEin,
            VLout    => VLout,
            VTYPEout => VTYPEout
        );

    stim_proc: process
    begin
        -- Teste 1: Configuração padrão (SEW=8, LMUL=1 -> VLMAX = 16)
        -- AVL menor que VLMAX (AVL = 10 -> VLout deve ser 10)
        VLx0    <= '0';
        AVL     <= std_logic_vector(to_unsigned(10, W));
        VTYPEin <= (others => '0');
        wait for 20 ns;
        assert (to_integer(unsigned(VLout)) = 10) report "Erro Teste 1: VLout incorreto" severity error;

        -- Teste 2: Saturação em VLMAX
        -- AVL maior que VLMAX (AVL = 30 -> VLout deve saturar em 16)
        AVL <= std_logic_vector(to_unsigned(30, W));
        wait for 20 ns;
        assert (to_integer(unsigned(VLout)) = 16) report "Erro Teste 2: VLout deveria ser 16" severity error;

        -- Teste 3: Forçar VLMAX via sinal VLx0='1'
        -- Mesmo com AVL baixo, VLx0='1' deve carregar VLMAX (16)
        VLx0 <= '1';
        AVL  <= std_logic_vector(to_unsigned(3, W));
        wait for 20 ns;
        assert (to_integer(unsigned(VLout)) = 16) report "Erro Teste 3: VLx0 nao forcou VLMAX" severity error;
        VLx0 <= '0';

-- Teste 4: Multiplicador fracionario LMUL=1/2 ("111"), SEW=8 ("000")
        -- vlmul em VTYPEin(2 downto 0) = "111"
        -- sew   em VTYPEin(5 downto 3) = "000"
        -- VLMAX = (128 / 8) / 2 = 8. Com AVL = 15, deve saturar em 8
        VTYPEin <= (others => '0');
        VTYPEin(5 downto 0) <= "000111";
        AVL <= std_logic_vector(to_unsigned(15, W));
        wait for 20 ns;
        assert (to_integer(unsigned(VLout)) = 8) report "Erro Teste 4: Falha em LMUL fracionario" severity error;

        -- Teste 5: Instrucao invalida (vill = '1')
        -- SEW=64 ("011") em VTYPEin(5 downto 3) e invalido para ELEN=32 -> VLout=0 e VTYPEout(31)='1'
        VTYPEin <= (others => '0');
        VTYPEin(5 downto 3) <= "011";
        wait for 20 ns;
        assert (to_integer(unsigned(VLout)) = 0) report "Erro Teste 5: VLout deveria ser zero para vill=1" severity error;
        assert (VTYPEout(W-1) = '1') report "Erro Teste 5: Bit vill deve ser 1" severity error;

        report "Simulacao concluida com sucesso!" severity note;
        wait;
    end process;

end architecture sim;
