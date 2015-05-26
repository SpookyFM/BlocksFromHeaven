package;


import haxe.ds.Vector;
import haxe.io.Float32Array;
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
	
	public var texture: Image;
	
	public var blurredTexture: Image;
	
	private var animationStart: Float;
	
	private var animationDuration: Float;
	
	private var animationDirection: Float;
	
	var t: Float;
	
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
	
	// TODO: Function is only translated from OVR source code
	public function new(uScale: Float, vScale: Float)
	{
		
		// In the beginning, we don't want any blur
		animationDirection = 1;
		animationStart = 0;
		animationDuration = 1;
		
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
				
				color[index].set_x(1.0);
				color[index].set_y(1.0);
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
		var vba: Float32Array = vb.lock();
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
		
		
		
		
		// Create the program
		program = new Program();
		
		vs = new VertexShader(Loader.the.getShader("vertexShader.vert"));
		fs = new FragmentShader(Loader.the.getShader("fragmentShader_blend.frag"));
		program.setVertexShader(vs);
		program.setFragmentShader(fs);
		program.link(structure);
		
		
	}
	
	public function startAnimating(direction: Float, duration: Float) {
		animationStart = Sys.time();
		animationDirection = direction;
		animationDuration = duration;
	}
	
	public function update(): Void {
		var time: Float = Sys.time();
		var delta: Float = time - animationStart;
		
		
		// For the other way, go from 0 to 1
		t = delta / animationDuration;
		
		if (t > 1) t = 1;
		
		if (animationDirection < 0) {
			t = 1 - t;
		}
		
		
	}
	
	public function render(g4: Graphics, mvp: Matrix4) {
		g4.setCullMode(CullMode.None);

		var mvpLoc: ConstantLocation = program.getConstantLocation("Mvpm");
		g4.setProgram(program);
		g4.setIndexBuffer(ib);
		g4.setVertexBuffer(vb);
		g4.setMatrix(mvpLoc, mvp);
		
		var tLoc: ConstantLocation = program.getConstantLocation("t");
		g4.setFloat(tLoc, t);
		
		var textureUnit: TextureUnit = program.getTextureUnit("tex");
		g4.setTexture(textureUnit, texture);
		
		var tex2: TextureUnit = program.getTextureUnit("tex2");
		g4.setTexture(tex2, blurredTexture);
		
		g4.drawIndexedVertices();
	}
	
	

	
}