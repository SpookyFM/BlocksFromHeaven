package;


import haxe.ds.Vector;
import haxe.Timer;
import kha.Button;
import kha.Color;
import kha.Configuration;
import kha.graphics4.Graphics;
import kha.Framebuffer;
import kha.Game;
import kha.graphics4.CompareMode;
import kha.graphics4.CullMode;
import kha.Image;
import kha.Key;
import kha.Loader;
import kha.LoadingScreen;
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


import kha.vr.VrInterface;
import kha.math.Matrix4;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.math.Matrix4;

import GlobeMesh;
import UIElement;
import Ray;
import GameReader;

class BlocksFromHeaven extends Game {
	
	
	private var globe: GlobeMesh;
	private var fade: FadeMesh;
	
	private var images: Vector<Image>;
	private var numImages: Int = 4;
	private var currentImage: Int = 0;
	
	private var prev: Float = 0.0;
	
	private var hotspot: Hotspot;
	
	private var background: Image;
	private var overlay: Image;

	private var game: TestGame;
	
	private var transition: Transition;
	
	private var uiElement: UIElement;
	
	public function new() {
		super("BlocksFromHeaven", false);
	}
	
	override public function init(): Void {
		Configuration.setScreen(new LoadingScreen());
		Interpreter.init();
		Loader.the.loadRoom("blocks", loadingFinished);
	}
	
	
	
	
	
	private function loadingFinished(): Void {
		Configuration.setScreen(this);

		globe = new GlobeMesh(1, 1);
		globe.texture = Loader.the.getImage("panorama");
		
		images = new Vector<Image>(4);
		for (i in 0...numImages) {
			images[i] = Image.createRenderTarget(1024, 1024, TextureFormat.RGBA32);
		}
		
		background = Loader.the.getImage("panorama");
		overlay = Loader.the.getImage("overlay");
		
		
		
		fade = new FadeMesh();
		fade.fade(Color.fromFloats(0, 0, 0, 0), Color.fromFloats(0, 0, 0, 1), 3.0);
		
		game = new TestGame();
		transition = new Transition();
		transition.game = game;
		transition.fade = fade;
		transition.globe = globe;
		
		Commands.game = game;
		Commands.transition = transition;
	
		uiElement = new UIElement();
		uiElement.SetPosition(game.startScene.hotspots[0].getLonLat(), 5);
		uiElement.Offset = new Vector2(0, 2);
		uiElement.startAnimating();
		
		uiElement.Texture = Loader.the.getImage("arrow_forward");
		
		Interpreter.the.interpret(game.startScene.onEnter);
	}
	
	private function nextImage(): Image {
		currentImage++;
		if (currentImage == numImages) currentImage = 0;
		return images[currentImage];
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
		globe.render(g, mvp);
		
		
		g.flush();
		g.end();
		
		return p;
	}
	
	
	public function getViewMatrix(state: SensorState): Matrix4 {
		var orientation: Quaternion = state.Predicted.Pose.Orientation;
		
		//trace("Orientation: " + orientation.x + " " + orientation.y + " " + orientation.z + " " + orientation.w);

		var EyeYaw: Float;
		var EyePitch: Float;
		var EyeRoll: Float;

		var eulerAngles: Vector3 = orientation.getEulerAngles(Quaternion.AXIS_Y, Quaternion.AXIS_X, Quaternion.AXIS_Z);

		EyeYaw = eulerAngles.x;
		EyePitch = eulerAngles.y;
		EyeRoll = eulerAngles.z;
		
		//trace("Angles: EyeYaw:" + EyeYaw + " EyePitch " + EyePitch + " EyeRoll " + EyeRoll);
		
		var rollPitchYaw: Matrix4 = Matrix4.rotationY(EyeYaw).multmat(Matrix4.rotationX(EyePitch).multmat(Matrix4.rotationZ(EyeRoll)));
		
		return rollPitchYaw;
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

		
		
		for (hotspot in game.currentScene.hotspots) {
			hotspot.handleGaze(imageLocation);
			
			if (keypress) {
				if (hotspot.isOver(imageLocation)) {
					Interpreter.the.interpret(hotspot.onUse);
				}
				keypress = false;
			}
		}
		
		
		var curImage: Image = nextImage();
		var p:Matrix4 = renderIt(curImage, getViewMatrix(state));
		var vp: Matrix4 = getViewMatrix(state).multmat(p);
		
		// Render the fade texture
		fade.render(curImage.g4);
		
		uiElement.update();
		
		// Render the GUI element
		uiElement.render(curImage.g4, vp);
		
		var ray: Ray = getCameraRay(getViewMatrix(state));
		if (ray.intersects(uiElement.quad)) {
			uiElement.Texture = Loader.the.getImage("arrow_forward_active");
		} else {
			uiElement.Texture = Loader.the.getImage("arrow_forward");
		}
		
		
		var parms: TimeWarpParms = new TimeWarpParms();
		
		var leftTimeWarpImage: TimeWarpImage = new TimeWarpImage();
		leftTimeWarpImage.Image = curImage;
		leftTimeWarpImage.Pose = state.Predicted;
		
		var rightTimeWarpImage: TimeWarpImage = new TimeWarpImage();
		rightTimeWarpImage.Image = curImage;
		rightTimeWarpImage.Pose = state.Predicted;
		
		
		parms.LeftImage = leftTimeWarpImage;
		parms.RightImage = rightTimeWarpImage;
		
		var overlayTimeWarpImage: TimeWarpImage = new TimeWarpImage();
		overlayTimeWarpImage.Image = overlay;
		overlayTimeWarpImage.Pose = state.Predicted;
		overlayTimeWarpImage.TexCoordsFromTanAngles = p;
		
		parms.LeftOverlay = parms.RightOverlay = overlayTimeWarpImage;
		
		// TODO: Fix the version in Haxe
		leftTimeWarpImage.TexCoordsFromTanAngles = p;
		rightTimeWarpImage.TexCoordsFromTanAngles = p;		

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
	}
	
	
	
	override public function buttonDown(button: Button): Void {
		
	}
	
	override public function buttonUp(button: Button): Void {
		
	}
	
	override public function mouseDown(x: Int, y: Int): Void {
		super.mouseDown(x, y);
		
		#if ANDROID
			// TODO: Need to differentiate between the two buttons
			// On Android, mouse down means a touch of the touchpad
			keypress = true;
		#end
	}
	
	override public function mouseUp(x: Int, y: Int): Void {
		super.mouseUp(x, y);
		
	}
	
	override public function mouseMove(x: Int, y: Int): Void {
		super.mouseMove(x, y);
		
	}
}
