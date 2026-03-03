library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity alarm is
    port (
        clk, clk_1s, rst: in std_logic;
        h2: out natural range 0 to 2;
        h1: out natural range 0 to 4;
        m2: out natural range 0 to 5;
        m1: out natural range 0 to 9;
        h2_in: in natural range 0 to 2;
        h1_in: in natural range 0 to 4;
        m2_in: in natural range 0 to 5;
        m1_in: in natural range 0 to 9;
        edit: in std_logic;
        alarm_out: out std_logic
    );
end alarm;

architecture alarm of alarm is
    signal set, edit_f: std_logic;

begin
    adjust: process(clk, rst) is
    variable h2_match, h1_match, m2_match, m1_match: std_logic;
    begin
        if (rst) then
            set <= '0';
            alarm_out <= '0';
            m1 <= 0;
            m2 <= 0;
            h1 <= 0;
            h2 <= 0;
        elsif rising_edge(clk) then
            -- Check for match
            if (set and not edit) then
                h2_match := '1' when (h2 = h2_in) else '0';
                h1_match := '1' when (h1 = h1_in) else '0';
                m2_match := '1' when (m2 = m2_in) else '0';
                m1_match := '1' when (m1 = m1_in) else '0';
                if h2_match and h1_match and m2_match and m1_match then
                    alarm_out <= '1';
                    set <= '0';
                else alarm_out <= '0';
                end if;
            else alarm_out <= '0';
            end if;

            -- Stay the same
            h2 <= h2;
            h1 <= h1;
            m2 <= m2;
            m1 <= m1;

            edit_f <= edit;
            --edit_ff <= edit_f;

            -- Start editing
            if edit and edit_f then
                set <= '1';
                h2 <= h2_in;
                h1 <= h1_in;
                m2 <= m2_in;
                m1 <= m1_in;
            end if;
        end if;
    end process adjust;

end alarm;
