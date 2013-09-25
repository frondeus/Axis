package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class Obstacle extends Entity
{
	public function new(x:Int, y:Int, angle:Float, _type:String)
	{
		super(x+16,y+16);
		
		sprite = new Spritemap("gfx/entities/obstacles.png",32,32);
		sprite.add("spikes",[0]);
		sprite.play(_type);

		
		sprite.angle = 360 - angle;
		sprite.centerOrigin();
		setHitbox(16,16,8,8);
		
		graphic = sprite;

		type = "kill";

	}

	private var sprite:Spritemap;
}