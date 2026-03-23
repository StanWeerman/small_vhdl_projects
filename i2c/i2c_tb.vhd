library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity i2c_tb is
end i2c_tb;

architecture i2c_tb of i2c_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal enable: std_logic;

    signal rw: std_logic;
    signal addr: std_logic_vector(6 downto 0);
    signal byte_in: std_logic_vector(7 downto 0);
    signal byte_out: std_logic_vector(7 downto 0);
    signal busy, error: std_logic;
    signal scl, sda: std_logic;

    signal addr_t: std_logic_vector(6 downto 0);
    signal byte_in_t: std_logic_vector(7 downto 0);
    signal byte_out_t: std_logic_vector(7 downto 0);
    signal busy_t, error_t: std_logic;

    constant ICLK: natural := 10000000;
    constant BCLK: natural := 400000;


    procedure write_byte (
        constant address: in std_logic_vector(6 downto 0);
        constant byte: in std_logic_vector(7 downto 0);
        signal addr_out : out std_logic_vector(6 downto 0);
        signal byte_out: out std_logic_vector(7 downto 0);
        signal rw: out std_logic;
        signal enable: out std_logic
    ) is
    begin
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        enable <= '1';
        addr_out <= address;
        byte_out <= byte;
        rw <= '1';
        wait until busy = '1';
        enable <= '0';
        wait until busy = '0';
    end procedure write_byte;
begin
    clk <= not clk after 1 ns;

    i2c_controller: entity work.i2c_controller
     generic map(
        ICLK => ICLK,
        BCLK => BCLK
    )
     port map(
        clk => clk,
        rst => rst,
        enable => enable,
        rw => rw,
        addr => addr,
        byte_in => byte_in,
        byte_out => byte_out,
        busy => busy,
        error => error,
        scl => scl,
        sda => sda
    );

    i2c_target: entity work.i2c_target
     generic map(
        ICLK => ICLK,
        BCLK => BCLK
    )
     port map(
        clk => clk,
        rst => rst,
        addr => addr_t,
        byte_in => byte_in_t,
        byte_out => byte_out_t,
        busy => busy_t,
        error => error_t,
        scl => scl,
        sda => sda
    );

    testing: process is
    begin
        rst <= '0';

        addr_t <= "1001001";
        write_byte("1001001", "01010101", addr, byte_in, rw, enable);

        write_byte("0010010", "10101010", addr, byte_in, rw, enable);
        --wait for 500 ns;

        report "Tests Complete";

        finish;
    end process testing;

end i2c_tb;
