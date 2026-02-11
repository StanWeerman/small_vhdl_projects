library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity reg_file is
    port (
        clk, reg_wr : in std_logic;
        r0a, r1a, r2a : in integer range 0 to 7;
        r0d, r1d, r2d: out std_logic_vector(7 downto 0);
        wd : in std_logic_vector(7 downto 0)
        );
end reg_file;

architecture reg_file of reg_file is
    type memory is array (0 to 7) of std_logic_vector(7 downto 0);
    signal regs : memory;
begin
    r0d <= regs(r0a);
    r1d <= regs(r1a);
    r2d <= regs(r2a);

    process (clk) is
        begin
            if (reg_wr) then
                regs(r0a) <= wd;
            end if;
        end process;
end reg_file;
