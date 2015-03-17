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
	
		
	public function Speak(text: String, soundFile: String): Void {
		var s: Sound = Loader.the.getSound(soundFile);
		s.play();
	}
	
	public function PlaySound(soundFile: String): Void {
		var s: Sound = Loader.the.getSound(soundFile);
		s.play();
	}
	
	
	public function ChangeToScene(scene: String): Void {
		game.currentScene = game.scenes[scene];
		// .interpret(game.currentScene.onEnter);
	}
	
	public function SetVariable(name: String, value: Dynamic): Void {
		game.variables[name] = value;
	}
	
	public function GetVariable(name: String): Dynamic {
		return game.variables[name];
	}
	
	public function GiveInventoryItem(name: String) {
		var item: InventoryItem = game.allItems[name];
		game.inventory.push(item);
	}
	
	public function TakeInventory(name: String) {
		var item: InventoryItem = null;
		for (current in game.inventory) {
			if (current.id == name) {
				item = current;
				break;
			}
		}
		game.inventory.remove(item);		
	}
	
	public function HasInventory(name: String): Bool {
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