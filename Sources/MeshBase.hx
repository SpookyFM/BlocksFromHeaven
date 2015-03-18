package;

import kha.Color;
import kha.graphics4.*;
import kha.Image;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.math.Matrix4;

/**
 * ...
 * @author Florian Mehm
 */
class MeshBase
{

	private var structure: VertexStructure;
	
	private var vertexCount: Int;
	private var vb: VertexBuffer;
	private var ib: IndexBuffer;
	
	private var program: Program;
	private var fs: FragmentShader;
	private var vs: VertexShader;
	
	
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
	
	
	
	private function buildGeometry() {
		
	}
	
	public function new() 
	{
		structure = new VertexStructure();
		structure.add("Position", VertexData.Float3);
		structure.add("TexCoord", VertexData.Float2);
		structure.add("VertexColor", VertexData.Float4);
		
		buildGeometry();
	}
	
	
	
}