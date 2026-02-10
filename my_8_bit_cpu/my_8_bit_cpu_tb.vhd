library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity my_8_bit_cpu_tb is
end my_8_bit_cpu_tb;

architecture cpu_tb of my_8_bit_cpu_tb is
    -- CPU signals
    signal clk : std_logic := '0';
    signal rst, en, m_rd, m_wr : std_logic;
    signal instruction : std_logic_vector(15 downto 0);
    signal cpu_d_in, cpu_d_out : std_logic_vector(7 downto 0);
    signal cpu_a, pco : integer range 0 to 65535;

    -- Test signals
    signal ins_write_data : std_logic_vector(15 downto 0);
    signal ins_mem_wr : std_logic;
begin
    cpu : work.cpu_package.cpu port map (clk => clk, rst => rst, en => en, instruction => instruction, d_in => cpu_d_in, d_out => cpu_d_out, m_rd => m_rd, m_wr => m_wr, pco => pco);
    ins_mem : work.cpu_package.memory generic map (data_width => 16) port map (clk => clk, rd => '1', wr => ins_mem_wr, a => pco, d_in => ins_write_data, d_out => instruction);
    ram : work.cpu_package.memory port map (clk => clk, rd => m_rd, wr => m_wr, a => cpu_a, d_in => cpu_d_out, d_out => cpu_d_in);

    clk <= not clk after 50 ns;

    tb: process is
        begin
            rst <= '1';

            wait until falling_edge(clk);
            wait until rising_edge(clk);
            rst <= '0';

            wait until rising_edge(clk);
            ins_mem_wr <= '1';
            ins_write_data <= "0010000000000011";
            wait until rising_edge(clk);
            ins_mem_wr <= '1';
            ins_write_data <= "0100000000100011";
            wait until rising_edge(clk);
            ins_mem_wr <= '1';
            ins_write_data <= "0000000010100011";
            wait until rising_edge(clk);
            ins_mem_wr <= '1';
            ins_write_data <= "0000010100000010";
            wait until rising_edge(clk);
            ins_mem_wr <= '1';
            ins_write_data <= "0100010100000100";
            wait until rising_edge(clk);
            ins_mem_wr <= '1';
            ins_write_data <= "0111111000100011";
            wait until rising_edge(clk);
            ins_mem_wr <= '1';
            ins_write_data <= "1000001111100011";
            wait until rising_edge(clk);
            ins_mem_wr <= '0';
            wait until falling_edge(clk);

            en <= '1';


            finish;
        end process;

end cpu_tb;
