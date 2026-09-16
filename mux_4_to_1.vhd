library ieee;
use ieee.std_logic_1164.all;

entity mux_4_to_1 is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        input_a      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        input_b      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        input_c      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        input_d      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        select_lines : in  std_logic_vector(1 downto 0);
        output_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity mux_4_to_1;

architecture rtl of mux_4_to_1 is
begin
    with select_lines select
        output_data <= input_a when "00",
                       input_b when "01",
                       input_c when "10",
                       input_d when "11",
                       (others => '0') when others;
end architecture rtl;
