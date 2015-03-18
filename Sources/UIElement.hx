package;

import kha.graphics4.*;
import kha.Image;
import kha.math.Matrix4;
import kha.math.Quaternion;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;

import kha.Loader;

import Quad;

/**
 * ...
 * @author Florian Mehm
 */
class UIElement extends MeshBase
{
	// The element is positioned over a location in the background image, specified as latitude/longitude
	public var Position: Vector2;
	public var Rotation: Quaternion;
	public var Distance: Float;
	
	public var Offset: Vector2;
	
	
	public var Texture: Image;
	
	public var quad: Quad;
	
	// Set the position of the Mesh to be infront of the specified location in the background image
	// viewPosition is the position in the image
	public function SetPosition(pos: Vector2, distance: Float) {
		Position = pos;
		Distance = distance;
	}
	
	public function getViewMatrix(): Matrix4 {
		// TODO: Why does this one work?
		var EyeYaw: Float = Math.PI * 2 - Position.x + Math.PI;
		var EyePitch: Float = Position.y;
		var EyeRoll: Float = 0;
		
		// trace("EyeYaw: " + EyeYaw + " EyePitch: " + EyePitch);
		
		var rollPitchYaw: Matrix4 = Matrix4.rotationY(EyeYaw).multmat(Matrix4.rotationX(EyePitch).multmat(Matrix4.rotationZ(EyeRoll)));
		
		return rollPitchYaw;
	}
	
	override function buildGeometry() 
	{
		super.buildGeometry();
		
		vertexCount = 4;
		
		
		vb = new VertexBuffer(vertexCount, structure, Usage.StaticUsage);
		var verts: Array<Float> = vb.lock();

		setVertex(verts, 0, new Vector3(1, 1, 0), new Vector2(0, 0), new Vector4(1, 1, 1, 1));
		setVertex(verts, 1, new Vector3(1, -1, 0), new Vector2(0, 1), new Vector4(1, 1, 1, 1));
		setVertex(verts, 2, new Vector3(-1, 1, 0), new Vector2(1, 0), new Vector4(1, 1, 1, 1));
		setVertex(verts, 3, new Vector3(-1, -1, 0), new Vector2(1, 1), new Vector4(1, 1, 1, 1));
		
		vb.unlock();
		
		ib = new IndexBuffer(6, Usage.StaticUsage);
		var indices: Array<Int> = ib.lock();
		
		indices[0] = 0;
		indices[1] = 1; 
		indices[2] = 2;
		indices[3] = 1;
		indices[4] = 3;
		indices[5] = 2;
		
		
		ib.unlock(); 
		
		program = new Program();
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("vertexShader.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("fragmentShader.frag")));
		program.link(structure);
	}
	
	var m: Matrix4;
	public function render(g: Graphics, vp: Matrix4) {
		// Build a model matrix that translates this object to the right spot.
		// For now, just translate it back to see if everything works. 

		
		var v: Matrix4 = getViewMatrix();
		v = v.transpose();
		
		var mvp: Matrix4 = m.multmat(v.multmat(vp));
		
		// Update the quad
		var worldMatrix: Matrix4 = m.multmat(v);
		quad.worldMatrix = worldMatrix;

		
		for (i in 0...4) {
			// trace("Matrix: " + worldMatrix.get(0, i) + " " + worldMatrix.get(1, i) + " " + worldMatrix.get(2, i) + " " + worldMatrix.get(3, i));
		}
		
		quad.center = quad.worldMatrix.transpose().multvec(new Vector4(0, 0, 0, 1));
		// TODO: Handle it correctly!
		quad.normal = quad.worldMatrix.transpose().multvec(new Vector4(0, 0, 1, 0));
		quad.extents = new Vector4(1, 1, 0, 0);
		
		//trace("Center: " + quad.center.x + " " + quad.center.y + " " + quad.center.z + " " + quad.center.w);
		
		g.setCullMode(CullMode.None);
		
		
		var mvpLoc: ConstantLocation = program.getConstantLocation("Mvpm");
		g.setProgram(program);
		g.setIndexBuffer(ib);
		g.setVertexBuffer(vb);
		g.setMatrix(mvpLoc, mvp);
		
		var textureUnit: TextureUnit = program.getTextureUnit("tex");
		g.setTexture(textureUnit, Texture);
		
		g.drawIndexedVertices();
	}
	
	
	private var startTime: Float;
	private var moveDuration: Float;
	private var moveDistance: Float;
	
	private var frequency: Float;
	private var rotationDuration: Float;
	
	private var animationDone: Bool = false;
	
	public function startAnimating() {
		startTime = Sys.time();
		moveDuration = 2;
		moveDistance = 4;
		frequency = 2;
		rotationDuration = 6;
	}
	
	// The update function should update the model matrix
	public function update() {
		//updateRotation();
		//return;
		
		var time: Float = Sys.time();
		var t: Float = time - startTime;
		t = (t % moveDuration) / moveDuration;
		
		// Turn the arrow around so it points into the screen somewhat
		var rotAmount: Float = -70 * Math.PI / 180.0;
		var rot: Matrix4 = Matrix4.rotationX(-rotAmount);
		var rotT: Matrix4 = rot.transpose();
		
		// Move it forward the right amount
		var transAmount: Float = moveDistance * t;
		var trans: Matrix4 = Matrix4.translation(0, t, 0);
		
		// Now move it into the screen the specified distance
		var matT: Matrix4 = Matrix4.translation(0, 0, -Distance);
		
		
		
		m = trans.multmat(rot.multmat(matT));
	}
	
	
	public function updateRotation() {
		// Move the control on a plane, around the center with the length of offset
		
		var time: Float = Sys.time();
		
		if (time > startTime + rotationDuration) animationDone = true;
		
		var t: Float = time - startTime;
		
		var rotAmount: Float = (t / frequency) * 2 * Math.PI;
		
		var offset3: Vector3 = new Vector3(Offset.x, Offset.y, 0);
		
		// Scale offset so that it looks like the individual items come out of the image
		var scale: Float = (t % rotationDuration) / rotationDuration;
		offset3 = offset3.mult(scale);
	
		
		var mOffset: Matrix4 = Matrix4.translation(offset3.x, offset3.y, 0);
		
		
	
		
		
		var mRot: Matrix4 = Matrix4.rotationZ(rotAmount);
		var mRotT: Matrix4 = mRot.transpose();
		
		var mScale: Matrix4 = Matrix4.scale(scale, scale, scale);
		
		m = mScale.multmat(mRotT.multmat(mOffset.multmat(mRot)).multmat(Matrix4.translation(0, 0, -Distance)));
	}
	
	
	public function new() 
	{
		super();
		quad = new Quad();
	}
	
}