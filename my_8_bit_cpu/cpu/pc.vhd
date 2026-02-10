library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity pc is
    port (
        clk, rstb, en : in std_logic;
        jmp, branch : in std_logic;
        jmp_address : in integer range 0 to 65535;
        pco : out integer range 0 to 65535
        );
end pc;

architecture pc of pc is
begin
    process (clk, rstb) is
        begin
            if (rstb = '0') then
                pco <= 0;
            elsif (en) then
                if (jmp) then pco <= jmp_address;
                elsif (branch) then pco <= jmp_address;
                else pco <= pco + 1;
                end if;
            end if;
        end process;
end pc;
