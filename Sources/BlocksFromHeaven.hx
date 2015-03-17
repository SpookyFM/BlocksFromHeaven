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
import kha.Loader;
import kha.LoadingScreen;
import kha.math.Quaternion;
import kha.math.Random;
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

import BigBlock;

class BlocksFromHeaven extends Game {
	private var board: Image;
	private var count: Int = 0;
	private var faster: Bool = false;
	private var klackSound: Sound;
	private var lineSound: Sound;
	private var backbuffer: Image;
	
	private var globe: GlobeMesh;
	
	private var images: Vector<Image>;
	private var numImages: Int = 4;
	private var currentImage: Int = 0;

	public function new() {
		super("BlocksFromHeaven", false);
	}
	
	override public function init(): Void {
		Configuration.setScreen(new LoadingScreen());
		Loader.the.loadRoom("blocks", loadingFinished);
		
		
		
	}
	
	
	
	
	
	private function loadingFinished(): Void {
		Random.init(Std.int(Timer.stamp() * 1000));
		
		backbuffer = Image.createRenderTarget(272, 480);
		
		for (x in 0...GameBlock.xsize) for (y in 0...GameBlock.ysize) {
			GameBlock.blocked.push(new Array<GameBlock>());
			GameBlock.blocked[x].push(null);
		}
		
		for (y in 0...GameBlock.ysize) GameBlock.blocked[0][y] = new GameBlock(0, y, null);
		for (y in 0...GameBlock.ysize) GameBlock.blocked[GameBlock.xsize - 1][y] = new GameBlock(GameBlock.xsize - 1, y, null);
		for (x in 0...GameBlock.xsize) GameBlock.blocked[x][0] = new GameBlock(x, 0, null);
		
		current = createRandomBlock();
		current.hop();
		next = createRandomBlock();
		
		board = Loader.the.getImage("board");
		klackSound = Loader.the.getSound("klack");
		lineSound = Loader.the.getSound("line");
		
		Configuration.setScreen(this);
		Loader.the.getMusic("blocks").play();
		
		globe = new GlobeMesh(1, 1);
		globe.texture = Loader.the.getImage("panorama");
		
		coloredImage = Image.createRenderTarget(1024, 1024, TextureFormat.RGBA32);
		redImage = Image.createRenderTarget(1024, 1024, TextureFormat.RGBA32);
		
		images = new Vector<Image>(4);
		for (i in 0...numImages) {
			//images[i] = Image.createRenderTarget(1024, 1024, TextureFormat.RGBA32, true, 1);
			images[i] = Image.createRenderTarget(1024, 1024, TextureFormat.RGBA32);
		}
		
	}
	
	private function nextImage(): Image {
		currentImage++;
		if (currentImage == numImages) currentImage = 0;
		return images[currentImage];
	}
	
	
	private function degreesToRadians(d: Float): Float {
		return d * Math.PI / 180;
	}
	
	var prev: Float;
	
	var coloredImage: Image;
	var redImage: Image;
	
	
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
		var m: Matrix4 = Matrix4.identity();
		
		var p: Matrix4 = Matrix4.perspectiveProjection(degreesToRadians(90), 1, 0.1, 200);
		
		
		
		
		var vm: Matrix4 = v.multmat(m);
		var pvm: Matrix4 = p.multmat(vm);
		
		pvm = v.multmat(p);
		
		
		var g: Graphics = target.g4;
		
		g.begin();
		g.clear(Color.Green);		
		globe.render(g, pvm);
		
		
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
		
		trace("Angles: EyeYaw:" + EyeYaw + " EyePitch " + EyePitch + " EyeRoll " + EyeRoll);
		
		var rollPitchYaw: Matrix4 = Matrix4.rotationY(EyeYaw).multmat(Matrix4.rotationX(EyePitch).multmat(Matrix4.rotationZ(EyeRoll)));
		
		return rollPitchYaw;
	}

	
	override public function render(framebuffer: Framebuffer): Void {
		var now: Float = VrInterface.instance.GetTimeInSeconds();
		var rawDelta: Float = now - prev;
		prev = now;
		
		var clampedPrediction = Math.min(0.1, rawDelta * 2.0);
		var state: SensorState = VrInterface.instance.GetPredictedSensorState(now + clampedPrediction);
	


		
		
		
	
		
		
		var curImage: Image = nextImage();
		var p:Matrix4 = renderIt(curImage, getViewMatrix(state));
		
		
		
		
		redImage.g4.begin();
		redImage.g4.clear(Color.Red);
		
		redImage.g4.end();
		
		
		var parms: TimeWarpParms = new TimeWarpParms();
		
		var leftTimeWarpImage: TimeWarpImage = new TimeWarpImage();
		leftTimeWarpImage.Image = curImage;
		leftTimeWarpImage.Pose = state.Predicted;
		
		var rightTimeWarpImage: TimeWarpImage = new TimeWarpImage();
		rightTimeWarpImage.Image = curImage;
		rightTimeWarpImage.Pose = state.Predicted;
		
		
		parms.LeftImage = leftTimeWarpImage;
		parms.RightImage = rightTimeWarpImage;
		
		// TODO: Port the code over
		leftTimeWarpImage.TexCoordsFromTanAngles = p;
		rightTimeWarpImage.TexCoordsFromTanAngles = p;		

		VrInterface.instance.WarpSwap(parms);
	}
	
	private var left = false;
	private var right = false;
	private var lastleft = false;
	private var lastright = false;
	private var down_ = false;
	private var button = true;
	private var current: BigBlock;
	private var next: BigBlock;
	private var xcount: Int = 0;
	
	private var mousedowncount: Int = 0;
	private var fingerdown: Bool = false;
	private var fingerposx: Int = 0;
	private var fingerposy: Int = 0;
	private var fingerstartx: Int = 0;
	private var fingerstarty: Int = 0;
	private var blocksize: Int = 16;
	private var lastclicktime: Float = 0;
	
	override public function update(): Void {		
		lastleft = left;
		lastright = right;

		//
		
		++mousedowncount;
		if (mousedowncount == 0) mousedowncount = 100;
		
	//
		if (fingerdown) {
			var leftright = false;
			if (fingerposx - fingerstartx > 15 || fingerposx - fingerstartx < -15) leftright = true;
			while (fingerposx - fingerstartx > blocksize) {
				fingerstartx += blocksize;
				current.right();
				leftright = true;
			}
			while (fingerposx - fingerstartx < -blocksize) {
				fingerstartx -= blocksize;
				current.left();
				leftright = true;
			}
			if (leftright) {
				fingerstarty = fingerposy;
			}
			else {
				while (fingerposy - fingerstarty > blocksize) {
					fingerstarty += blocksize;
					current.down();
				}
			}
		}
		else {
			if (mousedowncount < 10) {
				var currenttime = Scheduler.time();
				if (currenttime > lastclicktime + 0.6) {
					current.rotate();
					mousedowncount = 100;
					lastclicktime = currenttime;
				}
			}
		}
		
		++count;
		++xcount;
		if (right && !lastright) {
			current.right();
			xcount = 0;
		}
		if (left && !lastleft) {
			current.left();
			xcount = 0;
		}
		if (xcount % 4 == 0) {
			if (right && lastright) current.right();
			else if (left && lastleft) current.left();
		}
		if (button) {
			current.rotate();
			button = false;
		}
		if (down_) down();
		else if (count % 60 == 0) down();		
	}
	
	override public function buttonDown(button: Button): Void {
		switch (button) {
		case Button.LEFT:
			left = true;
		case Button.RIGHT:
			right = true;
		case Button.DOWN:
			down_ = true;
		case Button.BUTTON_1, Button.BUTTON_2:
			this.button = true;
		default:
		}
	}
	
	override public function buttonUp(button: Button): Void {
		switch (button) {
		case Button.LEFT:
			left = false;
		case Button.RIGHT:
			right = false;
		case Button.DOWN:
			down_ = false;
		case Button.BUTTON_1, Button.BUTTON_2:
			this.button = false;
		default:
		}
	}
	
	override public function mouseDown(x: Int, y: Int): Void {
		super.mouseDown(x, y);
		mousedowncount = 0;
		fingerstartx = painterTransformMouseX(x, y);
		fingerstarty = painterTransformMouseY(x, y);
		fingerposx = fingerstartx;
		fingerposy = fingerstarty;
		fingerdown = true;
	}
	
	override public function mouseUp(x: Int, y: Int): Void {
		super.mouseUp(x, y);
		fingerdown = false;
	}
	
	override public function mouseMove(x: Int, y: Int): Void {
		super.mouseMove(x, y);
		fingerposx = painterTransformMouseX(x, y);
		fingerposy = painterTransformMouseY(x, y);
	}
	
	private function createRandomBlock(): BigBlock {
		switch (Random.getUpTo(6)) {
		case 0: return new IBlock();
		case 1: return new LBlock();
		case 2: return new JBlock();
		case 3: return new TBlock();
		case 4: return new ZBlock();
		case 5: return new SBlock();
		case 6: return new OBlock();
		}
		return null;
	}
	
	private function down(): Void {
		if (!current.down()) {
			down_ = false;
			try {
				for (i in 0...4) {
					var block = current.getBlock(i);
					GameBlock.blocked[block.getX()][block.getY()] = block;
				}
				current = next;
				next = createRandomBlock();
				check();
				current.hop();
			}
			catch (e: Exception) {
				Configuration.setScreen(new GameOver());
				return;
			}
		}
	}
	
	private function lineBlocked(y: Int): Bool {
		return GameBlock.blocked[1][y] != null && GameBlock.blocked[2][y] != null && GameBlock.blocked[3][y] != null && GameBlock.blocked[4][y] != null && GameBlock.blocked[5][y] != null &&
			GameBlock.blocked[6][y] != null && GameBlock.blocked[7][y] != null && GameBlock.blocked[8][y] != null && GameBlock.blocked[9][y] != null && GameBlock.blocked[10][y] != null ;
	}
	
	private function check(): Void {
		var lineDeleted = false;
		for (i in 0...4) {
			var y: Int = 1;
			while (y < GameBlock.ysize) {
				if (lineBlocked(y)) {
					lineDeleted = true;
					for (x in 1...GameBlock.xsize - 1) {
						GameBlock.blocked[x][y] = null;
					}
					y += 1;
					while (y < GameBlock.ysize) {
						for (x in 1...GameBlock.xsize - 1) if (GameBlock.blocked[x][y] != null) {
							GameBlock.blocked[x][y].down();
							GameBlock.blocked[x][y - 1] = GameBlock.blocked[x][y];
							GameBlock.blocked[x][y] = null;
						}
						++y;
					}
				}
				++y;
			}
		}
		if (lineDeleted) lineSound.play();
		else klackSound.play();
	}
}
