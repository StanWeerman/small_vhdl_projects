library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;

entity reg_file is
    generic (
        DEBUG: natural := 0       -- 0 = no debug, 1 = print debug
        );
    port (
        clk, reg_wr : in std_logic;
        r0a, r1a, r2a : in natural range 0 to 7;
        r0d, r1d, r2d: out std_logic_vector(7 downto 0);
        wd : in std_logic_vector(7 downto 0)
        );
end reg_file;

architecture reg_file of reg_file is
    file file_out_reg : text;
    signal clk_ctr : integer := 0;

    type memory is array (0 to 7) of std_logic_vector(7 downto 0);
    signal regs : memory;
begin
    r0d <= regs(r0a);
    r1d <= regs(r1a);
    r2d <= regs(r2a);

    process (clk) is
        begin
            if (rising_edge(clk)) then
                if (reg_wr) then
                    regs(r0a) <= wd;
                end if;
            end if;
        end process;


    debug_output : if DEBUG = 1 generate
        reg_file_output: process is
            variable line : line;
            begin
                file_open(file_out_reg, "build/output_reg_file.txt", write_mode);
                write(line, string'("----- Single Cycle CPU Registers -----"));
                writeline(file_out_reg, line);

                output: loop
                    wait until rising_edge(clk);
                    clk_ctr <= clk_ctr + 20;

                    write(line, clk_ctr, right, 10);
                    write(line, string'(": "));
                    for i in 0 to 7 loop
                        write(line, to_hex_string(regs(i)));
                        write(line, string'("|"));
                    end loop;

                    writeline(file_out_reg, line);
                    --$fdisplay (output_reg_file, "+%4t: |0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|", $time, cpu.register_file.reg_file[0], cpu.register_file.reg_file[1], cpu.register_file.reg_file[2], cpu.register_file.reg_file[3], cpu.register_file.reg_file[4], cpu.register_file.reg_file[5], cpu.register_file.reg_file[6], cpu.register_file.reg_file[7]);

                end loop;
            end process;
        end generate;
end reg_file;
