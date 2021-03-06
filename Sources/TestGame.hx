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
	
	public var ActiveInventory: String;
	
	public function addScene(scene: Scene): Void {
		scenes[scene.id] = scene;
	}
	
	
		
	
	public function new() 
	{
		scenes = new Map();
		variables = new Map<String, Dynamic>();
		inventory = new Array<InventoryItem>();
		allItems = new Map<String, InventoryItem>();
		
		
		/* startScene = new Scene();
		startScene.id = "START";
		startScene.onEnter = "game.PlayMusic(\"intro\");";
		startScene.onLeave = "game.StopMusic(\"intro\");";
		startScene.setBackground(Loader.the.getImage("start"));
		addScene(startScene);
		
		
		var hotspot1: Hotspot = getHotspot(startScene, new Vector2(2082, 987), 144 / 2 );
		hotspot1.id = "startPlaying";
		hotspot1.onGaze = "game.ShowExit();";
		hotspot1.onUse = "game.ChangeScene(\"conservatory\");";
		
		hotspot1.uiCenter.x = hotspot1.center.x;
		hotspot1.uiCenter.y = hotspot1.center.y - 0.05;
		
		
		startScene.hotspots[hotspot1.id] = hotspot1;
		
		
		var secondScene: Scene = new Scene();
		secondScene.id = "conservatory";
		secondScene.onEnter = "game.PlayMusic(\"ambience_inside\", true);";
		secondScene.onLeave = "game.StopMusic(\"ambience_inside\");";
		secondScene.setBackground(Loader.the.getImage("conservatory_closed"));
		
		
		var doorHotspot: Hotspot = getHotspot(secondScene, new Vector2(2074, 1006), 524 / 2);
		doorHotspot.id = "hotspot2";
		doorHotspot.enabled = false;
		doorHotspot.uiCenter = doorHotspot.center;
		doorHotspot.onGaze = "game.ShowExit();";
		doorHotspot.onUse = "game.PlaySound(\"steps\"); game.ChangeScene(\"pool\");";
		secondScene.hotspots[doorHotspot.id] = doorHotspot;
		
		
		var leverHotspot: Hotspot = getHotspot(secondScene, new Vector2(2237, 995), 177 / 2);
		leverHotspot.id = "leverHotspot";
		leverHotspot.uiCenter = leverHotspot.center;
		leverHotspot.onGaze = "game.ShowUse();";
		leverHotspot.onUse = "game.ChangeBackground(\"conservatory_open\");game.PlaySound(\"door_open\");game.DisableHotspot(\"leverHotspot\"); game.EnableHotspot(\"hotspot2\");";
		secondScene.hotspots[leverHotspot.id] = leverHotspot;
		
		
		addScene(secondScene);
		
		
		
		
		
		
		
		var thirdScene: Scene = new Scene();
		thirdScene.id = "pool";
		thirdScene.onEnter = "game.PlayMusic(\"ambience_outside\", true);";
		thirdScene.onLeave = "game.StopMusic(\"ambience_outside\");";
		thirdScene.setBackground(Loader.the.getImage("pool"));
		addScene(thirdScene);
		
		
		var hotspot3: Hotspot = getHotspot(thirdScene, new Vector2(251, 1012), 260 / 2 );
		hotspot3.id = "hotspot3";
		hotspot3.uiCenter = hotspot3.center;
		hotspot3.onGaze = "game.ShowExit();";
		hotspot3.onUse = "game.ChangeScene(\"conservatory\");";
		thirdScene.hotspots[hotspot3.id] = hotspot3;
		
		
		
		currentScene = startScene;
		*/
		
		
		var item: InventoryItem = new InventoryItem();
		item.id = "ITEM";
		allItems[item.id] = item;
	}
	
	
	
	
	
	
	
	
}