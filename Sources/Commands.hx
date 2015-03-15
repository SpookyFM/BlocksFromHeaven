package;

import kha.Loader;
import kha.Sound;

/**
 * ...
 * @author Florian Mehm
 */
class Commands
{

	public static var game: TestGame;
	
	public static var interpreter: Interpreter;
	
	public static function speak(var text: String, var soundFile: String): Void {
		Sound s = Loader.the.getSound(soundFile);
		s.play();
	}
	
	
	public static function changeToScene(var scene: String): Void {
		game.currentScene = game.scenes[scene];
		interpreter.interpret(game.currentScene.onEnter);
	}
	
	public static function SetVariable(var name: String, var value: Dynamic): Void {
		game.variables[name] = value;
	}
	
	public static function GetVariable(var name: String): Dynamic {
		return game.variables[name];
	}
	
	public static function GiveInventoryItem(var name: String) {
		var item: InventoryItem = game.allItems[name];
		game.inventory.push(item);
	}
	
	public static function TakeInventory(var name: String) {
		var item: InventoryItem;
		for (current in game.inventory) {
		if (current.id == name) {
			item = current;
			break;
		}
		}
		game.inventory.remove(item);		
	}
	
	public static function HasInventory(var name: String): Bool {
		var item: InventoryItem;
		for (current in game.inventory) {
		if (current.id == name) {
		return true;
		}
		}
		return false;
	}
	
	
	
	public function new() 
	{
		
	}
	
}