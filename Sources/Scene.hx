package;
import kha.graphics4.TextureFormat;
import kha.Image;

/**
 * ...
 * @author Florian Mehm
 */
class Scene
{

		
	public var background: ImageHolder;
	
	// Call will be called when the scene is ready
	public function enter(call: Void -> Void) {
		background.load(function() { call(); } );
	}
	
	public function leave() {
		/* if (blurredBackground != null)
			blurredBackground.unload();
		blurredBackground = null; */
		background.unload();
	}
	
	
	public var id: String;
	
	public var onEnter: String;
	
	public var onLeave: String;
	
	public var visitCount: Int = 0;
	
	public var hotspots: Map<String, Hotspot>;
	
	public function new() 
	{
		hotspots = new Map<String, Hotspot>();
		background = new ImageHolder();
		
	}
	
}