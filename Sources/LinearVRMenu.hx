package;
import kha.math.Vector4;

/**
 * A menu in the style of the Oculus VR menus, with support for selecting using gaze and swiping using a touchpad.
 * @author Florian Mehm
 */
class LinearVRMenu
{
	// A list of menu items that is organized in this class
	public var MenuItems: Array<UIElement>;
	
	// Where does the menu start?
	public var Position: Vector4;
	
	public var SelectedItem: UIElement;
	
	// This class needs to 
	// Handle opening and closing the menu
	// Handle swipe events
	

	public function new() 
	{
		
	}
	
}