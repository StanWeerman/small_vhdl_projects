library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic(
        CLKS: natural := 115
        );
    port (
        clk: in std_logic;
        bit_in: in std_logic;
        done: out std_logic;
        byte: out std_logic_vector(7 downto 0)
    );
end uart_rx;

architecture uart_rx of uart_rx is
    signal bit_in_r, bit_in_rr: std_logic;
    signal index: natural range 0 to 7 := 0;
    signal clk_count: natural range 0 to CLKS := 0;
    type uart_state is
        (IDLE, START, DATA, STOP);
    signal state: uart_state := IDLE;
begin
    get: process(clk) is
    begin
        if rising_edge(clk) then
            bit_in_r <= bit_in;
            bit_in_rr <= bit_in_r;
        end if;
    end process get;

    sm: process(clk) is
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    -- RTL
                    done <= '0';
                    index <= 0;
                    clk_count <= 0;

                    -- NSL
                    if bit_in_rr = '0' then
                        state <= START;
                    end if;
                when START =>
                    -- RTL
                    clk_count <= clk_count + 1;
                    if clk_count = (CLKS-1)/2 then
                        clk_count <= 0;
                    end if;

                    -- NSL
                    if clk_count = (CLKS-1)/2 then
                        if bit_in_rr = '0' then
                            state <= DATA;
                        elsif bit_in_rr = '1' then state <= IDLE;
                        end if;
                    end if;
                when DATA =>
                    -- RTL
                    clk_count <= clk_count + 1;
                    if clk_count = CLKS-1 then
                        byte(index) <= bit_in_rr;
                        if index /= 7 then
                            index <= index + 1;
                        end if;
                        clk_count <= 0;
                    end if;

                    -- NSL
                    if clk_count = CLKS-1 and index = 7 then
                        index <= 0;
                        state <= STOP;
                    end if;
                when STOP =>
                    -- RTL
                    clk_count <= clk_count + 1;
                    if clk_count = CLKS-1 then
                        done <= '1';
                        clk_count <= 0;
                    end if;

                    -- NSL
                    if clk_count = CLKS-1 then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process sm;

end uart_rx;
