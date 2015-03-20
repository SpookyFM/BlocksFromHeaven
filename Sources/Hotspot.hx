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
	
	// The radius is defined based on the u-axis
	public var radius: Float;
	
	public var id: String;
	
	public var onExamine: String;
	
	public var onUse: String;
	
	// What should happen when we look at this hotspot for a longer time?
	public var onGaze: String;
	
	public var onClick: String;
	
	public static var current: Hotspot;
	
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
		if (isOverNoBounds(vInImage.sub(adjust))) return true;
		return false;
	}
	
	
	public var IsGazeOver: Bool;
	
	public var GazeStartTime: Float;
	
	public var GazeExecuted: Bool;
	
	
	
	
	// TODO: Look into kha timers
	public function handleGaze(v: Vector2) {
		if (isOver(v)) {
			if (!IsGazeOver) {
				GazeStartTime = Sys.time();
				IsGazeOver = true;
				BlocksFromHeaven.instance.gazeActive = true;
				current = this;
			} else {
				if (!GazeExecuted) {
					var duration: Float = Sys.time() - GazeStartTime;
					if (duration > 1.0) {
						// After one second, call our gaze function
						GazeExecuted = true;
						Interpreter.the.interpret(onGaze);
					}
				}
			}
			
		} else {
			IsGazeOver = false;
			GazeExecuted = false;
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
	
	
	
	
	private function isOverNoBounds(v: Vector2): Bool {
		if ( v.sub(centerInImage).length < rInImage) return true;
		return false;
	}
	
	
	
	
	public function new() 
	{
		center = new Vector2();
	}
	
}