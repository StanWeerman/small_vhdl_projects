library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity my_8_bit_cpu_tb is
end my_8_bit_cpu_tb;

architecture cpu_tb of my_8_bit_cpu_tb is
    signal clk, rst, en, m_rd, m_wr : std_logic;
    signal instruction : std_logic_vector(15 downto 0);
    signal d_in, d_out : std_logic_vector(7 downto 0);

begin
    cpu : work.cpu_package.cpu port map (clk => clk, rst => rst, en => en, instruction => instruction, d_in => d_in, d_out => d_out, m_rd => m_rd, m_wr => m_wr);
    --ins_mem : entity work
    clk <= not clk after 50 ns;
    tb: process is
        begin

            finish;
        end process;

end cpu_tb;
