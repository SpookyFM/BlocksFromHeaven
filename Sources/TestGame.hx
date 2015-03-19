package;
import kha.Image;
import kha.math.Vector2;

import kha.Loader;

/**
 * ...
 * @author Florian Mehm
 */
class TestGame
{
	
	public var startScene: Scene;
	
	public var name: String;
	
	public var currentScene: Scene;
	
	public var scenes: Map<String, Scene>;
	
	public var variables: Map<String, Dynamic>;
	
	public var inventory: Array<InventoryItem>;
	
	public var allItems: Map<String, InventoryItem>;
	
	public function addScene(scene: Scene): Void {
		scenes[scene.id] = scene;
	}
	
	private function getHotspot(scene: Scene, center: Vector2, radius: Float): Hotspot {
		var hotspot = new Hotspot();
		hotspot.image = scene.background;
		hotspot.center.x = center.x / scene.background.width;
		hotspot.center.y = (scene.background.height - center.y) / scene.background.height;
		hotspot.radius = radius / scene.background.width;
		//hotspot.center.x += hotspot.radius * 0.5;
		//hotspot.center.y -= hotspot.radius * 0.5;
		
		return hotspot;
	}
		
	
	public function new() 
	{
		scenes = new Map();
		variables = new Map<String, Dynamic>();
		inventory = new Array<InventoryItem>();
		allItems = new Map<String, InventoryItem>();
		
		
		startScene = new Scene();
		startScene.id = "START";
		startScene.onEnter = "game.PlayMusic(\"intro\");";
		startScene.onLeave = "game.StopMusic(\"intro\");";
		startScene.background = Loader.the.getImage("start");
		addScene(startScene);
		
		
		var hotspot1: Hotspot = getHotspot(startScene, new Vector2(2082, 987), 144/2 );
		hotspot1.onGaze = "game.ShowExit();";
		hotspot1.onUse = "game.ChangeScene(\"conservatory\");";
		startScene.hotspots.push(hotspot1);
		
		
		var secondScene: Scene = new Scene();
		secondScene.id = "conservatory";
		secondScene.onEnter = "game.PlayMusic(\"ambience_inside\");";
		secondScene.onLeave = "game.StopMusic(\"ambience_inside\");";
		secondScene.background = Loader.the.getImage("conservatory");
		
		
		var hotspot2: Hotspot = getHotspot(secondScene, new Vector2(2074, 1006), 524 / 2);
		hotspot2.onGaze = "game.ShowExit();";
		hotspot2.onUse = "game.ChangeScene(\"pool\");";
		secondScene.hotspots.push(hotspot2);
		
		addScene(secondScene);
		
		
		
		
		var thirdScene: Scene = new Scene();
		thirdScene.id = "pool";
		thirdScene.onEnter = "game.PlayMusic(\"ambience_outside\");";
		thirdScene.onLeave = "game.StopMusic(\"ambience_outside\");";
		thirdScene.background = Loader.the.getImage("pool");
		addScene(thirdScene);
		
		
		var hotspot3: Hotspot = getHotspot(thirdScene, new Vector2(251, 1012), 260/2 );
		hotspot3.onGaze = "game.ShowExit();";
		hotspot3.onUse = "game.ChangeScene(\"conservatory\");";
		startScene.hotspots.push(hotspot1);
		
		
		
		
		currentScene = startScene;
		
		var item: InventoryItem = new InventoryItem();
		item.id = "ITEM";
		allItems[item.id] = item;
	}
	
	
	
	
	
	
	
	
}