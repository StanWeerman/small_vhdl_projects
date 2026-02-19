library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity memory is
    generic (
        data_width: integer := 8;
        LOAD: natural := 0;
        ROM_FILE: string := "exe.bin"
    );
    port (
        clk, rd, wr : in std_logic;
        a : in natural range 0 to 65535;
        d_in : in std_logic_vector(data_width-1 downto 0);
        d_out : out std_logic_vector(data_width-1 downto 0)
    );
end memory;

architecture memory of memory is
    type memory is array (0 to 65535) of std_logic_vector(data_width-1 downto 0);

    impure function init_from_file (rom_file_name : in string) return memory is
        type ins_file is file of character;
        file file_in : ins_file;
        file file_out : text;
        variable rom: memory;
        variable i_line : line;
        variable o_line : line;
        variable ins_1 : character;
        variable ins_2 : character;
        variable index: integer := 0;
    begin
        if (LOAD = 1) then
            file_open(file_in, rom_file_name,  read_mode);
            file_open(file_out, "build/rom.txt",  write_mode);

            while not endfile(file_in) loop
                read(file_in, ins_1);
                read(file_in, ins_2);
                rom(index) := std_logic_vector(to_unsigned(character'pos(ins_1), 8)) & std_logic_vector(to_unsigned(character'pos(ins_2), 8));
                write(o_line, rom(index), right, 16);
                writeline(file_out, o_line);

                index := index+1;
            end loop;
            file_close(file_in);
            file_close(file_out);
        end if;
        return rom;
    end function;

    signal mem : memory := init_from_file(ROM_FILE);
begin
    d_out <= mem(a) when rd else (others => '0');
    read_mem : process(clk) is
        begin
            if rising_edge(clk) then
                if wr then
                    mem(a) <= d_in;
                end if;
            end if;
        end process;
end memory;
