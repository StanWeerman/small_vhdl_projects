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
    signal sda_others: std_logic;
    signal sda_start: std_logic;
    signal sda_stop: std_logic;

    signal byte_r: std_logic_vector(7 downto 0);
    signal addr_r: std_logic_vector(6 downto 0);
    signal rw_r: std_logic;
    signal enable_r: std_logic;
    signal index: natural range 0 to 7;

    type i2c_state is
        (IDLE, START, ADDRESS, GETACK, SENDACK, DATA, STOP);
    signal state: i2c_state := IDLE;
begin
    scl <= '0' when scl_out = '0' else 'Z';
    sda_others <= '0' when sda_out = '0' else 'Z';
    sda_start <= '0' when sda_clk = '0' else 'Z';
    sda_stop <= 'Z' when sda_clk = '0' else '0';
    with state select
        sda <=  sda_start when start,
                sda_stop when stop,
                sda_others when others;

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

    enable_handling: process(clk) is
    begin
        if (rst) then
            enable_r <= '0';
        elsif rising_edge(clk) then
            if (state = STOP or state = DATA or (state = IDLE and enable_r /= '1')) then enable_r <= enable;
            end if;
        end if;
    end process enable_handling;

    state_machine : process(sda_clk) is
    begin
        if (rst) then
            sda_out <= '1';
            busy <= '0';
            index <= 7;
            error <= '0';
        elsif rising_edge(sda_clk) then
                case state is
                    when IDLE =>
                        -- NSL
                        if enable_r then state <= START;
                        end if;

                        -- RTL
                        if enable_r then
                            error <= '0';
                            busy <= '1';
                            addr_r <= addr;
                            rw_r <= rw;
                            index <= 7;
                        end if;
                    when START =>
                        -- NSL
                        state <= ADDRESS;

                        -- RTL
                        sda_out <= addr_r(index-1);
                        index <= index - 1;
                    when ADDRESS =>
                        -- NSL
                        if index = 0 then state <= GETACK;
                        end if;

                        -- RTL
                        if index = 0 then
                            sda_out <= rw_r;
                            byte_r <= byte_in;
                            index <= 7;
                        else
                            index <= index - 1;
                            sda_out <= addr_r(index-1);
                        end if;
                    when GETACK =>
                        -- NSL
                        --if sda /= '0' then state <= IDLE;
                        if (enable_r = '1' and rw_r = rw and addr_r = addr) then state <= DATA;
                        elsif enable_r then state <= START;
                        else state <= STOP;
                        end if;

                        -- RTL
                        index <= 6;
                        --if sda /= '0' then
                        --    error <= '1';
                        if (enable_r = '1' and rw_r = rw and addr_r = addr) then
                            if rw_r then
                                byte_r <= byte_in;
                                index <= index - 1;
                                sda_out <= byte_r(index);
                            else sda_out <= '1';
                            end if;
                        elsif enable_r then
                            busy <= '1';
                            error <= '0';
                            addr_r <= addr;
                            rw_r <= rw;
                            index <= 7;
                        end if;
                    when DATA =>
                        -- NSL
                        if index = 0 then
                            if rw_r then state <= GETACK;
                            else state <= SENDACK;
                            end if;
                        end if;

                        -- RTL
                        if (index /= 0) then index <= index - 1;
                        else index <= 7;
                        end if;
                        if rw_r then sda_out <= byte_r(index);
                        else
                            byte_out(index) <= '0' when sda = '0' else '1';
                            if index = 0 then sda_out <= '1'; -- Send '1' as ACK
                            end if;
                        end if;
                    when SENDACK =>
                        -- NSL
                        if (enable_r = '1' and rw_r = rw and addr_r = addr) then state <= DATA;
                        elsif (enable_r) then state <= START;
                        else state <= STOP;
                        end if;

                        -- RTL
                        index <= 6;
                        sda_out <= '1';
                        if (enable_r = '1' and rw_r = rw and addr_r = addr) then byte_r <= byte_in;
                        elsif (enable_r) then
                            busy <= '1';
                            error <= '0';
                            addr_r <= addr;
                            rw_r <= rw;
                            index <= 7;
                        end if;
                    when STOP =>
                        -- NSL
                        state <= IDLE;

                        -- RTL
                        busy <= '0';
                    when others =>
                end case;
        end if;
    end process state_machine;

end i2c_controller;
