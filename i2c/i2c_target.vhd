library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity i2c_target is
    generic(
        ICLK: natural := 10000000;
        BCLK: natural := 400000
        );
    port (
        clk, rst: in std_logic;
        addr: in std_logic_vector(6 downto 0);
        byte_in: in std_logic_vector(7 downto 0);
        byte_out: out std_logic_vector(7 downto 0);
        busy, error: out std_logic;
        scl, sda: inout std_logic
    );
end i2c_target;

architecture i2c_target of i2c_target is
    constant period: integer := ICLK/BCLK;
    signal scl_out: std_logic;
    signal stretch_n: std_logic;

    signal scl_clk: std_logic;
    signal sda_clk: std_logic;
    signal sda_out: std_logic;
    signal sda_others: std_logic;
    signal sda_start: std_logic;
    signal sda_stop: std_logic;
    signal sda_prev: std_logic;
    signal sda_in: std_logic;
    signal sda_in_r: std_logic;

    signal byte_r: std_logic_vector(7 downto 0);
    signal addr_r: std_logic_vector(6 downto 0);
    signal rw_r: std_logic;
    signal enable_r: std_logic;
    signal index: natural range 0 to 7;

    signal stop_s, start_s: std_logic;

    type i2c_state is
        (IDLE, START, ADDRESS, GETACK, SENDACK, DATA, STOP);
    signal state: i2c_state := IDLE;
begin
    scl_clk <= '0' when scl = '0' else '1';
    sda_in <= '0' when sda = '0' else '1';
    scl <= '0' when scl_out = '0' else 'Z';
    sda_others <= '0' when sda_clk = '0' and sda_out = '0' else 'Z';
    sda_start <= '0' when sda_clk = '0' else 'Z';
    sda_stop <= 'Z' when sda_clk = '0' else '0';
    with state select
        sda <=
                --sda_start when start,
                --sda_stop when stop,
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
            addr_r <= (others => '0');
            start_s <= '0';
            stop_s <= '0';
        elsif rising_edge(clk) then
            addr_r <= addr;
            sda_prev <= sda_in;

            if scl = 'Z' then
                if (sda_prev = '1' and sda_in = '0') then start_s <= '1';
                elsif (sda_prev = '0' and sda_in = '1') then stop_s <= '0';
                end if;
            end if;
            if state /= SENDACK and state /= data and state /= stop then stop_s <= '0';
            end if;
            if state /= idle and state /= start then start_s <= '0';
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
                        if start_s then state <= START;
                        end if;

                        -- RTL
                        if start_s then
                            error <= '0';
                            busy <= '1';
                            index <= 7;
                        end if;
                    when START =>
                        -- NSL
                        if (addr_r(index-1)) /= sda_in then state <= IDLE;
                        else state <= ADDRESS;
                        end if;

                        -- RTL
                        index <= index - 1;
                    when ADDRESS =>
                        -- NSL
                        if index = 0 then state <= DATA;
                        elsif (addr_r(index-1)) /= sda_in then state <= IDLE;
                        end if;

                        -- RTL
                        if index = 0 then
                            sda_out <= '1';
                            rw_r <= sda_in;
                            index <= 7;
                        else
                            index <= index - 1;
                        end if;
                    when SENDACK =>
                        -- NSL
                        if (stop_s) then state <= STOP;
                        elsif (start_s) then state <= START;
                        else state <= DATA;
                        end if;

                        -- RTL
                        sda_out <= '1';
                        index <= 6;
                        if (start_s) then
                            busy <= '1';
                            error <= '0';
                            index <= 7;
                        elsif (not stop_s) then
                            if (not rw_r) then byte_r <= byte_in;
                            end if;
                        end if;
                    when DATA =>
                        -- NSL
                        if stop_s then state <= STOP;
                        elsif index = 0 then
                            if rw_r then state <= SENDACK;
                            else state <= GETACK;
                            end if;
                        end if;

                        -- RTL
                        sda_out <= '1';
                        if (rw_r) then byte_out(index) <= sda_in;
                        else sda_out <= byte_r(index);
                        end if;

                        if (index /= 0) then index <= index - 1;
                        else
                            if (rw_r) then sda_out <= '1';
                            --else sda_out <= byte_r(index);
                            end if;
                            index <= 7;
                        end if;
                    when GETACK =>
                        -- NSL
                        if sda /= '0' then state <= IDLE;
                        elsif (stop_s) then state <= STOP;
                        elsif (start_s) then state <= START;
                        else state <= DATA;
                        end if;

                        -- RTL
                        index <= 6;
                        if sda /= '0' then
                            error <= '1';
                        elsif (start_s) then
                            busy <= '1';
                            error <= '0';
                            index <= 7;
                        elsif (not stop_s) then
                            if (not rw_r) then byte_r <= byte_in;
                            end if;
                        else
                        index <= 7;
                            if (not rw_r) then byte_r <= byte_in;
                            end if;
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

end i2c_target;
