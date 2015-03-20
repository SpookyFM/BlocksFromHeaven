package;



import kha.Loader;
import kha.Music;
import kha.Sound;

import kha.Color;

import kha.math.Vector2;

/**
 * ...
 * @author Florian Mehm
 */
class Commands
{

	public static var game: TestGame;
	
	public static var transition: Transition;
	
		
	public function Speak(text: String, soundFile: String): Void {
		var s: Sound = Loader.the.getSound(soundFile);
		s.play();
	}
	
	public function PlaySound(soundFile: String): Void {
		var s: Sound = Loader.the.getSound(soundFile);
		s.play();
	}
	
	public function PlayMusic(musicFile: String, ?loop: Bool = false): Void {
		var m: Music = Loader.the.getMusic(musicFile);
		m.play(loop);
	}
	
	public function FadeOutMusic(musicFile: String): Void {
		// TODO: Check out the scheduler!
	}
	
	public function ChangeBackground(name: String): Void {
		game.currentScene.setBackground(Loader.the.getImage(name));
	}
	
	public function EnableHotspot(name: String): Void {
		game.currentScene.hotspots[name].enabled = true;
	}
	
	public function DisableHotspot(name: String): Void {
		game.currentScene.hotspots[name].enabled = false;
		
		BlocksFromHeaven.instance.uiElements.splice(0, BlocksFromHeaven.instance.uiElements.length);
	}
	
	public function ShowUse(): Void {
		// Show the "use" icon
		BlocksFromHeaven.instance.uiElements.splice(0, BlocksFromHeaven.instance.uiElements.length);
		
		var useSymbol: UIElement = new UIElement();
		useSymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		useSymbol.Offset = new Vector2(0, 0);
		useSymbol.Texture = Loader.the.getImage("use");
		// useSymbol.startAnimating();
		BlocksFromHeaven.instance.uiElements.push(useSymbol);
	}
	
	public function StopMusic(musicFile: String): Void {
		var m: Music = Loader.the.getMusic(musicFile);
		m.stop();
	}
	
	// Display the exit icon over the hotspot
	public function ShowExit(): Void {
		BlocksFromHeaven.instance.showExit(Hotspot.current);
	}
	
	
	public function ChangeScene(scene: String): Void {
		
		var current: Scene = game.currentScene;
		var to: Scene = game.scenes[scene];
		transition.start(current, to, 3.0, Color.White);
		trace("Transition from: " + current.id + " to " + to.id);
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