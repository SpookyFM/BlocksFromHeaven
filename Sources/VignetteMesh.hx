package;
import haxe.io.Float32Array;
import kha.graphics4.*;
import kha.math.Vector3;
import kha.Loader;

/**
 * For timewarping, we need to render a vignette around the image so that the timewarp algorithm doesn't pull the border color inside.
 * @author Florian Mehm
 */
class VignetteMesh extends MeshBase
{
	
	public var vignetteSize: Float;
	
	
	override function buildStructure() 
	{
		structure = new VertexStructure();
		structure.add("Position", VertexData.Float3 );
		
		program = new Program();
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("vignette.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("vignette.frag")));
		program.link(structure);
	}
	
	private function setTriangle(a: Array<Int>, i: Int, index1: Int, index2: Int, index3: Int) {
		a[i * 3 +0] = index1;
		a[i * 3 +1] = index2;
		a[i * 3 +2] = index3;
	}
	
	private function setVert(a: Float32Array, i: Int, x: Float, y: Float) {
		a[i * 3 +0] = x;
		a[i * 3 +1] = y;
		a[i * 3 +2] = 0;
	}
	
	override function buildGeometry() 
	{
		super.buildGeometry();
		
		// We use 12 verts: L/R are quads that cover the whole height, the top and bottom quads are in between
		
		vertexCount = 12;
		// Go from left to right
		vb = new VertexBuffer(vertexCount, structure, Usage.StaticUsage);
		var verts: Float32Array = vb.lock();
		setVert(verts, 0, -1.01, 1.01);
		setVert(verts, 1, -1.0 + vignetteSize, 1.01);
		setVert(verts, 2, 1.0 - vignetteSize, 1.01);
		setVert(verts, 3, 1.01, 1.01);
		
		setVert(verts, 4, -1.0 + vignetteSize, 1.0 - vignetteSize);
		setVert(verts, 5, 1.0 - vignetteSize, 1.0 - vignetteSize);
		
		setVert(verts, 6, -1.0 + vignetteSize, -1.0 + vignetteSize);
		setVert(verts, 7, 1.0 - vignetteSize, -1.0 + vignetteSize);
		
		setVert(verts, 8, -1.01, -1.01);
		setVert(verts, 9, -1.0 + vignetteSize, -1.01);
		setVert(verts, 10, 1.0 - vignetteSize, -1.01);
		setVert(verts, 11, 1.01, -1.01);
		
		vb.unlock();
		
		
		// two triangles for each side of the texture (4) * three verts: 24 indices
		ib = new IndexBuffer(24, Usage.StaticUsage);
		var indices: Array<Int> = ib.lock();
		
		// Left side
		setTriangle(indices, 0, 0, 1, 8);
		setTriangle(indices, 1, 1, 9, 8);
		// Top side
		setTriangle(indices, 2, 1, 2, 4);
		setTriangle(indices, 3, 2, 5, 4);
		// Right side
		setTriangle(indices, 4, 2, 3, 10);
		setTriangle(indices, 5, 3, 11, 10);
		// Bottom side
		setTriangle(indices, 6, 6, 7, 9);
		setTriangle(indices, 7, 7, 11, 9);
		
		
		ib.unlock(); 
	}
	
	
	public function render(g4: Graphics) {
		g4.setCullMode(CullMode.None);
		
		
		g4.setProgram(program);
		g4.setIndexBuffer(ib);
		g4.setVertexBuffer(vb);
		
		
		g4.drawIndexedVertices();
	}
	

	public function new(size: Float) 
	{
		vignetteSize = size;
		super();
		
	}
	
}