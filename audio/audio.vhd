library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity audio is
    generic (
        IFREQ: natural;
        AFREQ: natural
    );
    port (
        rst, clk, enable: in std_logic;
        cycle_done: out std_logic;
        duty: in natural range 0 to 99;
        note: in natural range 0 to 87;
        AUD_PWM: out std_logic;
        AUD_SD: out std_logic
    );
end audio;

architecture audio of audio is
    --constant CLKS: natural := IFREQ/AFREQ;
    signal clks: natural;
    signal clk_count: natural;
    signal period: natural;
    signal PWM: std_logic;

    constant NUM_NOTES: natural := 88;
    type freqs_array is array (NUM_NOTES-1 downto 0) of natural;

    function init_freqs return freqs_array is
        variable temp_freqs: freqs_array;
        variable temp_real : real;
    begin
            for i in temp_freqs'range loop
                temp_real := 2.0 ** ((real(i)+1.0-49.0)/12.0);
                temp_freqs(i) := natural(temp_real * 440.0); -- Get frequency for the note
            end loop;
            return temp_freqs;
    end function;

    constant NOTE_FREQS: freqs_array := init_freqs;

    type clks_array is array (NUM_NOTES-1 downto 0) of natural;

    function init_clks return clks_array is
        variable temp_clks: clks_array;
    begin
            for i in temp_clks'range loop
                temp_clks(i) := IFREQ / NOTE_FREQS(i); -- Get clks for the note
            end loop;
            return temp_clks;
    end function;

    constant NOTE_CLKS: clks_array := init_clks;
    signal freq: natural;
begin
    AUD_SD <= enable;
    AUD_PWM <= '0' when PWM = '0' else 'Z';

    cycle_done <= '1' when clk_count = 0 else '0';

    freq <= NOTE_FREQS(note);
    clks <= IFREQ / NOTE_FREQS(note);
    --clks <= NOTE_CLKS(note);
    --with duty select
        period <= (clks/100)*(duty+1);

    pmw: process (clk, rst) is
    begin
        if (rst) then
            PWM <= '0';
            clk_count <= 0;
        elsif (rising_edge(CLK)) then
            if (clk_count = CLKS or clk_count >= CLKS*2) then clk_count <= 0;
            else clk_count <= clk_count + 1;
            end if;
            if (clk_count <= period) then
                PWM <= '1';
            else PWM <= '0';
            end if;
        end if;
    end process pmw;

end audio;
