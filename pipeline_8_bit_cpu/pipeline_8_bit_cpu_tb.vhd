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
    signal rst, en, m_rd, m_wr : std_logic;
    signal instruction : std_logic_vector(15 downto 0);
    signal cpu_d_in, cpu_d_out : std_logic_vector(7 downto 0);
    signal cpu_a, pco : integer range 0 to 65535;

    -- Test signals
    signal ins_write_data : std_logic_vector(15 downto 0);
    signal ins_mem_wr : std_logic;

    -- File I/O
    type ins_file is file of character;
    file file_in : ins_file;
    file file_out : text;
    signal ready : std_logic := '0';
    signal start_clk : std_logic := '0';
    signal ins_clk : std_logic;
    signal start_address : integer range 0 to 65535 := 0;
    signal ins_address : integer range 0 to 65535;
begin
    cpu : work.cpu_package.cpu port map (clk => clk, rst => rst, en => en, instruction => instruction, d_in => cpu_d_in, d_out => cpu_d_out, m_rd => m_rd, m_wr => m_wr, pco => pco, a => cpu_a);
    ins_mem : work.cpu_package.memory generic map (data_width => 16) port map (clk => ins_clk, rd => '1', wr => ins_mem_wr, a => ins_address, d_in => ins_write_data, d_out => instruction);
    ram : work.cpu_package.memory port map (clk => clk, rd => m_rd, wr => m_wr, a => cpu_a, d_in => cpu_d_out, d_out => cpu_d_in);

    ins_address <= pco when ready else start_address;
    ins_clk <= clk when ready else start_clk;
    clk <= not clk after 10 ns;

    input: process is
        variable i_line : line;
        variable o_line : line;
        variable ins_1 : character;
        variable ins_2 : character;
        variable instruction : std_logic_vector(15 downto 0);
    begin
        file_open(file_in, "/Users/stanweerman/Documents/verilog_projects/small_verilog_projects/8_bit_cpu/assembler/tests/build/add",  read_mode);
        file_open(file_out, "build/output.txt", write_mode);

        while not endfile(file_in) loop
              --readline(file_in, instruction);
              read(file_in, ins_1);
              read(file_in, ins_2);

              instruction := std_logic_vector(to_unsigned(character'pos(ins_1), 8)) & std_logic_vector(to_unsigned(character'pos(ins_2), 8));
              ins_write_data <= instruction;

              ins_mem_wr <= '1';
              start_clk <= '1';
              wait for 1 ps;
              start_clk <= '0';
              wait for 1 ps;
              --start_clk <= '1';
              --wait for 1 ns;

              start_address <= start_address + 1;

              write(o_line, instruction, right, 16);
              writeline(file_out, o_line);
        end loop;

        file_close(file_in);
        file_close(file_out);

        ins_mem_wr <= '0';
        ready <= '1';

        wait;
    end process;

    tb: process is
        begin
            wait until rising_edge(ready);

            rst <= '1';

            --wait until falling_edge(clk);
            wait until rising_edge(clk);
            rst <= '0';
            en <= '1';

            wait for 500 ns;

            finish;
        end process;

end pipeline_8_bit_cpu_tb;
