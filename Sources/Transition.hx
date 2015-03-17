package;
import kha.Color;

/**
 * ...
 * @author Florian Mehm
 */
class Transition
{

	public var startScene: Scene;
	public var endScene: Scene;
	
	public var fadeDuration: Float;
	public var fadeColor: Color;
	
	private var startTime: Float;
	
	public var globe: GlobeMesh;
	public var fade: FadeMesh;
	public var game: TestGame;
	
	private var startSceneLeft: Bool = false;
	
	private var finished: Bool = false;
	
	private var active: Bool = false;
	
	public function start(from: Scene, to: Scene, duration: Float, color: Color) {
		startScene = from;
		endScene = to;
		fadeDuration = duration;
		fadeColor = color;
		
		startTime = Sys.time();
		
		fade.fade(color, Color.fromFloats(0, 0, 0, 0), fadeDuration);
		
		finished = false;
		active = true;
	}
	
	
	
	public function update() {
		if (!active) return;
		if (!startSceneLeft) {
			// We are waiting for the fade to finish
			if (fade.isFinished()) {
				// Switch out the image
				globe.texture = endScene.background;
				// Start a new fade in
				fade.fade(Color.fromFloats(0, 0, 0, 0), fadeColor, fadeDuration);
				
				game.currentScene = endScene;
				startSceneLeft = true;
			}
		} else {
			// We are waiting for the second fade
			finished = fade.isFinished();
			active = false;
			startSceneLeft = false;
		}
	}
	
	
	public function new() 
	{
		
	}
	
}