library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    generic(
        CLKS: natural := 115
        );
    port (
        clk: in std_logic;
        bit_out: out std_logic;
        go: in std_logic;
        done: out std_logic;
        byte: in std_logic_vector(7 downto 0)
    );
end uart_tx;

architecture uart_tx of uart_tx is
    signal index: natural range 0 to 7 := 0;
    signal clk_count: natural range 0 to CLKS := 0;
    type uart_state is
        (IDLE, START, DATA, STOP);
    signal state: uart_state := IDLE;
    signal byte_out: std_logic_vector(7 downto 0);
begin
    sm: process(clk) is
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    -- RTL
                    done <= '0';
                    index <= 0;
                    clk_count <= 0;
                    bit_out <= '1';
                    if go = '1' then
                        byte_out <= byte;
                    end if;

                    -- NSL
                    if go = '1' then
                        state <= START;
                    end if;
                when START =>
                    -- RTL
                    bit_out <= '0';
                    clk_count <= clk_count + 1;
                    if clk_count = CLKS-1 then
                        clk_count <= 0;
                    end if;

                    -- NSL
                    if clk_count = CLKS-1 then
                        state <= DATA;
                    end if;
                when DATA =>
                    -- RTL
                    bit_out <= byte_out(index);
                    clk_count <= clk_count + 1;
                    if clk_count = CLKS-1 then
                        index <= index + 1;
                        clk_count <= 0;
                    end if;

                    -- NSL
                    if clk_count = CLKS-1 and index = 7 then
                        index <= 0;
                        state <= STOP;
                    end if;
                when STOP =>
                    -- RTL
                    bit_out <= '1';
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

end uart_tx;
