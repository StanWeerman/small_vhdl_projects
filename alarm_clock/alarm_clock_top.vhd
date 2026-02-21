library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;


entity alarm_clock_top is
    Port (
        CLK100MHZ: in std_logic;
        sw: in std_logic_vector(15 downto 0);
        BtnC, BtnU, BtnL, BtnR, BtnD: in std_logic;
        LED: out std_logic_vector(15 downto 0);
        ca: out std_logic_vector(7 downto 0);
        an: out std_logic_vector(7 downto 0);
        LED16_R: out  std_logic;
        LED16_G: out  std_logic;
        LED16_B: out  std_logic;
        LED17_R: out  std_logic;
        LED17_G: out  std_logic;
        LED17_B: out  std_logic
        --micClk: out std_logic;
        --micLRSel: out std_logic;
        --micData: in std_logic;
        --ampPWM: out std_logic;
        --ampSD: out std_logic
        );
end alarm_clock_top;

architecture alarm_clock_top of alarm_clock_top is
    --signal clk: std_logic := '0';
    --signal rst: std_logic := '1';

    signal h2: natural range 0 to 2;
    signal h1: natural range 0 to 4;
    signal m2, s2: natural range 0 to 5;
    signal m1, s1: natural range 0 to 9;

    -- Button Handling
    signal btns_debounce, btns_fall: std_logic_vector(4 downto 0);
begin
    LED <= SW;

    -- Instantiate Debouncer
    debouncer_inst: entity work.debouncer
     generic map(
        DEBNC_CLOCKS => (2**16),
        PORT_WIDTH => 5
    )
     port map(
        SIGNAL_I => BtnU & BtnD & BtnL & BtnR & BtnC,
        CLK_I => CLK100MHZ,
        SIGNAL_O => btns_debounce
    );

    -- Instantiate Falling Edge Detector
    falling_edge_detector_inst: entity work.falling_edge_detector
     generic map(
        PORT_WIDTH => 5
    )
     port map(
        clk => CLK100MHZ,
        SIGNAL_IN => btns_debounce,
        SIGNAL_FALL => btns_fall
    );

    -- Instantiate Alarm Clock
    alarm_clock: entity work.alarm_clock
    generic map(
        PERIOD => 1,
        N_CLOCKS => 4
    )
    port map(
        clk => CLK100MHZ,
        rst => btns_fall(4),
        up => btns_fall(0),
        down => btns_fall(1),
        left => btns_fall(2),
        right => btns_fall(3),
        editing => sw(0),
        h1 => h1,
        h2 => h2,
        m1 => m1,
        s1 => s1,
        m2 => m2,
        s2 => s2,
        time_select => to_integer(unsigned(sw(2 downto 1)))
    );

    --Instantiate SSD
    ssd_inst: entity work.ssd
     generic map(
        SSD_NUM => 8,
        CLK_START => 19
    )
     port map(
        clk => CLK100MHZ,
        rst => BtnC,
        ca => ca,
        an => an,
        input => X"00" & std_logic_vector(to_unsigned(h2, 4) & to_unsigned(h1, 4) & to_unsigned(m2, 4) & to_unsigned(m1, 4) & to_unsigned(s2, 4) & to_unsigned(s1, 4))
    );

end alarm_clock_top;
