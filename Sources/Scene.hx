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
	
	public var blurredBackground: Image;
	
	
	
	// TODO: How to ensure that this is not called when the image is not loaded?
	public function updateBlurredBackground() {
		var oldBlur = blurredBackground;
		trace("Blurring: " + background.image);
		blurredBackground = Blur.BlurImage(background.image, TextureFormat.RGBA32);
		if (oldBlur != null) {
			oldBlur.unload();
		}
	}
	
	
	
	// Call will be called when the scene is ready
	public function enter(call: Void -> Void) {
		background.load(function() { updateBlurredBackground(); call(); } );
	}
	
	public function leave() {
		if (blurredBackground != null)
			blurredBackground.unload();
		blurredBackground = null;
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