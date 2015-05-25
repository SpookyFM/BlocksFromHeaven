package;
import kha.graphics4.TextureFormat;
import kha.Image;

/**
 * ...
 * @author Florian Mehm
 */
class Blur
{
	// See http://stackoverflow.com/questions/6849663/creating-blur-filter-with-a-shader-access-adjacent-pixels-from-fragment-shader/6902143#6902143
	
	
	public static function BlurImage(image: Image, textureFormat: TextureFormat): Image {
		var blur: BlurFilter = new BlurFilter();
		
		var blurred: Image = Image.createRenderTarget(image.width, image.height, textureFormat);
		
		blurred.g4.begin();
		
		blur.texture = image;
		
		blur.render(blurred.g4);
		
		blurred.g4.end();
		
		return blurred;
	}
	
	
	public static function BlurInPlace(target: Image, image: Image, textureFormat: TextureFormat) {
		var blur: BlurFilter = new BlurFilter();
		
		var blurred: Image = target;
		
		blurred.g4.begin();
		
		blur.texture = image;
		
		blur.render(blurred.g4);
		
		blurred.g4.end();
		
		return blurred;
	}
	
	public function new() 
	{
		
	}
	
}