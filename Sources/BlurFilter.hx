package;
import kha.Image;

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
class BlurFilter extends FullScreenQuad
{

	public function new() 
	{
		super();
		
	}
	
	public var texture: Image;
	
	
	override function buildGeometry() 
	{
		super.buildGeometry();
		
		
		program = new Program();
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("blur.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("blur.frag")));
		program.link(structure);
	}
	
	
	public function render(g4: Graphics) {
		g4.setCullMode(CullMode.None);
		
		
		g4.setProgram(program);
		g4.setIndexBuffer(ib);
		g4.setVertexBuffer(vb);
		
		
		
		
		
		var texelWidthOffset: ConstantLocation = program.getConstantLocation("texelWidthOffset");
		
		g4.setFloat(texelWidthOffset, 1.0 / texture.width);
		
		var texelHeightOffset: ConstantLocation = program.getConstantLocation("texelHeightOffset");
		g4.setFloat(texelHeightOffset, 1.0 / texture.height);
		
		var tex: TextureUnit = program.getTextureUnit("tex");
		g4.setTexture(tex, texture);
		
		
		
		
		
		g4.drawIndexedVertices();
	}
	
}
