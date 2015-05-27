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
	
	private var symbols: Map<ActionType, UIElement>;
	
		
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
		m.setVolume(1.0);
		m.play(loop);
	}
	
	public function FadeOutMusic(musicFile: String, ?duration: Float = 3.0): Void {
		var m: Music = Loader.the.getMusic(musicFile);
		var start: Float = Sys.time();
		var end: Float = start + duration;
		
		
		var task = function(): Bool { 
			var v: Float = (Sys.time() - start) / (end - start);
			v = 1.0 - v;
			if (v <= 0) m.stop();

			m.setVolume(v);
		
			// trace("Volume: " + v);
			return v > 0;
		};
		
		
		Scheduler.addBreakableFrameTask(task, 0);
	}
	
	public function FadeInMusic(musicFile:String, ?duration: Float = 3.0) {
		var m: Music = Loader.the.getMusic(musicFile);
		m.play();
		m.setVolume(0);
		var start: Float = Sys.time();
		var end: Float = start + duration;
		
		
		var task = function(): Bool { 
			var v: Float = (Sys.time() - start) / (end - start);

			m.setVolume(v);
		
			//trace("Volume: " + v);
			return v < 1;
		};
		
		
		Scheduler.addBreakableFrameTask(task, 0);
		
	}
	

	
	public function ChangeBackground(scene: String, newBG: String) {
		var s: Scene = game.scenes[scene];
		
		var image: ImageHolder = ImageHolder.getHolder(newBG);
		
		if (s == game.currentScene) {
			// Load the new image and use it to change the BG
			image.load(function() {
				trace("Load changed bg finished.");
					BlocksFromHeaven.instance.globe.texture = image.image;
					s.background.unload();
					s.background = image;
					
					
			});
		} else {
			s.background = image;
		}
		
		for (hotspot in s.hotspots) {
			hotspot.image = s.background;
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
	
	public function EnableHotspotInScene(scene: String, name: String) {
		game.scenes[scene].hotspots[name].enabled = true;
	}
	
	public function DisableHotspotInScene(scene: String, name: String) {
		game.scenes[scene].hotspots[name].enabled = false;
		
		if (game.currentScene.id == scene)
			BlocksFromHeaven.instance.uiElements.splice(0, BlocksFromHeaven.instance.uiElements.length);
		
	}
	
	private function ShowAction(type: ActionType) {
		var symbol: UIElement = symbols[type];
		if (type != Exit) {
			symbol.SetPosition(Hotspot.current.getUILonLat(), 5.0);
			
		} else {
			symbol.SetPosition(Hotspot.current.getUILonLat(), 5.0);
		}
		BlocksFromHeaven.instance.uiElements.push(symbol);
	}
	
	
	
	public function ShowUse(): Void {
		ShowAction(Use);
	}
	
	
	public function ShowTalkTo(): Void {
		ShowAction(TalkTo);
	}
		
	
	public function ShowExamine(): Void {
		ShowAction(Examine);
	}
	
	public function ShowLook(): Void {
		ShowAction(Look);
	}
	
	public function Log(s: String): Void {
		trace(s);
	}
	
	public function ShowUseInventory(): Void {
		ShowAction(UseInventory);
	}
	
	public function StopMusic(musicFile: String): Void {
		var m: Music = Loader.the.getMusic(musicFile);
		// TODO: Does stopping really work?
		m.setVolume(0.0);
		m.stop();
	}
	
	public function StopSound(soundFile: String): Void {
		var s: Sound = Loader.the.getSound(soundFile);
		// TODO: Not stoppable
	}
	
	// Display the exit icon over the hotspot
	public function ShowExit(): Void {
		ShowAction(Exit);
	}
	
	
	public function GetCurrentScene(): String {
		return game.currentScene.id;
	}
	
	public function IsFirstTime(): Bool {
		return game.currentScene.visitCount < 2;
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
		
		
		// Since by default, images are not saved as render targets we need to:
		// Copy the old base into a new image
		// Unload the old texture
		// Mark the holder as dirty
		// Replace the image
		// Load the image to draw from
		// Do the drawing
		// Unload the image we drew from
		
		var baseHolder: ImageHolder = ImageHolder.getHolder(base);
		var topHolder = ImageHolder.getHolder(top);
		
		// TODO: We are assuming that the image is currently loaded
		var baseImage: Image = baseHolder.image;
		
		
		// Copy the image to a render target
		var baseRenderTarget: Image = Image.createRenderTarget(4096, 2048, TextureFormat.RGBA32);
		var drawer2: SubImageDrawer = new SubImageDrawer(0, 0, 4096, 2048);
		drawer2.imageToDraw = baseImage;
		
		baseRenderTarget.g4.begin();
		drawer2.render(baseRenderTarget.g4);
		baseRenderTarget.g4.end();
		
		// Exchange it in the image holder and mark dirty
		baseHolder.exchangeImage(baseRenderTarget);
		baseHolder.setDirty();
		
		
		
		topHolder.load(function() {
			var topImage: Image = topHolder.image;
			var drawer: SubImageDrawer = new SubImageDrawer(x, y, w, h);
		
		
			drawer.imageToDraw = topImage;
			baseRenderTarget.g4.begin();
			drawer.render(baseRenderTarget.g4);
			baseRenderTarget.g4.end(); 
		
		
			// Check if we changed the current background image
		
			var currentBG: String = game.currentScene.background.name;
			if (currentBG == baseHolder.name) {
				BlocksFromHeaven.instance.globe.texture = baseRenderTarget;
				// game.currentScene.background.exchangeImage(baseRenderTarget);
				
				
			}
			// Unload the top image
			topHolder.unload();
		});
	}
	
	
	
	
	public function new() 
	{
		symbols = new Map<ActionType, UIElement>();
		var scale: Float = 0.5;
		
		var useSymbol: UIElement = new UIElement();
		useSymbol.Offset = new Vector2(0, 1);
		useSymbol.Texture = Loader.the.getImage("use");
		useSymbol.InactiveTexture = useSymbol.Texture;
		useSymbol.ActiveTexture = Loader.the.getImage("use_active");
		useSymbol.Scale = scale;
		useSymbol.OnClick = function(): Void {
			Interpreter.the.interpret(Hotspot.current.onUse);
		}
		symbols[ActionType.Use] = useSymbol;
		
		
		var talkSymbol: UIElement = new UIElement();
		talkSymbol.Offset = new Vector2(1, 0.3);
		talkSymbol.Texture = Loader.the.getImage("talk");
		talkSymbol.InactiveTexture = talkSymbol.Texture;
		talkSymbol.ActiveTexture = Loader.the.getImage("talk_active");
		talkSymbol.Scale = scale;
		talkSymbol.OnClick = function(): Void {
			Interpreter.the.interpret(Hotspot.current.onTalkTo);
		}
		symbols[ActionType.TalkTo] = talkSymbol;
		
		var examineSymbol: UIElement = new UIElement();
		examineSymbol.Offset = new Vector2(1, -1);
		examineSymbol.Texture = Loader.the.getImage("examine");
		examineSymbol.InactiveTexture = examineSymbol.Texture;
		examineSymbol.ActiveTexture = Loader.the.getImage("examine_active");
		examineSymbol.Scale = scale;
		examineSymbol.OnClick = function(): Void {
			Interpreter.the.interpret(Hotspot.current.onExamine);
		}
		symbols[ActionType.Examine] = examineSymbol;
		
		
		var showInventorySymbol: UIElement = new UIElement();
		showInventorySymbol.Offset = new Vector2(-1, 0.3);
		showInventorySymbol.Texture = Loader.the.getImage("use_inventory");
		showInventorySymbol.InactiveTexture = showInventorySymbol.Texture;
		showInventorySymbol.ActiveTexture = Loader.the.getImage("use_inventory_active");
		showInventorySymbol.Scale = scale;
		showInventorySymbol.OnClick = function(): Void {
			BlocksFromHeaven.instance.showInventory(InventoryType.Use);
			
		}
		symbols[ActionType.UseInventory] = showInventorySymbol;
		
		
		var lookSymbol: UIElement = new UIElement();
		lookSymbol.Offset = new Vector2(-1, -1);
		lookSymbol.Texture = Loader.the.getImage("look");
		lookSymbol.InactiveTexture = lookSymbol.Texture;
		lookSymbol.ActiveTexture = Loader.the.getImage("look_active");
		lookSymbol.Scale = scale;
		lookSymbol.OnClick = function(): Void {
			Interpreter.the.interpret(Hotspot.current.onLook);
		}
		symbols[ActionType.Look] = lookSymbol;
		
		
		var exitSymbol:UIElement = new UIElement();
		exitSymbol.Offset = new Vector2(0, 0);
		exitSymbol.Texture = Loader.the.getImage("arrow_forward");
		exitSymbol.ActiveTexture = Loader.the.getImage("arrow_forward_active");
		exitSymbol.InactiveTexture = Loader.the.getImage("arrow_forward");
		exitSymbol.Scale = 1.0;
		exitSymbol.OnClick = function(): Void {
			Interpreter.the.interpret(Hotspot.current.onUse);
		}
		exitSymbol.startAnimating();
		exitSymbol.isExit = true;
		symbols[ActionType.Exit] = exitSymbol;
	}
	
}