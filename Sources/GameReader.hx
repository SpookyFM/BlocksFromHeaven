package;
import haxe.xml.Fast;
import kha.Blob;

import kha.Loader;

/**
 * ...
 * @author Florian Mehm
 */
class GameReader
{
	
	// TODO: We shouldn't have to load all images on the start of the program
	// TODO: Change hotspot class to handle absolute positions 
	
	private function ParseHotspot(hotspotElement: Fast): Hotspot {
		var hotspot: Hotspot = new Hotspot();
		hotspot.id = hotspotElement.att.Name;
		hotspot.onExamine = hotspotElement.node.OnExamine.innerData;
		hotspot.onUse = hotspotElement.node.OnUse.innerData;
		hotspot.center.x = Std.parseFloat(hotspotElement.node.Shape.node.Center.att.X);
		hotspot.center.y = Std.parseFloat(hotspotElement.node.Shape.node.Center.att.Y);
		hotspot.radius = Std.parseFloat(hotspotElement.node.Shape.node.Radius.innerData);
		
		return hotspot;
	}
	
	
	private function ParseScene(sceneElement: Fast): Scene {
		var scene: Scene = new Scene();
		scene.id = sceneElement.att.Name;
		// scene.onEnter = sceneElement.att.
		// TODO: Save the reference and only load when needed
		// scene.background = sceneElement.node.BackgroundImage.innerData;
		for (hotspotElement in sceneElement.node.Hotspots.nodes.Hotspot) {
			var hotspot: Hotspot = ParseHotspot(hotspotElement);
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
		
		var startSceneName: String = fast.node.StartScene.att.Name;

		for (sceneElement in fast.nodes.scenes) {
			var scene: Scene = ParseScene(sceneElement);
			game.scenes[scene.id] = scene;
			if (startSceneName == scene.id) {
				game.startScene = scene;
			}
		}
		
		return game;
	}

	public function new() 
	{
		
	}
	
}