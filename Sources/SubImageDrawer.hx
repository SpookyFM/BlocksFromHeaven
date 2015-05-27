package;

import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.Image;
import kha.math.Vector2;
import kha.math.Vector4;
import kha.math.Vector3;
import kha.graphics4.Usage;
import kha.graphics4.Graphics;
import kha.graphics4.Program; 
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.graphics4.TextureUnit;
import kha.graphics4.CullMode;
import kha.math.Matrix4;
import kha.graphics4.ConstantLocation;
import kha.Loader;
import kha.Rectangle;

/**
 * ...
 * @author Florian Mehm
 */
class SubImageDrawer extends MeshBase
{
	private var sourceRect: Rectangle;
	private var targetRect: Rectangle;
	
	private var x: Float;
	private var y: Float;
	private var w: Float;
	private var h: Float;
	
	public var imageToDraw: Image;
	
	override function buildGeometry() 
	{
		super.buildGeometry();
		
		vertexCount = 4;
		
		var imageW: Float = 4096;
		var imageH: Float = 2048;
		
		
		vb = new VertexBuffer(vertexCount, structure, Usage.StaticUsage);
		var verts: Array<Float> = vb.lock();
		
		
		
		var viewport: Rectangle = new Rectangle(0, 0, 0, 0);
		viewport.x = (targetRect.x / imageW) * 2 - 1;
		viewport.y = (targetRect.y / imageH) * 2 - 1;
		viewport.width = (targetRect.width / imageW) * 2;
		viewport.height = (targetRect.height / imageH) * 2;
		
		var uv: Rectangle = new Rectangle(0, 0, 0, 0);
		uv.x = sourceRect.x / imageW;
		uv.y = sourceRect.y / imageH;
		uv.width = sourceRect.width / imageW;
		uv.height = sourceRect.height / imageH;
		
		
		
		/*var uvX: Float = x / imageW;
		var uvY: Float = y / imageH;
		var uvW: Float = w / imageW;
		var uvH: Float = h / imageH;
		var viewportX: Float =  uvX * 2 - 1;
		var viewportY: Float = uvY * 2 - 1;
		var viewportW: Float = uvW * 2;
		var viewportH: Float = uvH * 2; */
		
		

		/* setVertex(verts, 0, new Vector3(viewportX, viewportY, 0), new Vector2(uvX, uvY), new Vector4(1, 1, 1, 1));
		setVertex(verts, 1, new Vector3(viewportX, viewportY + viewportH, 0), new Vector2(uvX, uvY + uvH), new Vector4(1, 1, 1, 1));
		setVertex(verts, 2, new Vector3(viewportX + viewportW, viewportY, 0), new Vector2(uvX + uvW, uvY), new Vector4(1, 1, 1, 1));
		setVertex(verts, 3, new Vector3(viewportX + viewportW, viewportY + viewportH, 0), new Vector2(uvX + uvW, uvY + uvH), new Vector4(1, 1, 1, 1)); */
		
		setVertex(verts, 0, new Vector3(viewport.x, viewport.y, 0), new Vector2(uv.x, uv.y), new Vector4(1, 1, 1, 1));
		setVertex(verts, 1, new Vector3(viewport.x, viewport.y + viewport.height, 0), new Vector2(uv.x, uv.y + uv.height), new Vector4(1, 1, 1, 1));
		setVertex(verts, 2, new Vector3(viewport.x + viewport.width, viewport.y, 0), new Vector2(uv.x + uv.width, uv.y), new Vector4(1, 1, 1, 1));
		setVertex(verts, 3, new Vector3(viewport.x + viewport.width, viewport.y + viewport.height, 0), new Vector2(uv.x + uv.width, uv.y + uv.height), new Vector4(1, 1, 1, 1));
		
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
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("painter-image.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("painter-image.frag")));
		program.link(structure);
	}
	
	
	public function render(g: Graphics) {
		g.setCullMode(CullMode.None);
		
		
		
		
		g.setProgram(program);
		var pm: ConstantLocation = program.getConstantLocation("projectionMatrix");
		g.setMatrix(pm, Matrix4.identity());
		g.setIndexBuffer(ib);
		g.setVertexBuffer(vb);
		
		var textureUnit: TextureUnit = program.getTextureUnit("tex");
		g.setTexture(textureUnit, imageToDraw);
		
		g.drawIndexedVertices();
	}
	
	
	public function new(source: Rectangle, target: Rectangle ) 
	{
		this.sourceRect = source;
		this.targetRect = target;
		super();
		
	}
	
}