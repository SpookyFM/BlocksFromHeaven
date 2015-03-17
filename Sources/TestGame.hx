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
		currentScene = startScene;
		
		// Load images
		startScene.background = Loader.the.getImage("panorama");
		addScene(startScene);
		
		
		var hotspot1: Hotspot = getHotspot(startScene, new Vector2(3148, 1361), 186 / 2);
		hotspot1.onUse = "game.ChangeScene(\"SECOND\");";
		startScene.hotspots.push(hotspot1);
		
		
		var secondScene: Scene = new Scene();
		secondScene.id = "SECOND";
		secondScene.background = Loader.the.getImage("panorama2");
		
		var hotspot2: Hotspot = getHotspot(secondScene, new Vector2(1765, 973), 195 / 2);
		hotspot2.onUse = "game.ChangeScene(\"START\");";
		secondScene.hotspots.push(hotspot2);
		
		addScene(secondScene);
		
		
		
		
		
		
		var item: InventoryItem = new InventoryItem();
		item.id = "ITEM";
		allItems[item.id] = item;
	}
	
	
	
	
	
	
	
	
}