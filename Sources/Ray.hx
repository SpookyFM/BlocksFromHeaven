package;
import kha.math.Vector3;
import kha.math.Vector4;

/**
 * ...
 * @author Florian Mehm
 */
class Ray
{

	public var direction: Vector4;
	
	public var origin: Vector4;
	
	public function intersects(quad: Quad): Bool {
		
		
		var s: Vector4 = quad.center.sub(origin);

		var d3: Vector3 = new Vector3(direction.x, direction.y, direction.z);
		var n3: Vector3 = new Vector3(quad.normal.x, quad.normal.y, quad.normal.z);
		
		var d: Float = new Vector3(s.x, s.y, s.z).dot(n3);
		d = d / d3.dot(n3);
		
		// We assume direction to be normalized 
		direction = direction.mult(1 / direction.length);
		var intersection: Vector4 = origin.add(direction.mult(d));
		
		// Check if intersection is inside the quad
		// TODO: Why does it work with the transpose?
		var intersectionInPlane: Vector4 = quad.worldMatrix.inverse().transpose().multvec(intersection);
		
		
		trace("Intersection point: " + intersectionInPlane.x + " " + intersectionInPlane.y + " " + intersectionInPlane.z + " " + intersectionInPlane.w);
		
		
		return (Math.abs(intersectionInPlane.x) < 1.0 && Math.abs(intersectionInPlane.y) < 1.0);
	}
	
	public function new() 
	{
		
	}
	
}