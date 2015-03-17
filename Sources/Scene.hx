package;
import kha.Image;

/**
 * ...
 * @author Florian Mehm
 */
class Scene
{

	public var background: Image;
	
	public var id: String;
	
	public var onEnter: String;
	
	public var hotspots: Array<Hotspot>;
	
	public function new() 
	{
		hotspots = new Array<Hotspot>();
		
	}
	
}