package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;

class Exit extends Entity
{
	public function new(x:Int, y:Int, _where:String)
	{
		super(x,y);

		sprite = new Spritemap("gfx/entities/exit.png",64,64);
		sprite.add("idle",[0,]);
		sprite.play("idle");

		graphic = sprite;
		type = "exit";
		layer = 1;
		centerOrigin();
		setHitbox(64,64);

		where = _where;
	}

	private var sprite:Spritemap;
	public var where:String;
}