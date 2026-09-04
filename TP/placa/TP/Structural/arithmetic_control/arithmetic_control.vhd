library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity arithmetic_control is
	 port (
		  OPCODE   : in    std_logic_vector(2 downto 0);
		  OPERAND1 : in    std_logic_vector(7 downto 0);
		  OPERAND2 : in    std_logic_vector(2 downto 0);
		  CLK      : in    std_logic;
		  RST      : in    std_logic; 
		  OUTP     : out   std_logic_vector(7 downto 0);
		  ADDR     : out   std_logic_vector(2 downto 0);
		  DATA     : inout std_logic_vector(7 downto 0);
		  READW    : out   std_logic
	 );
end arithmetic_control;

architecture structural of arithmetic_control is

    -- Data path signals
    signal toALUB          : std_logic_vector(7 downto 0);
    signal toALUA          : std_logic_vector(7 downto 0);
    signal toMuxA          : std_logic_vector(2 downto 0); 
    signal toaddr_data     : std_logic_vector(7 downto 0); 
    
    -- Control signals
    signal toMuxS_ENABLE   : std_logic;
    signal readwtri        : std_logic;
    signal notEnable       : std_logic;

    -- Pipeline signals
    signal op_stage1       : std_logic_vector(2 downto 0); 
    signal op_stage2       : std_logic_vector(2 downto 0); 
    signal op_stage3       : std_logic_vector(2 downto 0); 
    signal op_stage4       : std_logic_vector(2 downto 0); 
    
    -- Data pipeline
    signal data_stage3     : std_logic_vector(7 downto 0);

begin
    -- Stage 1
    U_DFF1: entity work.D_flip_flop
        generic map (W => 3)
        port map (D => OPCODE, CLK => CLK, RST => RST, Q => op_stage1, Qn => open);
  
    U_DFF2: entity work.D_flip_flop
        generic map (W => 8)
        port map (D => OPERAND1, CLK => CLK, RST => RST, Q => toaddr_data, Qn => open);

    U_DFF3: entity work.D_flip_flop
        generic map (W => 3)
        port map (D => OPERAND2, CLK => CLK, RST => RST, Q => toMuxA, Qn => open);
            
    U_FSM : entity work.FSM
        port map (
            CLK    => CLK, 
            RST    => RST, 
            OPCODE => OPCODE, 
            READW  => readwtri, 
            ENABLE => toMuxS_ENABLE
        );
      
    READW <= readwtri;
    
    -- Tri-state logic (Correctly uses registered signal)
    DATA <= toaddr_data when readwtri = '1' else (others => 'Z');
    
    U_MUX_ADDR: entity work.Mux_2x1
        generic map(W => 3)
        -- FIXED: Sliced 'toaddr_data' down to 3 bits
        port map (A => toMuxA, B => toaddr_data(2 downto 0), S => toMuxS_ENABLE, Y => ADDR);
    
    -- Stage 2
    U_DFF_ALU1: entity work.D_flip_flop
        generic map (W => 3)
        port map (D => op_stage1, CLK => CLK, RST => RST, Q => op_stage2, Qn => open);

    -- Stage 3
    U_DFF_ALU2: entity work.D_flip_flop
        generic map (W => 3)
        port map (D => op_stage2, CLK => CLK, RST => RST, Q => op_stage3, Qn => open);
    
    -- Stage 4
    U_DFFALU3: entity work.D_flip_flop
        generic map (W => 3)
        port map (D => op_stage3, CLK => CLK, RST => RST, Q => op_stage4, Qn => open);

    notEnable <= not (toMuxS_ENABLE);
    
    U_DFF_EN1: entity work.D_EN_flip_flop
        generic map (W => 8)
        port map (D => DATA, CLK => CLK, RST => RST, EN => toMuxS_ENABLE, Q => toALUB, Qn => open);

    U_DFF_EN2: entity work.D_EN_flip_flop
        generic map (W => 8)
        port map (D => DATA, CLK => CLK, RST => RST, EN => notEnable, Q => toALUA, Qn => open);

    U_ALU: entity work.ALU
        generic map (W => 8)
        port map (
            A      => toALUA, 
            B      => toALUB,       
            opcode => op_stage4,    
            Y      => OUTP
        );

end structural;