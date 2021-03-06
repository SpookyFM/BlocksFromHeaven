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
	
	public var toExamine: Bool = false;
	
	public var fromExamine: Bool = false;
	
	public function start(from: Scene, to: Scene, duration: Float, color: Color) {
		startScene = from;
		endScene = to;
		fadeDuration = duration;
		fadeColor = color;
		
		startTime = Sys.time();
		
		var startColor: Color = color;
		startColor.A = 0;
		
		fade.fade(color, startColor, fadeDuration);
		
		finished = false;
		active = true;
		
		
		// Start loading new textures here
		
	}
	
	
	
	public function update() {
		if (!active) return;
		if (!startSceneLeft) {
			// We are waiting for the fade to finish
			if (fade.isFinished()) {
				// Unload the old images
				startScene.leave();	
				
				
				endScene.enter(function() { 
					// Switch out the image
					globe.texture = endScene.background.image;
					globe.blurredTexture = endScene.blurredBackground;
					
					if (toExamine) {
						globe.blurredTexture = endScene.background.image;
					}
					
					// Start a new fade in
					var startColor: Color = fadeColor;
					startColor.A = 0;
					fade.fade(startColor, fadeColor, fadeDuration);
					
					// Remove all UI elements
					BlocksFromHeaven.instance.uiElements.splice(0, BlocksFromHeaven.instance.uiElements.length); 
					
					// Reset the active hotspot
					Hotspot.current = null;
					BlocksFromHeaven.instance.gazeActive = false;
					
					if (!toExamine || !fromExamine) {
						// Execute the two commands
						Interpreter.the.interpret(game.currentScene.onLeave);
					}
					
					game.currentScene = endScene;
					game.currentScene.visitCount += 1;
					
					
					
					Interpreter.the.interpret(game.currentScene.onEnter);
					
					
					
					startSceneLeft = true;
					
					
					
				} );
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