package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Coin extends Entity
{
	public function new(x:Int, y:Int, _value:Int)
	{
		super(x,y);

		image = new Image("gfx/entities/coin.png");
		graphic = image;
		value = _value;
		centerOrigin();
		setHitbox(32,32);

		type = "coin";
	}

	public var value:Int;
	private var image:Image;
}