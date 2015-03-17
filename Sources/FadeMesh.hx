package;


import haxe.ds.Vector;
import kha.Color;
import kha.graphics4.*;
import kha.Image;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.math.Matrix4;

import kha.Loader;

/**
 * ...
 * @author Florian Mehm
 */
class FadeMesh
{
	
	private var structure: VertexStructure;
	
	private var vertexCount: Int;
	private var vb: VertexBuffer;
	private var ib: IndexBuffer;
	
	private var program: Program;
	private var fs: FragmentShader;
	private var vs: VertexShader;
	
	
	
	public var duration: Float;
	
	public var startTime: Float;
	
	public var startColor: Color;
	
	public var endColor: Color;
	
	public function fade(startColor: Color, endColor: Color, duration: Float) {
		this.startColor = startColor;
		this.endColor = endColor;
		this.duration = duration;
		startTime = Sys.time();
	}
	
	public function isFinished(): Bool {
		return Sys.time() > startTime + duration;
	}
	
	private function setVertex(a: Array<Float>, index: Int, pos: Vector3, uv: Vector2, color: Vector4) {
		var base: Int = index * 9;
		a[base + 0] = pos.x;
		a[base + 1] = pos.y;
		a[base + 2] = pos.z;
		base += 3;
		a[base + 0] = uv.x;
		a[base + 1] = uv.y;
		base += 2;
		for (i in 0...4) {
			a[base + i] = color.get(i);
		}
	}
	
	public function new()
	{
		structure = new VertexStructure();
		structure.add("Position", VertexData.Float3);
		structure.add("TexCoord", VertexData.Float2);
		structure.add("VertexColor", VertexData.Float4);
		
		vertexCount = 4;
		
		
		vb = new VertexBuffer(vertexCount, structure, Usage.StaticUsage);
		var verts: Array<Float> = vb.lock();

		setVertex(verts, 0, new Vector3(-1, -1, 0), new Vector2(0, 0), new Vector4(1, 1, 1, 1));
		setVertex(verts, 1, new Vector3(-1, 1, 0), new Vector2(0, 1), new Vector4(1, 1, 1, 1));
		setVertex(verts, 2, new Vector3(1, -1, 0), new Vector2(1, 0), new Vector4(1, 1, 1, 1));
		setVertex(verts, 3, new Vector3(1, 1, 0), new Vector2(1, 1), new Vector4(1, 1, 1, 1));
		
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
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("fade.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("fade.frag")));
		program.link(structure);
		
	}
	
	public function render(g4: Graphics) {
		g4.setCullMode(CullMode.None);
		
		
		g4.setProgram(program);
		g4.setIndexBuffer(ib);
		g4.setVertexBuffer(vb);
		
		var startColorLoc: ConstantLocation = program.getConstantLocation("uStartColor");
		g4.setFloat4(startColorLoc, startColor.R, startColor.G, startColor.B, startColor.A);
		
		var endColorLoc: ConstantLocation = program.getConstantLocation("uEndColor");
		g4.setFloat4(endColorLoc, endColor.R, endColor.G, endColor.B, endColor.A);
		
		var t: Float = (Sys.time() - startTime) / duration;
		if (t > 1) {
			t = 1;
		}
		if (t < 0) {
			t = 0;
		}
		
		var tLocation: ConstantLocation = program.getConstantLocation("uT");
		g4.setFloat(tLocation, t);
		
		g4.drawIndexedVertices();
	}
	
	
}