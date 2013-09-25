package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import entities.Player;

class Usable extends Entity
{
	public function new(x:Int, y:Int)
	{
		super(x,y);
		type = "usable";
		links =  new Array<Usable>();
	}
	public function use(player:Player, func:String = "default")
	{
		
	}
	public var dist:Float;
	public var links:Array<Usable>;
}