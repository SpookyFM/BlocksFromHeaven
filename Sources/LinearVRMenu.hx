package;
import kha.graphics4.Graphics;
import kha.math.Matrix4;
import kha.math.Vector4;
import kha.math.Vector2;

/**
 * A menu in the style of the Oculus VR menus, with support for selecting using gaze and swiping using a touchpad.
 * @author Florian Mehm
 */
class LinearVRMenu
{
	// A list of menu items that is organized in this class
	public var MenuItems: Array<UIElement>;
	
	// Position of the center of the inventory (in lat/lon coordinates)
	public var Center: Vector2;
	
	
	// How many items should be visible without needing scrolling?
	public var MaxNumItems: Int;
	
	// How many items are in the menu?
	public var NumItems: Int;
	
	// What is the index of the currently leftmost item?
	public var CurrentIndex: Int;
	
	public var ActiveElement: UIElement;
	
	public function ScrollLeft() {
		
	}
	
	public function ScrollRight() {
		
	}
	
	public var SelectedItem: UIElement;
	
	public function AddItem(item: UIElement) {
		MenuItems.push(item);
		item.SetPosition(Center, -3);
		ArrangeItems();
	}
	
	private function ArrangeItems() {
		var itemWidth: Float = Math.PI * 2.0 / 20;
		var allItemsWidth: Float = itemWidth * MenuItems.length;
		var index: Int = 0;
		for (item in MenuItems) {
			item.SetPosition(new Vector2(Center.x - allItemsWidth / 2.0 + itemWidth * index, Center.y), -3);
			index++;
		}
	}
	
	public function Update() {
		for (item in MenuItems) {
			item.update();
		}
	}
	
	public function HandleGaze(ray: Ray) {
		ActiveElement = null;
		for (uiElement in MenuItems) {
			if (ray.intersects(uiElement.quad)) {
				uiElement.Texture = uiElement.ActiveTexture;
				ActiveElement = uiElement;
			} else {
				uiElement.Texture = uiElement.InactiveTexture;
			} 
		}
	}
	
	public function HandleKeyPress() {
		if (ActiveElement != null) {
			ActiveElement.OnClick();
		}
	}
	
	public function Render(g4: Graphics, vp: Matrix4) {
		for (item in MenuItems) {
			item.render(g4, vp);
		}
	}
	
	public function Clear() {
		MenuItems.splice(0, MenuItems.length);
	}
	
	// This class needs to 
	// Handle opening and closing the menu
	// Handle swipe events
	

	public function new() 
	{
		MenuItems = new Array<UIElement>();
	}
	
}