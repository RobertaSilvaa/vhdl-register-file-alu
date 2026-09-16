library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder_5_to_32 is
    port (
        address      : in  std_logic_vector(4 downto 0);
        write_enable : in  std_logic;
        enable_lines : out std_logic_vector(31 downto 0)
    );
end entity decoder_5_to_32;

architecture rtl of decoder_5_to_32 is
    function is_binary(value : std_logic_vector) return boolean is
    begin
        for index in value'range loop
            if value(index) /= '0' and value(index) /= '1' then
                return false;
            end if;
        end loop;

        return true;
    end function;
begin
    process (address, write_enable)
    begin
        enable_lines <= (others => '0');

        if write_enable = '1' and is_binary(address) then
            enable_lines(to_integer(unsigned(address))) <= '1';
        end if;
    end process;
end architecture rtl;
