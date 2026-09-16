library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture test of alu_tb is
    constant DATA_WIDTH : positive := 8;

    signal operand_a     : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal operand_b     : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal function_code : std_logic_vector(2 downto 0) := (others => '0');
    signal result        : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal overflow      : std_logic;
begin
    dut : entity work.alu
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            operand_a     => operand_a,
            operand_b     => operand_b,
            function_code => function_code,
            result        => result,
            overflow      => overflow
        );

    stimulus : process
    begin
        -- Addition without carry-out: 10 + 20 = 30.
        operand_a <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
        operand_b <= std_logic_vector(to_unsigned(20, DATA_WIDTH));
        function_code <= "000";
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(30, DATA_WIDTH)
            report "Addition result is incorrect."
            severity error;
        assert overflow = '0'
            report "Unexpected addition overflow."
            severity error;

        -- Addition with carry-out: 250 + 10 = 260 -> 4 with carry.
        operand_a <= std_logic_vector(to_unsigned(250, DATA_WIDTH));
        operand_b <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
        function_code <= "000";
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(4, DATA_WIDTH)
            report "Addition truncation is incorrect."
            severity error;
        assert overflow = '1'
            report "Missing addition carry-out."
            severity error;

        -- Subtraction without borrow.
        operand_a <= std_logic_vector(to_unsigned(20, DATA_WIDTH));
        operand_b <= std_logic_vector(to_unsigned(7, DATA_WIDTH));
        function_code <= "001";
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(13, DATA_WIDTH)
            report "Subtraction result is incorrect."
            severity error;
        assert overflow = '0'
            report "Unexpected subtraction borrow."
            severity error;

        -- Subtraction with borrow: 3 - 5 wraps to 254.
        operand_a <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
        operand_b <= std_logic_vector(to_unsigned(5, DATA_WIDTH));
        function_code <= "001";
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(254, DATA_WIDTH)
            report "Subtraction wraparound is incorrect."
            severity error;
        assert overflow = '1'
            report "Missing subtraction borrow."
            severity error;

        -- Multiplication without truncation.
        operand_a <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
        operand_b <= std_logic_vector(to_unsigned(12, DATA_WIDTH));
        function_code <= "010";
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(120, DATA_WIDTH)
            report "Multiplication result is incorrect."
            severity error;
        assert overflow = '0'
            report "Unexpected multiplication overflow."
            severity error;

        -- Multiplication with upper bits set.
        operand_a <= std_logic_vector(to_unsigned(20, DATA_WIDTH));
        operand_b <= std_logic_vector(to_unsigned(20, DATA_WIDTH));
        function_code <= "010";
        wait for 1 ns;

        assert unsigned(result) = to_unsigned(144, DATA_WIDTH)
            report "Multiplication truncation is incorrect."
            severity error;
        assert overflow = '1'
            report "Missing multiplication overflow."
            severity error;

        operand_a <= x"AA";
        operand_b <= x"0F";

        function_code <= "011";
        wait for 1 ns;
        assert result = x"0A"
            report "AND result is incorrect."
            severity error;

        function_code <= "100";
        wait for 1 ns;
        assert result = x"AF"
            report "OR result is incorrect."
            severity error;

        function_code <= "101";
        wait for 1 ns;
        assert result = x"55"
            report "NOT result is incorrect."
            severity error;

        function_code <= "110";
        wait for 1 ns;
        assert result = x"00" and overflow = '1'
            report "Unsupported function-code behavior is incorrect."
            severity error;

        report "ALU testbench completed successfully." severity note;
        wait;
    end process;
end architecture test;
