package entities;

import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;

class Mib extends Body
{
	public function new(x:Int, y:Int)
	{
		super(x,y);

		sprite = new Spritemap("gfx/entities/mib.png",32,32);
		sprite.add("idle", [0]);
		sprite.play("idle");

		setHitbox(32,32);
		type = "kill";

		graphic = sprite;
	}

	private function setAnim()
	{
		if(vel.x == 0.0)
			sprite.play("idle");
		else
		{
			sprite.play("walk");
			if(vel.x < 0.0)
				sprite.flipped = true;
			else if(vel.x > 0.0)
				sprite.flipped = false;
		}
	}

	public override function update()
	{

		move();
		setAnim();

		super.update();
	}

	private var sprite:Spritemap;
}