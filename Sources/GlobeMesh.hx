package;


import haxe.ds.Vector;
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
class GlobeMesh
{
	
	private var structure: VertexStructure;
	
	private var vertexCount: Int;
	private var vb: VertexBuffer;
	private var ib: IndexBuffer;
	
	private var program: Program;
	private var fs: FragmentShader;
	private var vs: VertexShader;
	
	
	// TODO: Function is only translated from OVR source code
	public function new(uScale: Float, vScale: Float)
	{
		structure = new VertexStructure();
		structure.add("Position", VertexData.Float3);
		structure.add("TexCoord", VertexData.Float2);
		structure.add("VertexColor", VertexData.Float4);
		
		// Make four rows at the polar caps in the place of one
		// to diminish the degenerate triangle issue.
		var poleVertical: Int = 3;
		var uniformVertical: Int = 64;
		var horizontal: Int = 128;
		var vertical: Int = uniformVertical + poleVertical*2;
		var radius: Float = 100.0;
		
		vertexCount = ( horizontal + 1 ) * ( vertical + 1 );
		
		
		
		
		
		var position: Vector<Vector3> = new Vector<Vector3>(vertexCount);
		var uv0: Vector<Vector2> = new Vector<Vector2>(vertexCount);
		var color: Vector<Vector4> = new Vector<Vector4>(vertexCount);
		
		for (i in 0...vertexCount) {
			position[i] = new Vector3();
			uv0[i] = new Vector2();
			color[i] = new Vector4();
		}
		
		
		for (y in 0...vertical + 1) {
			var yf: Float;
			if ( y <= poleVertical) {
				yf = y / (poleVertical + 1) / uniformVertical;
			} else if ( y >= vertical - poleVertical ) {
				yf = (uniformVertical - 1 + ( ( y - (vertical - poleVertical - 1) ) / ( poleVertical+1) ) ) / uniformVertical;
			} else {
				yf = ( y - poleVertical ) / uniformVertical;
			}
			
			
			var lat: Float = (yf - 0.5) * Math.PI;
			var cosLat: Float = Math.cos(lat);
			
			for (x in 0...horizontal + 1) {
				
				var xf: Float = x / horizontal;
				var lon: Float = (0.5 + xf) * Math.PI * 2;
				var index: Int = y * (horizontal + 1) + x;
				
				if ( x == horizontal )
				{
					// Make sure that the wrap seam is EXACTLY the same
					// xyz so there is no chance of pixel cracks.
					position[index] = position[y * ( horizontal + 1 ) + 0];
				} else {
					position[index].x = radius * Math.cos( lon ) * cosLat;
					position[index].z = radius * Math.sin( lon ) * cosLat;
					position[index].y = radius * Math.sin( lat );
				}
				
				// With a normal mapping, half the triangles degenerate at the poles,
				// which causes seams between every triangle.  It is better to make them
				// a fan, and only get one seam.
				if ( y == 0 || y == vertical )
				{
					uv0[index].x = 0.5;
				} else {
					uv0[index].x = xf * uScale;
				}
				uv0[index].y = ( 1.0 - yf ) * vScale;
				/* for (i in 0...4)
				{
					color[index].set(i, 1.0);
				}*/
				color[index].set_x(0.0);
				color[index].set_y(0.0);
				color[index].set_z(1.0);
				color[index].set_w(1.0);
			}
		}
		
		var numIndices:Int= horizontal * vertical * 6;
		var indices: Vector<Int> = new Vector<Int>(numIndices);
		
		var index: Int = 0;

		for (x in 0...horizontal) {
			for (y in 0...vertical) {
				indices[index + 0] = y * (horizontal + 1) + x;
				indices[index + 1] = y * (horizontal + 1) + x + 1;
				indices[index + 2] = (y + 1) * (horizontal + 1) + x;
				indices[index + 3] = (y + 1) * (horizontal + 1) + x;
				indices[index + 4] = y * (horizontal + 1) + x + 1;
				indices[index + 5] = (y + 1) * (horizontal + 1) + x + 1;
				index += 6;
			}
		}
		
		// Create the VBO and IBO
		vb = new VertexBuffer(vertexCount, structure, Usage.StaticUsage);
		var vba: Array<Float> = vb.lock();
		for (i in 0...vertexCount) {
			var current: Int = i * 9;
			// Position
			vba[current + 0] = position[i].x;
			vba[current + 1] = position[i].y;
			vba[current + 2] = position[i].z;
			// UV
			vba[current + 3] = uv0[i].x;
			vba[current + 4] = uv0[i].y;
			// Color
			for (j in 0...4) {
				vba[current + 5 + j] = color[i].get(j);
			}
		}
		vb.unlock();
		
		ib = new IndexBuffer(numIndices, Usage.StaticUsage);
		var iba: Array<Int> = ib.lock();
		for (i in 0...numIndices) {
			iba[i] = indices[i];
		}
		ib.unlock();
		
		
		/*vb = new VertexBuffer(3, structure, Usage.StaticUsage);
		var verts: Array<Float> = vb.lock();
		verts[0] = 0.0;
		verts[1] = 1.0;
		verts[2] = 0.0;
		verts[3] = 0.0;
		verts[4] = 0.0;
		verts[5] = 1.0;
		verts[6] = 0.0;
		verts[7] = 0.0;
		verts[8] = 1.0;
		
		verts[9] = -1.0;
		verts[10] = -1.0;
		verts[11] = 0.0;
		verts[12] = 0.0;
		verts[13] = 0.0;
		verts[14] = 0.0;
		verts[15] = 1.0;
		verts[16] = 0.0;
		verts[17] = 1.0;
		
		verts[18] = 1.0;
		verts[19] = -1.0;
		verts[20] = 0.0;
		verts[21] = 0.0;
		verts[22] = 0.0;
		verts[23] = 0.0;
		verts[24] = 0.0;
		verts[25] = 1.0;
		verts[26] = 1.0;
		
		
		
		vb.unlock();
		
		ib = new IndexBuffer(3, Usage.StaticUsage);
		var indices: Array<Int> = ib.lock();
		
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		
		ib.unlock(); 
		
		*/
		
		
		// Create the program
		program = new Program();
		
		vs = new VertexShader(Loader.the.getShader("vertexShader.vert"));
		fs = new FragmentShader(Loader.the.getShader("fragmentShader.frag"));
		program.setVertexShader(vs);
		program.setFragmentShader(fs);
		program.link(structure);
		
		
	}
	
	public function render(g4: Graphics, mvp: Matrix4) {
		//g4.setDepthMode(false, CompareMode.Always);
		g4.setCullMode(CullMode.None);
		//g4.setBlendingMode(BlendingOperation.SourceAlpha, BlendingOperation.InverseSourceAlpha);
		//g4.setScissor(new kha.Rectangle(0, 0, 1024, 1024));
		g4.setVertexBuffer(vb);
		g4.setIndexBuffer(ib);
		g4.setProgram(program);
		var mvpLoc: ConstantLocation = program.getConstantLocation("Mvpm");
		g4.setMatrix(mvpLoc, mvp);
		g4.drawIndexedVertices();
		
		
		
		
		
		
		
	}
	
	
}