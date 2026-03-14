library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity audio is
    generic (
        IFREQ: natural;
        AFREQ: natural
    );
    port (
        rst, clk, enable: in std_logic;
        cycle_done: out std_logic;
        note: in natural range 0 to 11;
        AUD_PWM: out std_logic;
        AUD_SD: out std_logic
    );
end audio;

architecture audio of audio is
    constant CLKS: natural := IFREQ/AFREQ;
    signal clk_count: natural range 0 to CLKS;
    signal period: natural range 0 to CLKS;
    signal PWM: std_logic;
begin
    AUD_SD <= enable;
    AUD_PWM <= '0' when PWM = '0' else 'Z';

    cycle_done <= '1' when clk_count = 0 else '0';
    --with note select
        period <= CLKS/(note) when note /= 0 else 0;

    pmw: process (clk, rst) is
    begin
        if (rst) then
            PWM <= '0';
            clk_count <= 0;
        elsif (rising_edge(CLK)) then
            if (clk_count = CLKS) then clk_count <= 0;
            else clk_count <= clk_count + 1;
            end if;
            if (clk_count <= period) then
                PWM <= '1';
            else PWM <= '0';
            end if;
        end if;
    end process pmw;

end audio;
