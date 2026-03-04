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
        clk: in std_logic;
        rst: in std_logic := '1';
        up, down, left, right: in std_logic;
        editing, aediting: std_logic;

        h2: out natural range 0 to 2;
        h1: out natural range 0 to 4;
        m2, s2: out natural range 0 to 5;
        m1, s1: out natural range 0 to 9;
        alarm_1, alarm_2: out std_logic;
        time_select: in natural range 0 to N_CLOCKS-1;
        alarm_select: in natural range 0 to N_ALARMS-1;
        alarm_active: out std_logic;
        signal edit_select: out natural range 0 to 5
    );
end alarm_clock;

architecture alarm_clock of alarm_clock is
    signal div_clk: std_logic_vector(26 downto 0);
    signal clk_1s: std_logic;
    signal clk_1s_f: std_logic_vector(0 downto 0);

    signal edit_prev: std_logic;

    type three_array is array (0 to N_CLOCKS-1) of natural range 0 to 2;
    type five_array is array (0 to N_CLOCKS-1) of natural range 0 to 4;
    type six_array is array (0 to N_CLOCKS-1) of natural range 0 to 5;
    type ten_array is array (0 to N_CLOCKS-1) of natural range 0 to 9;
    signal h2s: three_array;
    signal h1s: five_array;
    signal m2s, s2s: six_array;
    signal m1s, s1s: ten_array;

    type athree_array is array (0 to N_CLOCKS-1, 0 to N_ALARMS-1) of natural range 0 to 2;
    type afive_array is array (0 to N_CLOCKS-1, 0 to N_ALARMS-1) of natural range 0 to 4;
    type asix_array is array (0 to N_CLOCKS-1, 0 to N_ALARMS-1) of natural range 0 to 5;
    type aten_array is array (0 to N_CLOCKS-1, 0 to N_ALARMS-1) of natural range 0 to 9;
    type alarm_array is array (0 to N_CLOCKS-1) of std_logic_vector(0 to N_ALARMS-1);

    signal ah2s: athree_array;
    signal ah1s: afive_array;
    signal am2s: asix_array;
    signal am1s: aten_array;
    signal alarm_bits: alarm_array;
    signal set: std_logic;

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

    -- Instantiate Falling Edge Detector for Clk
    falling_edge_detector_inst: entity work.falling_edge_detector
     generic map(
        PORT_WIDTH => 1
    )
     port map(
        clk => clk,
        SIGNAL_IN => (0 => clk_1s),
        SIGNAL_FALL => clk_1s_f
    );

    h2 <= h2s(time_select) when not aediting else ah2s(time_select, alarm_select);
    h1 <= h1s(time_select) when not aediting else ah1s(time_select, alarm_select);
    m2 <= m2s(time_select)when not aediting else am2s(time_select, alarm_select);
    m1 <= m1s(time_select)when not aediting else am1s(time_select, alarm_select);
    s2 <= s2s(time_select)when not aediting else 0;
    s1 <= s1s(time_select)when not aediting else 0;


    gen_times: for t_index in 0 to N_CLOCKS-1 generate
        signal edit: std_logic;
    begin
        edit <= editing and not aediting and '1' when time_select = t_index else '0';
        time: entity work.time
        port map(
            clk_1s => clk_1s_f(0),
            clk => clk,
            rst => rst,
            h2 => h2s(t_index),
            h1 => h1s(t_index),
            m2 => m2s(t_index),
            s2 => s2s(t_index),
            m1 => m1s(t_index),
            s1 => s1s(t_index),
            h2_edit => h2_edit,
            h1_edit => h1_edit,
            m2_edit => m2_edit,
            s2_edit => s2_edit,
            m1_edit => m1_edit,
            s1_edit => s1_edit,
            edit => edit
        );

        gen_alarms: for a_index in 0 to N_ALARMS-1 generate
            signal a_match, aedit: std_logic;
            signal h2_in: natural range 0 to 2;
            signal h1_in: natural range 0 to 4;
            signal m2_in, s2_edit: natural range 0 to 5;
            signal m1_in, s1_edit: natural range 0 to 9;
        begin
            a_match <= '1' when alarm_select = a_index else '0';
            aedit <= editing and aediting and a_match;
            h2_in <= h2_edit when aedit else h2s(t_index);
            h1_in <= h1_edit when aedit else h1s(t_index);
            m2_in <= m2_edit when aedit else m2s(t_index);
            m1_in <= m1_edit when aedit else m1s(t_index);


            alarm_inst: entity work.alarm
            port map(
                clk => clk,
                clk_1s => clk_1s_f(0),
                rst => rst,
                h2 => ah2s(t_index, a_index),
                h1 => ah1s(t_index, a_index),
                m2 => am2s(t_index, a_index),
                m1 => am1s(t_index, a_index),
                h2_in => h2_in,
                h1_in => h1_in,
                m2_in => m2_in,
                m1_in => m1_in,
                edit => aedit,
                alarm_out => alarm_bits(t_index)(a_index)
            );
        end generate gen_alarms;

    end generate gen_times;

    options: process (clk, rst) is
        variable edit_val: integer range -1 to 1;
    begin
        if rst then
            edit_select <= 0;
            edit_val := 0;
        end if;
        if rising_edge(clk) then
            edit_val := 0;

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
                else edit_select <= edit_select - 1;
                end if;
            end if;
            --if time_switch_in then
            --    if time_select = N_CLOCKS-1 then time_select <= 0;
            --    else time_select <= time_select + 1;
            --    end if;
            --end if;
            if up then edit_val := 1;
            end if;
            if down then edit_val := -1;
            end if;

            edit_prev <= editing;

            -- Editing
            if edit_prev and editing then
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
                if (not aediting) then
                    h2_edit <= h2s(time_select);
                    h1_edit <= h1s(time_select);
                    m2_edit <= m2s(time_select);
                    m1_edit <= m1s(time_select);
                    s2_edit <= s2s(time_select);
                    s1_edit <= s1s(time_select);
                else
                    h2_edit <= ah2s(time_select, alarm_select);
                    h1_edit <= ah1s(time_select, alarm_select);
                    m2_edit <= am2s(time_select, alarm_select);
                    m1_edit <= am1s(time_select, alarm_select);
                    s2_edit <= 0;
                    s1_edit <= 0;
                end if;
            end if;
        end if;
    end process options;

    alarm: process (all) is
        constant ALL_ZEROS_CLOCKS : std_logic_vector(N_CLOCKS-1 downto 0) := (others => '0');
        constant ALL_ZEROS_ALARMS : std_logic_vector(N_ALARMS-1 downto 0) := (others => '0');
        variable alarm_out_vec: std_logic_vector(N_CLOCKS-1 downto 0);
    begin
        for index in 0 to N_CLOCKS-1 loop
            alarm_out_vec(index) := '0' when alarm_bits(index) = ALL_ZEROS_ALARMS else '1';
        end loop;
        alarm_active <= '0' when alarm_out_vec = ALL_ZEROS_CLOCKS else '1';
    end process alarm;

end alarm_clock;
