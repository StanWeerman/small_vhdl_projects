library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity fu is
    port (
        id_r0a, id_r1a, id_r2a: in natural range 0 to 7;
        ex_r0a: in natural range 0 to 7;
        me_r0a: in natural range 0 to 7;
        ex_reg_wr, me_reg_wr: in std_logic;
        ex_alu: in std_logic;
        id_r0f1, id_r1f1, id_r2f1: out std_logic;
        id_r0f2, id_r1f2, id_r2f2: out std_logic
    );
end fu;

architecture fu of fu is
begin
    process (all) is
    begin
        if (ex_alu) then
            id_r0f1 <= '1' when ex_r0a = id_r0a else '0';
            id_r1f1 <= '1' when ex_r0a = id_r1a else '0';
            id_r2f1 <= '1' when ex_r0a = id_r2a else '0';
        else
            id_r0f1 <= '0';
            id_r1f1 <= '0';
            id_r2f1 <= '0';
        end if;
        if me_reg_wr then
            id_r0f2 <= '1' when me_r0a = id_r0a else '0';
            id_r1f2 <= '1' when me_r0a = id_r1a else '0';
            id_r2f2 <= '1' when me_r0a = id_r2a else '0';
        else
            id_r0f2 <= '0';
            id_r1f2 <= '0';
            id_r2f2 <= '0';
        end if;
    end process;
end fu;
