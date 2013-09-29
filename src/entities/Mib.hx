package entities;

import com.haxepunk.HXP;
import com.haxepunk.graphics.Spritemap;

class Mib extends Body
{
	public function new(x:Int, y:Int,player:entities.Player)
	{
		super(x,y);

		sprite = new Spritemap("gfx/entities/mib.png",32,32);
		sprite.add("idle", [0]);
		sprite.add("walk", [1,2,3,2],12);
		sprite.play("idle");

		setHitbox(32,32);
		type = "kill";

		graphic = sprite;
		_player = player;
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
		vel.x = (_player.x - x) * 0.05;
		vel.y = (_player.y - y) * 0.05;
		move();
		setAnim();



		super.update();
	}

	private var sprite:Spritemap;
	private var _player:entities.Player;
}