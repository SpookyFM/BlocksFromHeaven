package;
import kha.graphics4.*;
import kha.Image;
import kha.math.Matrix4;
import kha.Loader;

/**
 * ...
 * @author Florian Mehm
 */
class GazeCursor extends FullScreenQuad
{
	public var activeImage: Image;
	
	public var inactiveImage: Image;
	
	public var cutoffImage: Image;
	
	
	// Between 0 and 1, chooses which part of the active image is visible
	public var active: Float;
	
	// How deep into the screen is the cursor?
	public var depth: Float;
	
	public var scale: Float;
	
	override function buildGeometry() 
	{
		super.buildGeometry();
		
		
		program = new Program();
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("cutoff.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("cutoff.frag")));
		program.link(structure);
	}
	
	public function render(g4: Graphics, p: Matrix4) {
		g4.setCullMode(CullMode.None);
		
		g4.setBlendingMode(BlendingOperation.SourceAlpha, BlendingOperation.InverseSourceAlpha);
		
		
		g4.setProgram(program);
		g4.setIndexBuffer(ib);
		g4.setVertexBuffer(vb);
		
		var projectionMatrix: ConstantLocation = program.getConstantLocation("projectionMatrix");
		
		var m: Matrix4 = Matrix4.translation(0, 0, -depth);
		m = Matrix4.scale(scale, -scale, scale).multmat(m);
		m = m.multmat(p);
		g4.setMatrix(projectionMatrix, m);
		
		
		var texActive: TextureUnit = program.getTextureUnit("texActive");
		var texInactive: TextureUnit = program.getTextureUnit("texInactive");
		var texCutoff: TextureUnit = program.getTextureUnit("texCutoff");
		
		var cutoff: ConstantLocation = program.getConstantLocation("cutoff");
		
		g4.setTextureParameters(texCutoff, TextureAddressing.Clamp, TextureAddressing.Clamp, TextureFilter.PointFilter, TextureFilter.PointFilter, MipMapFilter.NoMipFilter);
		
		
		g4.setTexture(texActive, activeImage);
		g4.setTexture(texInactive, inactiveImage);
		g4.setTexture(texCutoff, cutoffImage);
		g4.setFloat(cutoff, active);	
		
		
		
		
		g4.drawIndexedVertices();
	}

	public function new() 
	{
		super();
		
		active = 0.25;
		
	}
	
}
