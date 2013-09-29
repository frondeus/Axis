package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Emitter;

import com.haxepunk.graphics.Graphiclist;

class Trap extends Entity
{
	public function new(x:Int, y:Int, angle:Float)
	{
		super(x,y);
		
		sprite = new Spritemap("gfx/entities/traps.png",32,32);
		sprite.add("idle",[1]);
		sprite.add("hide",[1,0],2);
		sprite.play("idle");

		emitter = new Emitter("gfx/particles.png",8, 8);
		emitter.relative = false;
		emitter.newType("white", [1]);
		emitter.setMotion("white",0.0,100.0,0.8,360.0);
		emitter.setAlpha("white",1.0,0.0);
		emitter.setGravity("white",10.0);
		
		sprite.angle = 360 - angle;
		setHitbox(32,32);
		
		graphic = new Graphiclist([sprite,emitter]);
		type = "solid";

	}

	public function hide()
	{
		sprite.callbackFunc = isHidden;
		sprite.play("hide");
	}

	private function isHidden()
	{
		collidable = false;
		HXP.scene.remove(this);
	}

	public override function update()
	{
		if(collide("player",x,y-32)!= null ||
			collide("player",x,y+32)!= null ||
			collide("player",x-32,y)!= null ||
			collide("player",x+32,y)!= null) 
		{
			emitter.emit("white",x,y);
			hide();
		}
	}
	private var sprite:Spritemap;
	private var emitter:Emitter;
}