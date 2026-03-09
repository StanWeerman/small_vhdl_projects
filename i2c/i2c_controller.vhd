library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity i2c_controller is
    generic(
        ICLK: natural := 10000000;
        BCLK: natural := 400000
        );
    port (
        clk, rst, enable: in std_logic;
        rw: in std_logic;
        addr: in std_logic_vector(6 downto 0);
        byte_in: in std_logic_vector(7 downto 0);
        byte_out: out std_logic_vector(7 downto 0);
        busy, error: out std_logic;
        scl, sda: inout std_logic
    );
end i2c_controller;

architecture i2c_controller of i2c_controller is
    constant period: integer := ICLK/BCLK;
    signal scl_out: std_logic;
    signal stretch_n: std_logic;

    signal sda_clk: std_logic;
    signal sda_out: std_logic;

    signal byte_r: std_logic_vector(7 downto 0);
    signal addr_r: std_logic_vector(6 downto 0);
    signal rw_r: std_logic;
    signal index: natural range 0 to 7;

    type i2c_state is
        (IDLE, START, ADDRESS, GETACK, SENDACK, DATA, STOP);
    signal state: i2c_state := IDLE;
begin
    scl <= '0' when scl_out = '0' else 'Z';
    sda <= '0' when sda_out = '0' else 'Z';

    clock_handling : process(clk) is
        variable clk_count: natural range 0 to ICLK/BCLK;
    begin
        if (rst) then
            clk_count := 0;
            stretch_n <= '1';
        elsif rising_edge(clk) then
            if (clk_count = period - 1) then clk_count := 0;
            elsif (stretch_n) then clk_count := clk_count + 1;
            end if;

            if (clk_count < period/2) then
                scl_out <= '0';
                if (clk_count < period/4) then sda_clk <= '0';
                else sda_clk <= '1';
                end if;
            else
                scl_out <= '1';
                if (scl = '0') then stretch_n <= '0';
                else stretch_n <= '1';
                end if;
                if (clk_count < period/2 + period/4) then sda_clk <= '1';
                else sda_clk <= '0';
                end if;
            end if;
        end if;
    end process clock_handling;

    state_machine : process(clk) is
    begin
        if (rst) then
            sda_out <= '0';
            busy <= '0';
            index <= 7;
        elsif rising_edge(clk) then
            if (rising_edge(sda_clk)) then
                sda_out <= sda_out xor '1';
                case state is
                    when IDLE =>
                        if (enable) then
                            busy <= '1';
                            addr_r <= addr;
                            rw_r <= rw;
                            state <= START;
                        end if;
                    when START =>
                        sda_out <= rw_r;
                        index <= index - 1;
                    when ADDRESS =>
                        sda_out <= addr_r(index);
                        index <= index - 1;
                        if (index = 0) then
                            byte_r <= byte_in;
                            state <= GETACK;
                            index <= 7;
                        end if;
                    when GETACK =>
                        index <= index - 1;
                        state <= DATA;
                        if rw_r then
                            sda_out <= byte_r(index);
                        else
                            sda_out <= '1';
                        end if;
                        if (enable) then
                            byte_r <= byte_in;
                            state <= DATA;
                        else state <= STOP;
                        end if;
                    when DATA =>
                        index <= index - 1;
                        if rw_r then
                            sda_out <= byte_r(index);
                            if (index = 0) then state <= GETACK;
                            end if;
                        else
                            if (index = 0) then
                                sda_out <= '1';
                                state <= SENDACK;
                            end if;
                        end if;
                    when SENDACK =>
                        index <= 6;
                        if (enable) then
                            byte_r <= byte_in;
                            state <= DATA;
                        else state <= STOP;
                        end if;
                    when STOP =>
                        busy <= '0';
                        state <= IDLE;
                    when others =>
                end case;
            end if;
        end if;
    end process state_machine;

end i2c_controller;
