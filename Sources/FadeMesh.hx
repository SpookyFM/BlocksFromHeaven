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

import MeshBase;

/**
 * ...
 * @author Florian Mehm
 */
class FadeMesh extends FullScreenQuad
{

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
	
	
	override function buildGeometry() 
	{
		super.buildGeometry();
		
		
		program = new Program();
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("fade.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("fade.frag")));
		program.link(structure);
	}
	
	public function new()
	{
		super();
		
		
		
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