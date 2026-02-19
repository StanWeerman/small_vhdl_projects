library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;


entity ssd_tb is
end ssd_tb;

architecture ssd_tb of ssd_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal ca: std_logic_vector(7 downto 0);
    signal an: std_logic_vector(7 downto 0);
    signal byte_0, byte_1, byte_2, byte_3: std_logic_vector(7 downto 0);
    signal div_clk: std_logic_vector (26 downto 0);
    signal tb_clk: std_logic;
begin
    tb_clk <= div_clk(4);
    clk <= not clk after 1 ps;

    ssd_inst: entity work.ssd
     generic map(
        SSD_NUM => 8,
        CLK_START => 2
    )
     port map(
        clk => clk,
        rst => rst,
        ca => ca,
        an => an,
        input => byte_0 & byte_1 & byte_2 & byte_3
    );

    inc_tb_clk: process(clk, rst) is
    begin
        if (rst) then
            div_clk <= (others => '0');
        end if;
        if rising_edge(clk) then
            div_clk <= std_logic_vector(unsigned(div_clk) + 1);
        end if;
    end process inc_tb_clk;

    setup: process is
    begin
        rst <= '0';
        byte_0 <= "00010010";
        byte_1 <= "00110100";
        byte_2 <= "01010110";
        byte_3 <= "01111000";

        wait for 100 ns;
        finish;
    end process setup;

    test : process (tb_clk, rst) is
        begin

        end process;
end ssd_tb;
