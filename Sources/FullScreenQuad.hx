package;

import haxe.ds.Vector;
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
class FullScreenQuad extends MeshBase
{

	public function new() 
	{
		super();
		
		
		
	}
	
	override function buildGeometry() 
	{
		super.buildGeometry();
		
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
	}
	
	
	
}