package;
import kha.Image;
import kha.math.Vector2;

/**
 * ...
 * @author Florian Mehm
 */
class Hotspot
{

	public var image: Image;
	
	// The center is defined in uv coordinates of the image
	public var center: Vector2;
	
	// The position where the UI element should be displayed
	public var uiCenter: Vector2;
	
	// The radius is defined based on the u-axis
	public var radius: Float;
	
	public var id: String;
	
	public var onExamine: String;
	
	public var onUse: String;
	
	// What should happen when we look at this hotspot for a longer time?
	public var onGaze: String;
	
	public var onClick: String;
	
	public var onTalkTo: String;
	
	public var onLook: String;
	
	public var onUseInventory: String;
	
	public static var current: Hotspot;
	
	public var enabled: Bool;
	
	
	private function isInsideCircle(c: Vector2, r: Float, v: Vector2): Bool {
		return ( v.sub(c).length < r);
	}
	
	private function getCoordsInImage(v: Vector2): Vector2 {
		return new Vector2(v.x * image.width, v.y * image.height);
	}
	
	// TODO: Re-implement using properties
	var vInImage: Vector2;
	var centerInImage: Vector2;
	var rInImage: Float; 
	
	// Returns true if the vector is inside the circle of this hotspot
	public function isOver(v: Vector2): Bool {
		// Do the calculations with the right aspect ratio
		
		// trace("Location in image: " + v.x * image.width + " " + v.y * image.height);
		
		vInImage = getCoordsInImage(v);
		centerInImage = getCoordsInImage(center);
		rInImage = radius * image.width;
		
		if (isInsideCircle(centerInImage, rInImage, vInImage)) return true;
		
		
		// We need to check if the circle touches one of the sides
		var adjust: Vector2 = new Vector2();
		if (vInImage.x - rInImage < 0) {
			// Might be ovInImageer the left side
			adjust.x = -image.width;
		} else if (vInImage.x + rInImage > image.width)
			// Might be ovInImageer the right side
			adjust.x = image.width;
		if (vInImage.y - rInImage < 0) {
			// Might be ovInImageer the top
			adjust.y = -image.height;
		} else if (vInImage.y + rInImage > image.height) {
			// Might be below the bottom
			adjust.y = image.height;
		} 
		if (isOverNoBounds(vInImage.sub(adjust))) {
			return true;
		}
		return false;
	}
	
	
	public var IsGazeOver: Bool;
	
	public var GazeStartTime: Float;
	
	public var GazeExecuted: Bool;
	
	public var GazeLostTime: Float;
	
	public var GazeLostExecuted: Bool;
	
	
	// TODO: Look into kha timers
	public function handleGaze(v: Vector2) {
		if (!enabled) return;
		
		if (isOver(v)) {
			if (!IsGazeOver) {
				GazeStartTime = Sys.time();
				IsGazeOver = true;
				BlocksFromHeaven.instance.gazeActive = true;
			} else {
				if (!GazeExecuted) {
					var duration: Float = Sys.time() - GazeStartTime;
					// Set the gaze cursor's active state
					var gazeCursor: GazeCursor = BlocksFromHeaven.instance.gazeCursor;
					var t: Float = duration;
					t = Math.min(t, 1.0);
					gazeCursor.active = t;
					
					if (duration > 1.0) {
						
						// After one second, call our gaze function
						GazeExecuted = true;
						BlocksFromHeaven.instance.clearUI();
						current = this;
						Interpreter.the.interpret(onGaze);
					}
				}
			}
			
		} else {
			if (IsGazeOver) {
				GazeLostTime = Sys.time();
				IsGazeOver = false;
				GazeExecuted = false;
				GazeLostExecuted = false;
				BlocksFromHeaven.instance.gazeActive = false;
			}
			
			var duration: Float = Sys.time() - GazeLostTime;
			if (duration > 0.5) {
				if (!GazeLostExecuted) {
					// trace("Gaze lost - removing ui elements");
					// BlocksFromHeaven.instance.clearUI();
					GazeLostExecuted = true;
				}
			}
			
			
		}
		
		/* if (isOver(v)) {
			Interpreter.the.interpret(onExamine);
		} */
	}
	
	
	
	public function getLonLat(): Vector2 {
		var result: Vector2 = new Vector2();
		result.x = center.x * Math.PI * 2;
		result.y = (center.y - 0.5) * Math.PI;
	
		
		return result;
	}
	
	public function getUILonLat(): Vector2 {
		var result: Vector2 = new Vector2();
		result.x = uiCenter.x * Math.PI * 2;
		result.y = (uiCenter.y - 0.5) * Math.PI;
	
		
		return result;
	}
	
	
	
	private function isOverNoBounds(v: Vector2): Bool {
		if ( v.sub(centerInImage).length < rInImage) return true;
		return false;
	}
	
	
	
	
	public function new() 
	{
		center = new Vector2();
		uiCenter = new Vector2();
		enabled = true;
	}
	
}