package;



import kha.Image;
import kha.Loader;
import kha.Music;
import kha.Sound;

import kha.Color;

import kha.math.Vector2;

import kha.Scheduler;

import ActionType;

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
		var m: Music = Loader.the.getMusic(musicFile);
		var start: Float = Sys.time();
		var end: Float = start + 1.0;
		
		
		var task = function(): Bool { 
			var v: Float = Sys.time() - start / (end - start);
			v = 1.0 - v;
			if (v <= 0) m.stop();
			
			// TODO: Kore does not handle the volume...
			m.setVolume(v);
		
			return v > 0;
		};
		
		
		Scheduler.addBreakableFrameTask(task, 0);
	}
	

	
	public function ChangeBackground(scene: String, newBG: String) {
		var s: Scene = game.scenes[scene];
		var image: Image = Loader.the.getImage(newBG);
		s.background = image;
		if (s == game.currentScene) {
			BlocksFromHeaven.instance.globe.texture = s.background;
		}
	}
	
	public function ChangeBackgroundFade(newBG: String) {
		// TODO: Changes the background of the current scene and uses a fade
	}
	
	public function ChangeBackgroundBlend(newBG: String) {
		// TODO: Changes the background of the current scene and blends between the two images
	}
	
	public function EnableHotspot(name: String): Void {
		game.currentScene.hotspots[name].enabled = true;
	}
	
	public function DisableHotspot(name: String): Void {
		game.currentScene.hotspots[name].enabled = false;
		
		BlocksFromHeaven.instance.uiElements.splice(0, BlocksFromHeaven.instance.uiElements.length);
	}
	
	public function ShowUse(): Void {
		trace("Showing the use icon");
		// Show the "use" icon
		BlocksFromHeaven.instance.uiElements.splice(0, BlocksFromHeaven.instance.uiElements.length);
		
		var useSymbol: UIElement = new UIElement();
		useSymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		useSymbol.Offset = new Vector2(0, 0);
		useSymbol.Texture = Loader.the.getImage("use");
		useSymbol.InactiveTexture = useSymbol.Texture;
		useSymbol.ActiveTexture = Loader.the.getImage("use_active");
		// useSymbol.startAnimating();
		BlocksFromHeaven.instance.uiElements.push(useSymbol);
		BlocksFromHeaven.instance.currentAction = ActionType.Use;
	}
	
	
	public function ShowTalkTo(): Void {
		trace("Showing the talk to icon");
		// Show the "use" icon
		BlocksFromHeaven.instance.uiElements.splice(0, BlocksFromHeaven.instance.uiElements.length);
		
		var talkSymbol: UIElement = new UIElement();
		talkSymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		talkSymbol.Offset = new Vector2(0, 0);
		talkSymbol.Texture = Loader.the.getImage("talk");
		talkSymbol.InactiveTexture = talkSymbol.Texture;
		talkSymbol.ActiveTexture = Loader.the.getImage("talk_active");
		// useSymbol.startAnimating();
		BlocksFromHeaven.instance.uiElements.push(talkSymbol);
		BlocksFromHeaven.instance.currentAction = ActionType.TalkTo;
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
		trace("Setting " + name + " to value " + value);
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