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
	
	
	public function handleGaze(v: Vector2) {
		if (isOver(v)) {
			Interpreter.the.interpret(onExamine);
		}
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