//	Copyright (C) 2012-2013, 2018 Vaptistis Anogeianakis <nomad@cornercase.gr>
/*
 *	This file is part of DOP Parser.
 *
 *	DOP Parser is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	DOP Parser is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with DOP Parser.  If not, see <http://www.gnu.org/licenses/>.
 */
import std.array, std.range, std.exception;
import ast, testUtilities;

// Symbolic names for error messages generated by parsePostfixExpression
// Note that in order to keep variable names reasonably short, the semantics had
// to be oversimplified and in some situations the name can be misleading. It's
// the string value itself that adequately describes the situation.
private immutable stack_not_exhausted = "Unconsumed trailing symbols remained in the input!";
private immutable insufficient_operands = "There aren't enough operands for this operator to be applied!";

// operators is a map from operator name to number of operands.
Expression parsePostfixExpression(const int[string] operators, string input)
{
	Expression[] stack;

	foreach(token; std.array.split(input))
	{
		if(token !in operators) // not an operator
		{
			stack ~= new LiteralOperand(token);
		}
		else // an operator
		{
			Expression[] operands = new Expression[operators[token]];
			foreach(ref op; retro(operands))
			{
				enforce(!stack.empty, insufficient_operands);
				op = stack.back();
				stack.popBack();
			} // end foreach
			stack ~= new ExpressionAstNode(token,operands);
		} // end else
	} // end foreach

	enforce(stack.length == 1, stack_not_exhausted);
	return stack.back();
} // end function parsePostfixExpression

unittest
{
	immutable operators = ["+":2,"-":2,"*":2,"/":2,"%":2,"?":3,"!":1,"$":1]; // (operator symbol,#operands) pairs

	immutable test_cases = [
		["2 3 +", "( + , 2, 3)"],
		["2 3 -", "( - , 2, 3)"],
		["2 3 *", "( * , 2, 3)"],
		["2 3 /", "( / , 2, 3)"],
		["2 3 %", "( % , 2, 3)"],
		["2 3 4 ?", "( ? , 2, 3, 4)"],
		["2 !", "( ! , 2)"],
		["2 $", "( $ , 2)"],
		["a b +", "( + , a, b)"],
		["a b + c -", "( - , ( + , a, b), c)"],
		["c a b + -", "( - , c, ( + , a, b))"],
		["2 3 - 3.1 + 2 5 ? 1 ! 2 $ % /", "( / , ( ? , ( + , ( - , 2, 3), 3.1), 2, 5), ( % , ( ! , 1), ( $ , 2)))"],
		["1 ! 2 3 - $ $ ! *", "( * , ( ! , 1), ( ! , ( $ , ( $ , ( - , 2, 3)))))"],
	];

	runUnitTests!(test_input => parsePostfixExpression(operators, test_input).serialize())(test_cases);
} // end unittest
