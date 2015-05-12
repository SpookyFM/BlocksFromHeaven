package;


import haxe.ds.Vector;
import haxe.Timer;
import kha.Button;
import kha.Color;
import kha.Configuration;
import kha.Font;
import kha.graphics4.Graphics;
import kha.Framebuffer;
import kha.Game;
import kha.graphics4.CompareMode;
import kha.graphics4.CullMode;
import kha.Image;
import kha.input.Mouse;
import kha.Key;
import kha.Loader;
import kha.LoadingScreen;
import kha.math.Matrix3;
import kha.math.Quaternion;
import kha.math.Random;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Scaler;
import kha.Scheduler;
import kha.Sound;
import kha.vr.SensorState;
import kha.vr.TimeWarpImage;
import kha.vr.TimeWarpParms;

import kha.Font;
import kha.FontStyle;


import kha.vr.VrInterface;
import kha.math.Matrix4;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.math.Matrix4;

import GlobeMesh;
import UIElement;
import Ray;
import GameReader;
import VignetteMesh;
import GameReader;
import GazeCursor;
import ActionType;
import BlurFilter;
import LinearVRMenu;



class BlocksFromHeaven extends Game {
	
	
	public var globe: GlobeMesh;
	private var fade: FadeMesh;
	
	private var images: Vector<Image>;
	private var imagesR: Vector<Image>;
	private var numImages: Int = 4;
	private var currentImage: Int = 0;
	private var currentImageR: Int = 0;
	
	private var prev: Float = 0.0;
	
	private var vignette: VignetteMesh;
	
	private var ipd: Float = 0.065;
	

	private var game: TestGame;
	
	private var transition: Transition;
	
	public var uiElements: Array<UIElement>;
	
	public static var instance: BlocksFromHeaven;
	
	
	public var gazeCursor: GazeCursor;
	
	public var blurredBackground: Bool;
	
	public var gazeActive: Bool;
	
	public var inventoryActive: Bool;
	
	public var inventoryExamineActive: Bool;
	
	// TODO: Change to another system once several actions can be active at the same time
	public var currentAction: ActionType;
	
	public var inventoryMenu: LinearVRMenu;
	
	public var inventoryType: InventoryType = InventoryType.Examine;
	
	public var f: Font;
	
	public function new() {
		super("BlocksFromHeaven", false);
		trace("SteamQuest new");
	}
	
	override public function init(): Void {
		trace("Steamquest init");
		instance = this;
		Configuration.setScreen(new LoadingScreen());
		uiElements = new Array<UIElement>();
		Loader.the.loadRoom("blocks", loadingFinished);
		Mouse.get(0).notify(mouseDownEvent, mouseUpEvent, null, null);
		inventoryMenu = new LinearVRMenu();
		inventoryMenu.Center = new Vector2(0, 0);
		
	}
	
	
	
	
	public function showInventory(type: InventoryType) {
		// Disable the hotspots
		inventoryActive = true;
		inventoryType = type;
		
		
		var filter: BlurFilter = new BlurFilter();
		filter.texture = game.currentScene.background;
		var image: Image = Image.createRenderTarget(game.currentScene.background.width, game.currentScene.background.height, TextureFormat.RGBA32);
		image.g4.begin();
		filter.render(image.g4);
		image.g4.end();
		globe.blurredTexture = image;
		game.currentScene.blurredBackground = image;
		
		
		// Blur the background
		globe.startAnimating(-1, 1);
		
		// Remove all UI elements
		uiElements.splice(0, uiElements.length);
		
		inventoryMenu.Clear();
		
		// Show the inventory items
		for (item in game.inventory) {
			var uiElement: UIElement = new UIElement();
			inventoryMenu.AddItem(uiElement);
			uiElement.InactiveTexture = item.image;
			uiElement.ActiveTexture = item.activeImage;
			uiElement.Texture = uiElement.InactiveTexture;
			uiElement.isExit = false;
			uiElement.Offset = new Vector2(0, 0);
			uiElement.Scale = 0.7;
			
			var onClick: Void -> Void;
			if (type == InventoryType.Examine) {
				onClick = function() {
					Interpreter.the.interpret(item.onExamine);
				}
			} else {
				onClick = function() {
					game.ActiveInventory = item.id;
					hideInventory();
					Interpreter.the.interpret(Hotspot.current.onUseInventory);
				}
			}
			uiElement.OnClick = onClick;
		}
	}
	
	
	public function hideInventory() {
		// Enable hotspots
		inventoryActive = false;
		
		// Un-blur the background
		globe.startAnimating(1, 1);
	}
	
	
	public function clearUI() {
		uiElements.splice(0, uiElements.length);
	}
	
	
	
	
	private function loadingFinished(): Void {
		trace("Start of loading finished");
		Configuration.setScreen(this);
		Interpreter.init();

		
		
		images = new Vector<Image>(4);
		imagesR = new Vector<Image>(4);
		for (i in 0...numImages) {
			var w: Int = 1024;
			var h: Int = 1024;
			
			#if VR_RIFT
				w = 1182;
				h = 1464;
			#end
			
			
			images[i] = Image.createRenderTarget(w, h, TextureFormat.RGBA32);
			imagesR[i] = Image.createRenderTarget(w, h, TextureFormat.RGBA32);
		}
		
		gazeCursor = new GazeCursor();
		gazeCursor.activeImage = Loader.the.getImage("gazeCursor_active");
		gazeCursor.inactiveImage = Loader.the.getImage("gazeCursor_inactive");
		gazeCursor.cutoffImage = Loader.the.getImage("gazeCursor_cutoff");
		gazeCursor.depth = 2.0;
		gazeCursor.scale = 0.05;
		
		
		
		
		
		
		fade = new FadeMesh();
		fade.fade(Color.fromFloats(0, 0, 0, 0), Color.fromFloats(0, 0, 0, 1), 3.0);
		
		var reader: GameReader= new GameReader();
		game = reader.Read();
		
		//game = new TestGame();
		
		globe = new GlobeMesh(1, 1);
		globe.texture = game.startScene.background;
		globe.blurredTexture = game.startScene.blurredBackground;
		
		
		
		transition = new Transition();
		transition.game = game;
		transition.fade = fade;
		transition.globe = globe;
		
			
		
		
		
		Commands.game = game;
		Commands.transition = transition;
	
		
		
		Interpreter.the.interpret(game.startScene.onEnter);
		
		vignette = new VignetteMesh(0.01);
		
		
		f = Loader.the.loadFont("zorus", FontStyle.Default, 18.0);
		
		trace("Loading finished");
	}
	
	private function nextImage(): Image {
		currentImage++;
		if (currentImage == numImages) currentImage = 0;
		return images[currentImage];
	}
	
	private function nextImageR(): Image {
		currentImageR++;
		if (currentImageR == numImages) currentImageR = 0;
		return imagesR[currentImageR];
	}
	
	
	private function degreesToRadians(d: Float): Float {
		return d * Math.PI / 180;
	}
	
	// Convert a standard projection matrix into a TanAngle matrix for
	// the primary time warp surface.
	function TanAngleMatrixFromProjection(projection: Matrix4): Matrix4
	{
		
		// A projection matrix goes from a view point to NDC, or -1 to 1 space.
		// Scale and bias to convert that to a 0 to 1 space.

		var proj: Matrix4 = Matrix4.empty();
		
		for (x in 0...4) for (y in 0...4) {
			proj.set(x, y, projection.get(x, y));
		}
		
		for (i in 2...4) {
			proj.set(i, 0, 0);
			proj.set(i, 1, 0);
			proj.set(i, 2, -1);
			proj.set(i, 3, 0);
		}
	
		var t: Matrix4 = Matrix4.translation(0.5, 0.5, 0);
		var s: Matrix4 = Matrix4.scale(0.5, 0.5, 1);
		
		return s.multmat(t);
	}
	
	function renderIt(target: Image, v: Matrix4): Matrix4 {
		// Rotate 90 degrees: The globe mesh starts out rotated
		var m: Matrix4 = Matrix4.rotationY(-Math.PI / 2.0);
		var p: Matrix4 = Matrix4.perspectiveProjection(degreesToRadians(90), 1, 0.1, 200);
		
		var vm: Matrix4 = v.multmat(m);
		var mvp: Matrix4 = p.multmat(vm);
		
		mvp = m.multmat(v.multmat(p));
		
		
		var g: Graphics = target.g4;
		
		g.begin();
		g.clear(Color.Green);
		globe.update();
		globe.render(g, mvp);
		
		
		g.flush();
		g.end();
		
		return p;
	}
	
	
	public function getViewMatrix(state: SensorState, ?eye: Int = 0): Matrix4 {
		var orientation: Quaternion = state.Predicted.Pose.Orientation;
		
		//trace("Orientation: " + orientation.x + " " + orientation.y + " " + orientation.z + " " + orientation.w);

		var EyeYaw: Float;
		var EyePitch: Float;
		var EyeRoll: Float;

		var eulerAngles: Vector3 = orientation.getEulerAngles(Quaternion.AXIS_Y, Quaternion.AXIS_X, Quaternion.AXIS_Z);

		EyeYaw = eulerAngles.x;
		EyePitch = eulerAngles.y;
		EyeRoll = eulerAngles.z;
		
		// trace("Angles: EyeYaw:" + EyeYaw + " EyePitch " + EyePitch + " EyeRoll " + EyeRoll);
		#if VR_CARDBOARD
		var rollPitchYaw: Matrix4 = Matrix4.rotationY(EyeYaw).multmat(Matrix4.rotationX(EyePitch).multmat(Matrix4.rotationZ( -EyeRoll)));
		#else
		var rollPitchYaw: Matrix4 = Matrix4.rotationY(EyeYaw).multmat(Matrix4.rotationX(EyePitch).multmat(Matrix4.rotationZ(EyeRoll)));
		#end
		
		var eyeOffset: Float = ipd * 0.5;
		if (eye == 0) eyeOffset = eyeOffset * -1;
		
		var translation: Matrix4 = Matrix4.translation(eyeOffset, 0, 0);
		
		return rollPitchYaw.multmat(translation);
	}
	
	public function getViewCenter(orientation: Quaternion): Vector2 {
		var eulerAngles: Vector3 = orientation.getEulerAngles(Quaternion.AXIS_Y, Quaternion.AXIS_X, Quaternion.AXIS_Z);

		// Yaw is mapped to u
		// yaw of 0 is straight ahead: middle of the image
		var u: Float = eulerAngles.x + Math.PI;
		if (u < 0.0) {
			u = u + Math.floor(Math.abs((u / (2 * Math.PI)))) * 2 * Math.PI;
		}
		if (u > Math.PI * 2) {
			u = u - Math.floor(Math.abs((u / (2 * Math.PI)))) * 2 * Math.PI;
		}
		
		u = 1 - (u / (Math.PI * 2));
		
		
		
		// Pitch is handled similarly - but only goes from -90 to 90
		var v: Float = eulerAngles.y;
		
		if (v < -Math.PI) {
			v = v + (Math.floor(Math.abs((v / Math.PI)) - 1)) * Math.PI;
		}
		
		if (v > Math.PI) {
			v = v - (Math.floor(Math.abs((v / Math.PI)) - 1)) * Math.PI;
		}
		
		
		v = v / Math.PI + 0.5;
		
		
		
		
		return new Vector2(u, v);
	}
	
	public function getCameraRay(worldMatrix: Matrix4): Ray {
		var r: Ray = new Ray();
		r.direction = worldMatrix.multvec(new Vector4(0, 0, -1, 0));
		r.origin = new Vector4(0, 0, 0, 1);
		
		return r;
	}

	
	override public function render(framebuffer: Framebuffer): Void {
		var now: Float = VrInterface.instance.GetTimeInSeconds();
		var rawDelta: Float = now - prev;
		prev = now;
		
		var clampedPrediction = Math.min(0.1, rawDelta * 2.0);
		var state: SensorState = VrInterface.instance.GetPredictedSensorState(now + clampedPrediction);
	
		
		var imageLocation: Vector2 = getViewCenter(state.Predicted.Pose.Orientation);

		
		if (!inventoryActive) {
			for (hotspot in game.currentScene.hotspots) {
				hotspot.handleGaze(imageLocation);
			}
		} 
		
		var ray: Ray = getCameraRay(getViewMatrix(state));
		
		if (keypress) {
			if (!inventoryActive) {
				for (uiElement in uiElements) {
					if (ray.intersects(uiElement.quad)) {
						uiElement.OnClick();
					}
					if (uiElement.isExit) {
						if (Hotspot.current.IsGazeOver) {
							uiElement.OnClick();
						}
					}
				}
			} else {
				inventoryMenu.HandleKeyPress();
			}
			keypress = false;
		}
		
		var parms: TimeWarpParms = new TimeWarpParms();
		var leftTimeWarpImage: TimeWarpImage = new TimeWarpImage();
		var rightTimeWarpImage: TimeWarpImage = new TimeWarpImage();
		
		for (eye in 0...2) {
		
			var curImage: Image;
			if (eye == 0) {
				curImage =  nextImage();
			} else {
				curImage = nextImageR();
			}
			var p:Matrix4 = renderIt(curImage, getViewMatrix(state, eye));
			var vp: Matrix4 = getViewMatrix(state, eye).multmat(p);
			
			if (inventoryActive) {
				inventoryMenu.Update();
				inventoryMenu.Render(curImage.g4, vp);
				// TODO: Should be the other way around
				inventoryMenu.HandleGaze(getCameraRay(getViewMatrix(state)));
			}
			
			for (uiElement in uiElements) {
				uiElement.update();

				// Render the GUI element
				uiElement.render(curImage.g4, vp);
				
				
				if (ray.intersects(uiElement.quad)) {
					uiElement.Texture = uiElement.ActiveTexture;
					gazeActive = true;
					gazeCursor.active = 1.0;
				} else {
					uiElement.Texture = uiElement.InactiveTexture;
				} 
				
				if (uiElement.isExit) {
					// The exit should be active as long as the cursor is over the hotspot (anywhere)
					if (Hotspot.current.IsGazeOver) {
						uiElement.Texture = uiElement.ActiveTexture;
					}
					
				}
			
				
			}
			
			// Render the fade texture
			fade.render(curImage.g4);
			
			
			
			
			if (!gazeActive) gazeCursor.active = 0;
			
			gazeCursor.render(curImage.g4, p);
			
			curImage.g2.begin(false);
			curImage.g2.set_transformation(Matrix3.scale(1, -1));
			curImage.g2.set_color(Color.Red);
			curImage.g2.set_font(f);
			//curImage.g2.drawString("Hello, world!", 512, -512);
			curImage.g2.end();
			
			// Build a vignette around the texture
			// vignette.render(curImage.g4);
			
			if (eye == 0) {
				leftTimeWarpImage.Image = curImage;
				// TODO: Fix the version in Haxe
				leftTimeWarpImage.TexCoordsFromTanAngles = p;
			} else {
				rightTimeWarpImage.Image = curImage;
				rightTimeWarpImage.TexCoordsFromTanAngles = p;		
			}
		
		}
		
		
		
		
		leftTimeWarpImage.Pose = state.Predicted;
		rightTimeWarpImage.Pose = state.Predicted;
		
		
		parms.LeftImage = leftTimeWarpImage;
		parms.RightImage = rightTimeWarpImage;
		

		VrInterface.instance.WarpSwap(parms);
	}
	
	
	override public function update(): Void {		
		transition.update();
	}
	
	private var keypress: Bool = false;
	
	override public function keyDown(key:Key, char:String):Void 
	{
		super.keyDown(key, char);
		if (char == " ") {
			keypress = true;
		}
		if (char == "i") {
			if (!inventoryActive)   {
				if (!inventoryExamineActive) {
					showInventory(InventoryType.Examine);
				}
			} else {
				hideInventory();
			}
		}
	}
	
	
	
	override public function buttonDown(button: Button): Void {
		
	}
	
	override public function buttonUp(button: Button): Void {
		
	}
	
	private var lastMouseDown: Float;
	
	public function mouseUpEvent(button: Int, x: Int, y: Int): Void {
		var duration: Float = Sys.time() - lastMouseDown;
		// TODO: Quick hack since the mapping of GearVR's second button doesn't seem to work
		/* if (duration > 1) {
			// Switch between blurred and unblurred
			if (blurredBackground) {
				globe.startAnimating(1, 1);
			} else {
				globe.startAnimating(-1, 1);
			}
			blurredBackground = !blurredBackground;
		} else { */
		#if ANDROID
			keypress = true;
		#end
		// }
	}
	
	
	public function mouseDownEvent(button: Int, x: Int, y: Int): Void {
		lastMouseDown = Sys.time();
	}
	
}
