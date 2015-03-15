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
	
	public var center: Vector2;
	
	public var radius: Float;
	
	public var id: String;
	
	public var onExamine: String;
	
	public var onUse: String;
	
	
	// Returns true if the vector is inside the circle of this hotspot
	public function isOver(v: Vector2): Bool {
		if ( (v - center).length < radius) return true;
		
		// We need to check if the circle touches one of the sides
		var adjust: Vector2 = new Vector2();
		if (v.x - radius < 0) {
			// Might be over the left side
			adjust.x = -image.width;
		} else if (v.x + radius > image.width)
			// Might be over the right side
			adjust.x = image.width;
		if (v.y - radius < 0) {
			// Might be over the top
			adjust.y = -image.height;
		} else if (v.y + radius > image.height) {
			// Might be below the bottom
			adjust.y = image.height;
		} 
		if (isOverNoBounds(v - adjust)) return true;
		return false;
	}
	
	private function isOverNoBounds(v: Vector2): Bool {
		if ( (v - center).length < radius) return true;
		return false;
	}
	
	public function new() 
	{
		
	}
	
}