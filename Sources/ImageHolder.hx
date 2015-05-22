package;




import kha.Image;
import kha.Loader;
import kha.loader.Room;


/**
 * ...
 * @author Florian Mehm
 */
class ImageHolder
{
	// Must call "load" before accessing the image. Also remember to unload when it is not used anymore.
	public var image: Image;
	
	public var name: String;
	
	private var isDirty: Bool;
	
	private var room: Room;
	
	private static var allImages: Map<String, ImageHolder>;
	
	public function exchangeImage(i: Image): Void {
		image.unload();
		image = i;
	}
	
	
	public static function getHolder(s: String): ImageHolder {
		var i: ImageHolder = allImages.get(s);
		// Check if we have already loaded this image before
		if (i == null) {
			// Create one
			i = new ImageHolder();
			i.name = s;
			i.register();
		} 
		return i;
	}
	
	public static function initStatic(): Void {
		allImages = new Map<String, ImageHolder>();
	}
	
	
	public function register(): Void {
		allImages.set(name, this);
	}
	
	
	public function setDirty(): Void {
		isDirty = true;
	}
	
	
	
	public function load(call: Void -> Void): Void {
		if (!isDirty) {
			Loader.the.autoCleanupAssets = false;
			Loader.the.loadRoom(name, function() {
				image = Loader.the.getImage(name);
				call();			
			});
		}
	}
	
	public function unload(): Void {
		if (image != null)
		if (!isDirty) {
			Loader.the.unloadedImage(name);
			image = null;
		}
	}
	

	public function new() 
	{
		
	}
	
}