library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity time is
    port (
        clk_1s, rst: in std_logic;
        h2: out natural range 0 to 2;
        h1: out natural range 0 to 4;
        m2, s2: out natural range 0 to 5;
        m1, s1: out natural range 0 to 9;
        h2_edit: in natural range 0 to 2;
        h1_edit: in natural range 0 to 4;
        m2_edit, s2_edit: in natural range 0 to 5;
        m1_edit, s1_edit: in natural range 0 to 9;
        edit: in std_logic;
        edit_out: out std_logic
    );
end time;

architecture time of time is
begin
    inc_clock: process(clk_1s, rst) is
    begin
        if (rst) then
            edit_out <= '0';
            s1 <= 0;
            s2 <= 0;
            m1 <= 0;
            m2 <= 0;
            h1 <= 0;
            h2 <= 0;
        elsif rising_edge(clk_1s) then
            -- Increment clock by 1
            if s1 = 9 then
                s1 <= 0;
                if s2 = 5 then
                    s2 <= 0;
                    if m1 = 9 then
                        m1 <= 0;
                        if m2 = 5 then
                            m2 <= 0;
                            if h1 = 4 then
                                h1 <= 0;
                                if h2 = 2 then
                                    h2 <= 0;
                                else h2 <= h2 + 1;
                                end if;
                            else h1 <= h1 +1;
                            end if;
                        else m2 <= m2 + 1;
                        end if;
                    else m1 <= m1 + 1;
                    end if;
                else s2 <= s2 + 1;
                end if;
            else s1 <= s1 + 1;
            end if;
            -- Done incrementing

            -- Start editing
            edit_out <= edit;
            if edit_out then
                h2 <= h2_edit;
                h1 <= h1_edit;
                m2 <= m2_edit;
                s2 <= s2_edit;
                m1 <= m1_edit;
                s1 <= s1_edit;
                report to_string(h1_edit);
            end if;
        end if;
    end process inc_clock;

end time;
