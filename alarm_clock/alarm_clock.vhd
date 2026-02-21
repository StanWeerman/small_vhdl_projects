library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity alarm_clock is
    generic (
        PERIOD: integer := 50000000;
        N_CLOCKS: integer := 1;
        N_ALARMS: integer := 1
    ); -- For 100MHZ clk, switch when div_clk is 50,000,000
    port (
        clk, rst: in std_logic;
        up, down, left, right: in std_logic;
        editing: std_logic;

        h2: out natural range 0 to 2;
        h1: out natural range 0 to 4;
        m2, s2: out natural range 0 to 5;
        m1, s1: out natural range 0 to 9;
        alarm_1, alarm_2: out std_logic;
        time_select: in natural range 0 to N_CLOCKS
    );
end alarm_clock;

architecture alarm_clock of alarm_clock is
    signal div_clk: std_logic_vector(26 downto 0);
    signal clk_1s: std_logic;

    signal edit_out: std_logic_vector(N_CLOCKS-1 downto 0);
    signal edit_select: natural range 0 to 5;
    signal edit_val: integer range -1 to 1;

    type three_array is array (0 to N_CLOCKS-1) of natural range 0 to 2;
    type five_array is array (0 to N_CLOCKS-1) of natural range 0 to 4;
    type six_array is array (0 to N_CLOCKS-1) of natural range 0 to 5;
    type ten_array is array (0 to N_CLOCKS-1) of natural range 0 to 9;
    signal h2s: three_array;
    signal h1s: five_array;
    signal m2s, s2s: six_array;
    signal m1s, s1s: ten_array;

    signal h2_edit: natural range 0 to 2;
    signal h1_edit: natural range 0 to 4;
    signal m2_edit, s2_edit: natural range 0 to 5;
    signal m1_edit, s1_edit: natural range 0 to 9;

    function adjust_clock_value (
        max: in natural;
        val: in natural;
        add: in integer range -1 to 1
    )
    return natural is
    begin
        if add = 1 then
            if val = max then return 0;
            else return val + 1;
            end if;
        elsif add = -1 then
            if val = 0 then return max;
            else return val - 1;
            end if;
        else
            return val;
        end if;
    end function adjust_clock_value;
begin
    clk_1s <= '0' when div_clk = std_logic_vector(to_unsigned(PERIOD, 27)) else '1';

    inc_clk: process(clk, rst) is
    begin
        if (rst) then
            div_clk <= (others => '0');
        end if;
        if rising_edge(clk) then
            div_clk <= std_logic_vector(unsigned(div_clk) + 1);
            if div_clk = std_logic_vector(to_unsigned(PERIOD, 27)) then
                div_clk <= (others => '0');
            end if;
        end if;
    end process inc_clk;

    h2 <= h2s(time_select);
    h1 <= h1s(time_select);
    m2 <= m2s(time_select);
    m1 <= m1s(time_select);
    s2 <= s2s(time_select);
    s1 <= s1s(time_select);


    gen_times: for i in 0 to N_CLOCKS-1 generate
        signal edit: std_logic;
    begin
        edit <= editing and '1' when time_select = i else '0';
        time: entity work.time
        port map(
            clk_1s => clk_1s,
            rst => rst,
            h2 => h2s(i),
            h1 => h1s(i),
            m2 => m2s(i),
            s2 => s2s(i),
            m1 => m1s(i),
            s1 => s1s(i),
            h2_edit => h2_edit,
            h1_edit => h1_edit,
            m2_edit => m2_edit,
            s2_edit => s2_edit,
            m1_edit => m1_edit,
            s1_edit => s1_edit,
            edit => edit,
            edit_out => edit_out(i)
        );
    end generate gen_times;

    options: process (clk, rst) is
    begin
        if rst then
            time_select <= 0;
            edit_select <= 0;
            edit_val <= 0;
        end if;
        if rising_edge(clk) then
            edit_val <= 0;

            -- PB Edit
            --if editing then
            --    if edit_in then editing <= '0';
            --    end if;
            --elsif edit_in then editing <= '1';
            --end if;

            if right then
                if edit_select = 5 then edit_select <= 0;
                else edit_select <= edit_select + 1;
                end if;
            end if;
            if left then
                if edit_select = 0 then edit_select <= 5;
                else edit_select <= edit_select + 1;
                end if;
            end if;
            --if time_switch_in then
            --    if time_select = N_CLOCKS-1 then time_select <= 0;
            --    else time_select <= time_select + 1;
            --    end if;
            --end if;
            if up then edit_val <= 1;
            end if;
            if down then edit_val <= -1;
            end if;

            -- Editing
            if editing or edit_out(time_select) then
                case edit_select is
                when 5 =>
                    s1_edit <= adjust_clock_value(9, s1_edit, edit_val);
                when 4 =>
                    s2_edit <= adjust_clock_value(5, s2_edit, edit_val);
                when 3 =>
                    m1_edit <= adjust_clock_value(9, m1_edit, edit_val);
                when 2 =>
                    m2_edit <= adjust_clock_value(5, m2_edit, edit_val);
                when 1 =>
                    h1_edit <= adjust_clock_value(4, h1_edit, edit_val);
                when 0 =>
                    h2_edit <= adjust_clock_value(2, h2_edit, edit_val);
                end case;
            -- Done editing
            else -- If not editing get values
                h2_edit <= h2s(time_select);
                h1_edit <= h1s(time_select);
                m2_edit <= m2s(time_select);
                m1_edit <= m1s(time_select);
                s2_edit <= s2s(time_select);
                s1_edit <= s1s(time_select);
            end if;
        end if;
    end process options;

end alarm_clock;
