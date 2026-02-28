library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;


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

    procedure UART_WRITE_BYTE (
        data_in: in  std_logic_vector(7 downto 0);
        signal bit: out std_logic) is
      begin
        bit <= '0';
        wait for PERIOD;

        for index in 0 to 7 loop
          bit <= data_in(index);
          wait for PERIOD;
        end loop;

        bit <= '1';
        wait for PERIOD;
    end procedure UART_WRITE_BYTE;
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

    --setup: process is
    --begin
    --    rst <= '0';

    --    finish;
    --end process setup;

    testing: process is
      begin

        -- Tell the UART to send a command.
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        tx_go   <= '1';
        tx_byte <= X"AB";
        wait until rising_edge(clk);
        tx_go   <= '0';
        wait until tx_done = '1';


        -- Send a command to the UART
        wait until rising_edge(clk);
        UART_WRITE_BYTE(X"3F", rx_bit);
        wait until rising_edge(clk);

        -- Check that the correct command was received
        if rx_byte = X"3F" then
          report "Test Passed - Correct Byte Received" severity note;
        else
          report "Test Failed - Incorrect Byte Received" severity note;
        end if;

        assert false report "Tests Complete" severity failure;

        finish;
      end process testing;

    test : process (clk, rst) is
        begin

        end process;
end uart_tb;
