package;
import kha.graphics4.TextureFormat;
import kha.Image;

/**
 * ...
 * @author Florian Mehm
 */
class Scene
{

	public var background: Image;
	
	public var blurredBackground: Image;
	
	public function setBackground(image: Image) {
		// Blur the image and save the result
		background = image;
		blurredBackground = Blur.BlurImage(background, TextureFormat.RGBA32);
	}
	
	public var id: String;
	
	public var onEnter: String;
	
	public var onLeave: String;
	
	public var visitCount: Int = 0;
	
	public var hotspots: Map<String, Hotspot>;
	
	public function new() 
	{
		hotspots = new Map<String, Hotspot>();
		
	}
	
}