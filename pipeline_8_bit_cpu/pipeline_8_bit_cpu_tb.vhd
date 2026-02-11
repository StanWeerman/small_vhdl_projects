library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use STD.textio.all;
use ieee.std_logic_textio.all;
use IEEE.NUMERIC_STD.ALL;

entity pipeline_8_bit_cpu_tb is
end pipeline_8_bit_cpu_tb;

architecture pipeline_8_bit_cpu_tb of pipeline_8_bit_cpu_tb is
    -- CPU signals
    signal clk : std_logic := '0';
    signal rst, en: std_logic;
    --signal instruction : std_logic_vector(15 downto 0);
    --signal cpu_d_in, cpu_d_out : std_logic_vector(7 downto 0);
    --signal cpu_a, pco : integer range 0 to 65535;

    -- Test signals
    signal ins_write_data : std_logic_vector(15 downto 0);
    signal ins_mem_wr : std_logic;

    -- File I/O
    type ins_file is file of character;
    file file_in : ins_file;
    file file_out : text;
    signal start_clk : std_logic := '0';
    signal ins_clk : std_logic;
    signal start_address : integer range 0 to 65535 := 0;
    signal ins_address : integer range 0 to 65535;
begin
    cpu: entity work.cpu
    port map(
        clk => clk,
        rst => rst,
        en => en
    );

    clk <= not clk after 10 ns;

    tb: process is
        begin
            en <= '1';
            rst <= '1';
            ----wait until falling_edge(clk);
            wait until rising_edge(clk);
            rst <= '0';

            wait for 500 ns;

            finish;
        end process;

end pipeline_8_bit_cpu_tb;
