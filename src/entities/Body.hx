package entities;

import flash.geom.Point;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Emitter;


class Body extends Entity
{
	public function new(x:Int, y:Int)
	{
		super(x,y);
		layer = 0;
		vel = new Point();
		acc = new Point();
		hitDir = new Point();
		gravityScale = 1.0;
		onWall = onGround = false;
		drag = 3;
		maxSpeed = 8;
		alive = true;


		emitter = new Emitter("gfx/particles.png",8, 8);
		emitter.relative = false;
		emitter.newType("blood", [0]);

		emitter.setMotion("blood",0.0,100.0,2.0,360.0);
		emitter.setAlpha("blood",1.0,0.0);
		emitter.setGravity("blood",10.0);

	}	

	// public override function moveCollideX(e:Entity)
	// {
	// 	vel.x = 0.0;
	// 	onWall = true;
	// 	return true;
	// }

	// public override function moveCollideY(e:Entity)
	// {
	// 	vel.y = 0.0;
	// 	onGround = true;
	// 	drag = 0.4;
	// 	return true;
	// }

	private function move()
	{
		acc.y = gravityScale;
		vel.x += acc.x* HXP.elapsed * 64;
		vel.y += acc.y* HXP.elapsed * 64;

		onGround = false;



		if(Math.abs(vel.x) > maxSpeed)
			vel.x = maxSpeed * HXP.sign(vel.x);

		if(vel.x < 0) vel.x = Math.min(vel.x + drag,0);
		else if(vel.x > 0) vel.x = Math.max(vel.x - drag,0);

		var xd:Float = vel.x * HXP.elapsed * 64;
		var yd:Float = vel.y * HXP.elapsed * 64;
		//trace(yd);

		drag = 0.1;
		onGround = false;

		var i:Int = 0;
		if(xd != 0)
		{
			onWall = false;
			do
			{
				if(collide("solid",x+HXP.sign(xd),y) != null)	//sciana
				{
					onWall=true;
					hitDir.x = HXP.sign(xd);
					if(HXP.sign(vel.x) == hitDir.x) 
						vel.x = 0;
					break;
				}
				else x += HXP.sign(xd);

				i+=1;
			} while(i < Math.abs(xd));
		} 

		i = 0;
		if(yd != 0) do
		{
			if(collide("solid",x,y+HXP.sign(yd)) != null)	//pologa
			{
				hitDir.y = HXP.sign(yd);
				if(yd > 0)
					onGround=true;
				vel.y = 0;
				drag = 0.4;
				break;
			}
			else y += HXP.sign(yd);
			i+=1;
		} while(i < Math.abs(yd));
	}
	private var maxSpeed:Float;
	private var vel:Point;
	private var acc:Point;
	private var onGround:Bool;
	private var onWall:Bool;
	private var hitDir:Point;
	private var drag:Float;
	private var gravityScale:Float;

	private var alive:Bool;

	private var emitter:Emitter;

}