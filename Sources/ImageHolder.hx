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
		if (!isDirty) {
			image.unload();
			image = null;
		}
	}
	

	public function new() 
	{
		
	}
	
}