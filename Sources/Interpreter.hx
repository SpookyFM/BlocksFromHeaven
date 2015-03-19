package;

import hscript.Expr;
import hscript.Parser;
import hscript.Interp;

/**
 * ...
 * @author Florian Mehm
 */
class Interpreter
{
	public static var the(default, null): Interpreter;
	
	private static var parser: hscript.Parser;
	private static var interp: hscript.Interp;
	
	private static var commands: Commands;
	
	public function interpret(s: String) {
		try {
			var program = parser.parseString(s);
			interp.execute(program);
		} catch (error: Error) {
			trace("Interpreter error: " + error.getName());
		}
	}
	
	private function new() {
		
	}
	
	public static function init()
	{
		the = new Interpreter();
		parser = new hscript.Parser();
		interp = new hscript.Interp();
		commands = new Commands();
		interp.variables["game"] = commands;
	}
	
}