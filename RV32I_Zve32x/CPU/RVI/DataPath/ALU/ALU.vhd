library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    generic(
        W : integer := 32
    );
    port(
        A           : in  std_logic_vector(W-1 downto 0);
        B           : in  std_logic_vector(W-1 downto 0);
        ALUControl  : in  std_logic_vector(3 downto 0);
        ALUResult   : out std_logic_vector(W-1 downto 0)
    );
end entity;

architecture dataflow of ALU is
    signal add_out  : std_logic_vector(W-1 downto 0); -- i could do further implementations of each module
    signal sub_out  : std_logic_vector(W-1 downto 0);
    signal sll_out  : std_logic_vector(W-1 downto 0);
    signal srl_out  : std_logic_vector(W-1 downto 0);
    signal sra_out  : std_logic_vector(W-1 downto 0);
    signal and_out  : std_logic_vector(W-1 downto 0);
    signal or_out   : std_logic_vector(W-1 downto 0);
    signal xor_out  : std_logic_vector(W-1 downto 0);
    signal slt_out  : std_logic_vector(W-1 downto 0);
    signal sltu_out : std_logic_vector(W-1 downto 0);
begin
--- ALU
    add_out  <= std_logic_vector(signed(A) + signed(B));
    sub_out  <= std_logic_vector(signed(A) - signed(B));
    sll_out  <= std_logic_vector(shift_left (unsigned(A), to_integer(unsigned(B(4 downto 0)))));
    srl_out  <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
    sra_out  <= std_logic_vector(shift_right(signed(A),   to_integer(unsigned(B(4 downto 0)))));
    and_out  <= A and B;
    or_out   <= A or  B;
    xor_out  <= A xor B;
    slt_out  <= (0 => '1', others => '0') when signed(A) < signed(B) else (others => '0');
    sltu_out <= (0 => '1', others => '0') when unsigned(A) < unsigned(B) else (others => '0');

with ALUControl select -- theres an strong dependecy onto the R-Type
    ALUResult <= add_out  when "0000",
                 sub_out  when "0001",
                 sll_out  when "0010",
                 srl_out  when "0011",
                 sra_out  when "0100",
                 and_out  when "0101",
                 or_out   when "0110",
                 xor_out  when "0111",
                 slt_out  when "1000",
                 sltu_out when "1001",
                 (others => '0') when others;
end architecture;
