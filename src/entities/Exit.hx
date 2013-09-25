package entities;

import com.haxepunk.HXP;
import com.haxepunk.Entity;
import entities.Player;

import com.haxepunk.graphics.Spritemap;

class Exit extends entities.Usable
{
	public function new(x:Int, y:Int,_locked:Bool)
	{
		super(x,y);

		sprite = new Spritemap("gfx/entities/door.png",64,64);
		sprite.add("closed",[0]);
		sprite.add("opened",[4]);
		sprite.add("open",[0,1,2,3,4],10);
		sprite.add("close",[4,3,2,1,0],10);
		sprite.play("closed");
		graphic = sprite;

		opened = false;
		locked = _locked;
		setHitbox(64,64);
		layer = 5;
		dist = 64;

		
	}
	private function hasOpened()
	{
		sprite.callbackFunc = null;
		opened = true;
		sprite.play("opened");
	
		if(links.length > 0)
		{
			var dist = links[0];
			dist.use(_player,"teleport");
		}
		use(_player);
	}
	private function hasClosed()
	{
		sprite.callbackFunc = null;
		opened = false;
		sprite.play("closed");
	}
	private function hasTeleported()
	{
		sprite.callbackFunc = null;
		opened = true;
		sprite.play("opened");

		_player.x = x + 16;
		_player.y = y + 16;
		use(_player);
	}
	public override function use(player:Player, func:String="default")
	{
		_player = player;

		if(func == "default")
		{
			if(!opened && !locked)
			{
				sprite.play("open");
				sprite.callbackFunc = hasOpened; 
			}
			if(opened)
			{
				sprite.play("close");
				sprite.callbackFunc = hasClosed;
			}
		}
		else if(func == "teleport")
		{
			if(!opened)
			{
				sprite.play("open");
				sprite.callbackFunc = hasTeleported; 
			}
			else hasTeleported();	
		}
	}
	public override function update()
	{
		super.update();
	}

	private var sprite:Spritemap;
	private var opened:Bool;
	private var locked:Bool;
	private var _player:Player;
}