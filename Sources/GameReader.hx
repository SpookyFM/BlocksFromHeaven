package;
import haxe.xml.Fast;
import kha.Blob;
import kha.math.Vector2;

import kha.Loader;

/**
 * ...
 * @author Florian Mehm
 */
class GameReader
{
	
	// TODO: We shouldn't have to load all images on the start of the program
	// TODO: Change hotspot class to handle absolute positions 
		// Checks if innerData exists and returns it, otherwise an empty string
		private function GetString(element: Fast): String {
			// if (element.hasNode.innerData) {
			if (element.x.firstChild() != null) {
				return element.innerData;
			} else {
				return "";
			}
		}
		
	private function createHotspot(scene: Scene, center: Vector2, radius: Float): Hotspot {
		var hotspot = new Hotspot();
		hotspot.image = scene.background;
		hotspot.center.x = center.x / scene.background.width;
		hotspot.center.y = (scene.background.height - center.y) / scene.background.height;
		hotspot.radius = radius / scene.background.width;
		
		hotspot.uiCenter.x = hotspot.center.x;
		hotspot.uiCenter.y = hotspot.center.y;
		
		return hotspot;
	}
	
	private function ParseHotspot(hotspotElement: Fast, scene:Scene): Hotspot {
		var x: Float = Std.parseFloat(hotspotElement.node.Shape.node.Center.att.X);
		var y: Float = Std.parseFloat(hotspotElement.node.Shape.node.Center.att.Y);
		var radius: Float = Std.parseFloat(hotspotElement.node.Shape.node.Radius.innerData);
		
		var hotspot: Hotspot = createHotspot(scene, new Vector2(x, y), radius);
		
		hotspot.id = hotspotElement.att.Name;
		trace("Parse hotspot:" + hotspot.id);
		
		hotspot.onGaze = GetString(hotspotElement.node.OnGaze);
		trace("OnGaze: " + hotspot.onGaze);
		hotspot.onExamine = GetString(hotspotElement.node.OnExamine);
		hotspot.onUse = GetString(hotspotElement.node.OnUse);
		
		return hotspot;
	}
	
	
	private function ParseScene(sceneElement: Fast): Scene {
		var scene: Scene = new Scene();
		scene.id = sceneElement.att.Name;
		scene.background = Loader.the.getImage(sceneElement.node.BackgroundImage.innerData);
		if (sceneElement.hasNode.OnEnter)
			scene.onEnter = GetString(sceneElement.node.OnEnter);
		
		trace("Parse scene: " + scene.id);
		trace("OnEnter: " + scene.onEnter);
		// scene.onEnter = sceneElement.att.
		// TODO: Save the reference and only load when needed
		// scene.background = sceneElement.node.BackgroundImage.innerData;
		for (hotspotElement in sceneElement.node.Hotspots.nodes.Hotspot) {
			var hotspot: Hotspot = ParseHotspot(hotspotElement, scene);
			scene.hotspots[hotspot.id] = hotspot;
		}
		
		return scene;
	}
	
	public function Read(): TestGame {
		var blob: Blob = Loader.the.getBlob("game.xml");
		var xml: Xml = Xml.parse(blob.toString());
		
		var fast: Fast = new Fast(xml.firstElement());
		
		var game: TestGame = new TestGame();
		game.name = fast.att.Name;
		trace("Game name: " + game.name);
		
		var startSceneName: String = fast.node.StartScene.att.Name;

		for (sceneElement in fast.node.Scenes.nodes.Scene) {
			var scene: Scene = ParseScene(sceneElement);
			game.scenes[scene.id] = scene;
			if (startSceneName == scene.id) {
				game.startScene = scene;
			}
		}
		
		// Bring the game into the started state
		game.currentScene = game.startScene;
		
		return game;
	}

	public function new() 
	{
		
	}
	
}