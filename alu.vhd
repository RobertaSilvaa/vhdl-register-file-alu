library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        operand_a     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        operand_b     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        function_code : in  std_logic_vector(2 downto 0);
        result        : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        overflow      : out std_logic
    );
end entity alu;

architecture rtl of alu is
begin
    process (operand_a, operand_b, function_code)
        variable a_unsigned       : unsigned(DATA_WIDTH - 1 downto 0);
        variable b_unsigned       : unsigned(DATA_WIDTH - 1 downto 0);
        variable addition_result  : unsigned(DATA_WIDTH downto 0);
        variable multiply_result  : unsigned((2 * DATA_WIDTH) - 1 downto 0);
    begin
        a_unsigned := unsigned(operand_a);
        b_unsigned := unsigned(operand_b);

        result   <= (others => '0');
        overflow <= '0';

        case function_code is
            -- Unsigned addition. Overflow is the carry-out bit.
            when "000" =>
                addition_result := resize(a_unsigned, DATA_WIDTH + 1) +
                                   resize(b_unsigned, DATA_WIDTH + 1);
                result   <= std_logic_vector(addition_result(DATA_WIDTH - 1 downto 0));
                overflow <= addition_result(DATA_WIDTH);

            -- Unsigned subtraction. Overflow indicates an unsigned borrow.
            when "001" =>
                result <= std_logic_vector(a_unsigned - b_unsigned);

                if a_unsigned < b_unsigned then
                    overflow <= '1';
                else
                    overflow <= '0';
                end if;

            -- Unsigned multiplication. Overflow indicates truncated upper bits.
            when "010" =>
                multiply_result := a_unsigned * b_unsigned;
                result <= std_logic_vector(multiply_result(DATA_WIDTH - 1 downto 0));

                if multiply_result((2 * DATA_WIDTH) - 1 downto DATA_WIDTH) /=
                   to_unsigned(0, DATA_WIDTH) then
                    overflow <= '1';
                else
                    overflow <= '0';
                end if;

            when "011" =>
                result <= operand_a and operand_b;

            when "100" =>
                result <= operand_a or operand_b;

            when "101" =>
                result <= not operand_a;

            -- Function codes 110 and 111 are unsupported.
            when others =>
                result   <= (others => '0');
                overflow <= '1';
        end case;
    end process;
end architecture rtl;
