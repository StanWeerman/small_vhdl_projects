-- half_adder.vhd

library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
  port (a, b, c_in : in std_logic;
        sum, c_out : out std_logic
    );
end full_adder;

architecture full_adder of full_adder is
begin
  sum <= (a xor b) xor c_in;
  c_out <= ((a xor b) and c_in) or (a and b);
end full_adder;
