package;




import kha.Image;
import kha.Loader;
import kha.Music;
import kha.Sound;

import kha.Color;

import kha.math.Vector2;

import kha.Scheduler;

import ActionType;
import SubImageDrawer;

import kha.graphics4.TextureFormat;

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

		var useSymbol: UIElement = new UIElement();
		useSymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		useSymbol.Offset = new Vector2(0, 1);
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
		
		
		var talkSymbol: UIElement = new UIElement();
		talkSymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		talkSymbol.Offset = new Vector2(1, 0.3);
		talkSymbol.Texture = Loader.the.getImage("talk");
		talkSymbol.InactiveTexture = talkSymbol.Texture;
		talkSymbol.ActiveTexture = Loader.the.getImage("talk_active");
		// useSymbol.startAnimating();
		BlocksFromHeaven.instance.uiElements.push(talkSymbol);
		BlocksFromHeaven.instance.currentAction = ActionType.TalkTo;
	}
	
	public function ShowExamine(): Void {
		trace("Showing the examine icon");
		
		
		var examineSymbol: UIElement = new UIElement();
		examineSymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		examineSymbol.Offset = new Vector2(1, -1);
		examineSymbol.Texture = Loader.the.getImage("examine");
		examineSymbol.InactiveTexture = examineSymbol.Texture;
		examineSymbol.ActiveTexture = Loader.the.getImage("examine_active");
		// useSymbol.startAnimating();
		BlocksFromHeaven.instance.uiElements.push(examineSymbol);
		BlocksFromHeaven.instance.currentAction = ActionType.Examine;
	}
	
	public function ShowLook(): Void {
		trace("Showing the look icon");
		
		
		var lookSymbol: UIElement = new UIElement();
		lookSymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		lookSymbol.Offset = new Vector2(-1, -1);
		lookSymbol.Texture = Loader.the.getImage("look");
		lookSymbol.InactiveTexture = lookSymbol.Texture;
		lookSymbol.ActiveTexture = Loader.the.getImage("look_active");
		// useSymbol.startAnimating();
		BlocksFromHeaven.instance.uiElements.push(lookSymbol);
		BlocksFromHeaven.instance.currentAction = ActionType.Look;
	}
	
	public function Log(s: String): Void {
		trace(s);
	}
	
	public function ShowUseInventory(): Void {
		trace("Showing the use inventory icon");
		
		
		var showInventorySymbol: UIElement = new UIElement();
		showInventorySymbol.SetPosition(Hotspot.current.getUILonLat(), 5);
		showInventorySymbol.Offset = new Vector2(-1, 0.3);
		showInventorySymbol.Texture = Loader.the.getImage("use_inventory");
		showInventorySymbol.InactiveTexture = showInventorySymbol.Texture;
		showInventorySymbol.ActiveTexture = Loader.the.getImage("use_inventory_active");
		// useSymbol.startAnimating();
		BlocksFromHeaven.instance.uiElements.push(showInventorySymbol);
		BlocksFromHeaven.instance.currentAction = ActionType.UseInventory;
	}
	
	public function StopMusic(musicFile: String): Void {
		var m: Music = Loader.the.getMusic(musicFile);
		m.stop();
	}
	
	public function StopSound(soundFile: String): Void {
		var s: Sound = Loader.the.getSound(soundFile);
		// TODO: Not stoppable
	}
	
	// Display the exit icon over the hotspot
	public function ShowExit(): Void {
		BlocksFromHeaven.instance.showExit(Hotspot.current);
	}
	
	
	public function GetCurrentScene(): String {
		return game.currentScene.id;
	}
	
	public function ChangeScene(scene: String): Void {
		
		var current: Scene = game.currentScene;
		var to: Scene = game.scenes[scene];
		transition.start(current, to, 1.0, Color.White);
		trace("Transition from: " + current.id + " to " + to.id);
		// .interpret(game.currentScene.onEnter);
	}
	
	public var LastScene: Scene;
	
	public function ShowExamineScene(scene: String) {
		LastScene = game.currentScene;
		transition.toExamine = true;
		transition.fromExamine = false;
		ChangeScene(scene);
		// TODO: This is not very clean, two different interfaces to this variable with different meanings!
		BlocksFromHeaven.instance.inventoryActive = false;
		BlocksFromHeaven.instance.inventoryExamineActive = true;
	}
	
	public function ReturnToInventory() {
		transition.toExamine = false;
		transition.fromExamine = true;
		ChangeScene(LastScene.id);
		BlocksFromHeaven.instance.inventoryActive = true;
		BlocksFromHeaven.instance.inventoryExamineActive = false;
	}
	
	
	
	public function SetVariable(name: String, value: Dynamic): Void {
		trace("Setting " + name + " to value " + value);
		game.variables[name] = value;
	}
	
	public function GetVariable(name: String): Dynamic {
		return game.variables[name];
	}
	
	

	
	public function AddInventoryItem(name: String) {
		trace("Giving item: " + name);
		var item: InventoryItem = game.allItems[name];
		game.inventory.push(item);
	}
	
	public function RemoveInventoryItem(name: String) {
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
	
	public function GetActiveInventory(): String {
		return game.ActiveInventory;
	}
	
	
	public function DrawSubImage(base: String, top: String, x: Float, y: Float, w: Float, h: Float) {
		
		
		
		// var baseImage: Image = Loader.the.getImage(base);
		var baseImage: Image = BlocksFromHeaven.instance.globe.texture;
		var topImage: Image = Loader.the.getImage(top);
		
		var baseRenderTarget: Image = Image.createRenderTarget(4096, 2048, TextureFormat.RGBA32);
		var drawer2: SubImageDrawer = new SubImageDrawer(0, 0, 4096, 2048);
		drawer2.imageToDraw = baseImage;
		
		baseRenderTarget.g4.begin();
		drawer2.render(baseRenderTarget.g4);
		baseRenderTarget.g4.end();
		
		
		var drawer: SubImageDrawer = new SubImageDrawer(x, y, w, h);
		
		
		drawer.imageToDraw = topImage;
		baseRenderTarget.g4.begin();
		drawer.render(baseRenderTarget.g4);
		baseRenderTarget.g4.end(); 
		
		
		// TODO: Needs to be more general!
		BlocksFromHeaven.instance.globe.texture = baseRenderTarget;
		
	}
	
	
	
	
	public function new() 
	{
		
	}
	
}