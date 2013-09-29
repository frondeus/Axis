package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Bonus extends Entity
{
	public function new(x:Int, y:Int)
	{
		super(x,y);

		image = new Image("gfx/entities/bonus.png");
		graphic = image;
		centerOrigin();
		setHitbox(32,32);

		type = "bonus";
	}
	private var image:Image;
}