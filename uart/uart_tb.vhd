library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uart_tb is
end uart_tb;

architecture uart_tb of uart_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    constant CLKS: natural := 87;
    constant PERIOD: time := 8680 ns;

    signal rx_bit, rx_done: std_logic;
    signal rx_byte: std_logic_vector(7 downto 0);

    signal tx_bit, tx_done, tx_go: std_logic;
    signal tx_byte: std_logic_vector(7 downto 0);

    procedure test_byte (
        constant byte: in std_logic_vector(7 downto 0);
        signal byte_out: out std_logic_vector(7 downto 0);
        signal go: out std_logic
    ) is
        begin
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            go   <= '1';
            byte_out <= byte;
            wait until rising_edge(clk);
            go   <= '0';
            wait until tx_done = '1';

            assert rx_byte = tx_byte report "Incorrect Byte, expected <" &  to_hex_string(tx_byte) & ">, received <" & to_hex_string(rx_byte) & ">";
    end procedure test_byte;
begin
    clk <= not clk after 50 ns;

    uart_rx: entity work.uart_rx
     generic map(
        CLKS => CLKS
    )
     port map(
        clk => clk,
        bit_in => rx_bit,
        done => rx_done,
        byte => rx_byte
    );

    rx_bit <= tx_bit;

    uart_tx: entity work.uart_tx
     generic map(
        CLKS => CLKS
    )
     port map(
        clk => clk,
        bit_out => tx_bit,
        go => tx_go,
        done => tx_done,
        byte => tx_byte
    );

    testing: process is
        variable seed1, seed2 : integer := 999;
        variable r : real;
        variable random_byte : std_logic_vector(7 downto 0);
      begin


        for index in 1 to 100 loop
            for i in random_byte'range loop
                uniform(seed1, seed2, r);
                random_byte(i) := '1' when r > 0.5 else '0';
            end loop;
            test_byte(random_byte, tx_byte, tx_go);
        end loop;


        report "Tests Complete";

        finish;
      end process testing;

end uart_tb;
