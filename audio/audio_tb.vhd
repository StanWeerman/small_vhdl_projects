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
    signal note: natural range 0 to 11;
    signal AUD_PWM: std_logic;
    signal AUD_SD: std_logic;
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
        AUD_PWM => AUD_PWM,
        AUD_SD => AUD_SD
    );

    testing: process is
    begin
        rst <= '0';
        note <= 1;
        enable <= '1';

        wait until rising_edge(cycle_done);
        wait until rising_edge(cycle_done);
        wait until rising_edge(cycle_done);
        wait until rising_edge(cycle_done);

        note <= 2;

        wait until rising_edge(cycle_done);
        wait until rising_edge(cycle_done);
        wait until rising_edge(cycle_done);
        wait until rising_edge(cycle_done);

        report "Tests Complete";

        finish;
    end process testing;

end audio_tb;
