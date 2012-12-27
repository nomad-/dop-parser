import std.stdio, std.string;
import Expressions;


void main()
{
	
	writeln("Type in a line of text and press enter. (Type ctrl+z and enter to exit)");
	write("<< ");
	
	foreach(line; stdin.byLine())
	{
		// print output line
		auto ast = parseInfixExpression(line);
		writeln(">> ",ast?ast.serialize():"error: stack not exhausted... or something else!");
		// prepare for new input
		write("<< ");
	} // end foreach
} // end function main