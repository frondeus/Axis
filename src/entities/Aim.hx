package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class Aim extends Entity
{
	public function new(x:Int, y:Int, _where:String)
	{
		super(x,y);

		sprite = new Spritemap("gfx/entities/aim.png",64,64);
		sprite.add("idle",[0,1,2,3,2,1],10);
		sprite.play("idle");

		graphic = sprite;
		type = "aim";
		layer = 1;
		setHitbox(64,64);

		where = _where;
	}

	private var sprite:Spritemap;
	public var where:String;
}