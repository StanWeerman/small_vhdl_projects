library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity hdu is
    port (
        id_r0a, id_r1a, id_r2a: in natural range 0 to 7;
        ex_r0a: in natural range 0 to 7;
        me_r0a: in natural range 0 to 7;
        ex_reg_wr, me_reg_wr: in std_logic;
        stall_hdu: out std_logic
    );
end hdu;

architecture hdu of hdu is
begin
    process (all) is
    begin
        if ex_reg_wr then
            if ex_r0a = id_r0a or ex_r0a = id_r1a or ex_r0a = id_r2a then stall_hdu <= '1';
            end if;
        elsif me_reg_wr then
            if me_r0a = id_r0a or me_r0a = id_r1a or me_r0a = id_r2a then stall_hdu <= '1';
        end if;
            else stall_hdu <= '0';
        end if;
    end process;
end hdu;
