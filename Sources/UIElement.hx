package;

import kha.graphics4.*;
import kha.Image;
import kha.math.Matrix4;
import kha.math.Quaternion;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;

import kha.Loader;

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
	
	
	public var Texture: Image;
	
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
		
		trace("EyeYaw: " + EyeYaw + " EyePitch: " + EyePitch);
		
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
	
	public function startAnimating() {
		startTime = Sys.time();
		moveDuration = 2;
		moveDistance = 4;
	}
	
	// The update function should update the model matrix
	public function update() {
		var time: Float = Sys.time();
		var t: Float = time - startTime;
		t = t % moveDuration;
		
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
	
	
	public function new() 
	{
		super();
	}
	
}