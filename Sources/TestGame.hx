package;
import kha.Image;

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
	
	
		
	
	public function new() 
	{
		scenes = new Map();
		variables = new Map<String, Dynamic>();
		inventory = new Array<InventoryItem>();
		allItems = new Map<String, InventoryItem>();
		
		
		startScene = new Scene();
		startScene.id = "START";
		
		// Load images
		startScene.background = new Image();
		addScene(startScene);
		
		
		var secondScene: Scene = new Scene();
		secondScene.id = "SECOND";
		addScene(secondScene);
		
		
		var item: InventoryItem = new InventoryItem();
		item.id = "ITEM";
		allItems[item.id] = item;
		
		
	}
	
	
	
	
	
	
	
	
}