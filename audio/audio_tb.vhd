library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity audio_tb is
end audio_tb;

architecture audio_tb of audio_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal enable: std_logic;
    signal cycle_done: std_logic;
    signal note: natural range 0 to 87;
    signal duty: natural range 0 to 99;
    signal AUD_PWM: std_logic;
    signal AUD_SD: std_logic;

    procedure test_note (
        constant note_in: in natural range 0 to 87;
        constant duty_in: in natural range 0 to 99;
        signal note_out: out natural range 0 to 87;
        signal duty_out: out natural range 0 to 99
    ) is
        begin
            note_out <= note_in;
            duty_out <= duty_in;
            wait until rising_edge(cycle_done);
            wait until rising_edge(cycle_done);
            wait until rising_edge(cycle_done);
            wait until rising_edge(cycle_done);
    end procedure test_note;
begin
    clk <= not clk after 1 ns;

    audio_inst: entity work.audio
     generic map(
        IFREQ => 1000000,
        AFREQ => 31250
    )
     port map(
        rst => rst,
        clk => clk,
        enable => enable,
        cycle_done => cycle_done,
        note => note,
        duty => duty,
        AUD_PWM => AUD_PWM,
        AUD_SD => AUD_SD
    );

    testing: process is
    begin
        rst <= '0';
        note <= 1;
        duty <= 50;
        enable <= '1';

        for i in 0 to 87 loop
            test_note(i, 50, note, duty);
        end loop;

        --test_note(0, 50, note, duty);
        --test_note(1, 50, note, duty);
        --test_note(44, 50, note, duty);
        --test_note(80, 50, note, duty);
        --test_note(87, 50, note, duty);

        report "Tests Complete";

        finish;
    end process testing;

end audio_tb;
