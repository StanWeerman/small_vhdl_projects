library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;


entity alarm_clock_tb is
end alarm_clock_tb;

architecture alarm_clock_tb of alarm_clock_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    signal h2: natural range 0 to 2;
    signal h1: natural range 0 to 4;
    signal m2, s2: natural range 0 to 5;
    signal m1, s1: natural range 0 to 9;

    signal up, down, left, right, aedit_switch, edit_switch, center: std_logic := '0';
    signal rst_f, up_f, down_f, left_f, right_f: std_logic := '0';

    signal time_select: natural range 0 to 1 := 0;
    signal alarm_select: natural range 0 to 3 := 0;

    signal btns_fall: std_logic_vector(4 downto 0);

    procedure press_button (
        signal button : out std_logic
        ) is
        begin
            wait until rising_edge(clk);
            button <= '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            button <= '0';                -- Wait is OK here.
        end press_button;
begin
    alarm_clock: entity work.alarm_clock
    generic map(
        PERIOD => 1,
        N_CLOCKS => 2,
        N_ALARMS => 4
    )
    port map(
        clk => clk,
        rst => rst_f,
        up => up_f,
        down => down_f,
        left => left_f,
        right => right_f,
        editing => edit_switch,
        aediting => aedit_switch,
        h1 => h1,
        h2 => h2,
        m1 => m1,
        s1 => s1,
        m2 => m2,
        s2 => s2,
        time_select => time_select,
        alarm_select => alarm_select
    );

    falling_edge_detector_inst: entity work.falling_edge_detector
     generic map(
        PORT_WIDTH => 5
    )
     port map(
        clk => clk,
        signal_in => rst & right & left & down & up,
        signal_fall => btns_fall
    );
    rst_f <= btns_fall(4);
    right_f <= btns_fall(3);
    left_f <= btns_fall(2);
    down_f <= btns_fall(1);
    up_f <= btns_fall(0);

    clk <= not clk after 1 ps;

    setup: process is
    begin


        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        rst <= '0';

        edit_switch <= '1';
        press_button(up);
        press_button(right);
        press_button(up);
        press_button(up);
        press_button(up);
        press_button(up);

        edit_switch <= '0';

        wait for 10 ns;
        time_select <= 1;
        alarm_select <= 2;

        wait for 5 ns;

        aedit_switch <= '1';
        edit_switch <= '1';
        press_button(right);

        press_button(up);
        press_button(up);
        press_button(up);
        press_button(up);
        press_button(up);
        press_button(up);
        edit_switch <= '0';
        aedit_switch <= '0';

        wait for 1 ns;

        aedit_switch <= '1';
        edit_switch <= '1';
        press_button(right);

        press_button(up);
        press_button(up);
        press_button(up);
        press_button(up);
        press_button(up);
        press_button(up);
        edit_switch <= '0';
        aedit_switch <= '0';


        wait for 100 ns;
        finish;
    end process setup;

    test : process (clk, rst) is
        begin

        end process;
end alarm_clock_tb;
