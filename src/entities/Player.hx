package entities;

import entities.Body;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Touch;
import com.haxepunk.graphics.Text;
import com.haxepunk.Sfx;
import entities.Usable;

class Player extends Body
{
	public function new(x:Int, y:Int)
	{
		super(x, y);

		sprite = new Spritemap("gfx/entities/player.png", 16, 16);
		sprite.add("idle", [0]);
		sprite.add("walk", [1,2,3,2], 12);
		sprite.play("idle");
		sprite.scale = 2.0;
		

		moveImage = new Image("gfx/ui/move.png");
		moveImage.relative = false;
		moveImage.scrollX = moveImage.scrollY = 0.0;
		moveImage.visible = false;
		moveImage.layer = -10;

		Input.define("left", [Key.LEFT, Key.A]);
		Input.define("right", [Key.RIGHT, Key.D]);
		Input.define("jump", [Key.UP,Key.W]);

		setHitbox(32+4,32,8);
		type = "player";
	
		useDelay = 0.0;

		graphic = new Graphiclist([sprite,emitter,moveImage]);
		maxJumps = 2;
		jumpTime = 0.0;

		slowmot = 1.0;

		movePoint = new flash.geom.Point(0,0);

		emitter.newType("coins", [1]);
		emitter.setMotion("coins",0.0,100.0,0.8,360.0);
		emitter.setAlpha("coins",1.0,0.0);
		emitter.setGravity("coins",10.0);

		scoreSound = new Sfx("sfx/coin.wav");
		jumpSound = new Sfx("sfx/jump.wav");
		deathSound = new Sfx("sfx/death.wav");
		levelSound = new Sfx("sfx/level.wav");

		deaths = 0;
		lastTime = time = 0.0;
	}


	private function handleInput()
	{
		acc.x = acc.y = 0.0;
		inputJump = inputLeft = inputRight = false;

#if (android || ios)
		if(Input.multiTouchSupported)
		{
			moveImage.visible = false;
			if(Input.touches.exists(0))
			{
				var t = Input.touches.get(0);
				var e:Usable = cast collide("usable",t.sceneX,t.sceneY);
				if((e != null) && (Math.abs(x - t.sceneX) < e.dist))
				{
					useDelay += HXP.elapsed;

					if(useDelay >= 1.0)
					{
						e.use(this);
						useDelay = 0.0;
					}
				}
				else
				{
					useDelay = 0.0;
					if(t.pressed)
					{
						trace("MOVE");
						movePoint.x = t.x;
						movePoint.y = t.y;
					}
					trace("Move: " + (movePoint.x - t.x));
					inputLeft = ((movePoint.x - t.x) > 32);
					inputRight = ((movePoint.x - t.x) < -32);
					moveImage.visible = true;
					moveImage.x = movePoint.x-16;
					moveImage.y = movePoint.y-16;
				}
			}
			else useDelay = 0.0;
			if(Input.touches.exists(1)) inputJump = true;
		}
		else 
#end
		if(Input.mouseDown)
		{
			var e:Usable = cast collide("usable",HXP.scene.mouseX,HXP.scene.mouseY);
			if((e != null) && (Math.abs(x - HXP.scene.mouseX) < e.dist))
			{
				useDelay += HXP.elapsed;
				if(useDelay >= 1.0)
				{
					e.use(this);
					useDelay = 0.0;
				}
			}
			else
			{
				useDelay = 0.0;
				inputLeft =	(HXP.scene.mouseX < x);
				inputRight = (HXP.scene.mouseX > x);
			}
		}
		

		inputLeft = inputLeft || Input.check("left");
		inputRight = inputRight || Input.check("right");
		inputJump = inputJump || Input.check("jump");

		

		HXP.rate += (slowmot - HXP.rate) * 0.15;
		if(HXP.rate < 0.1) HXP.rate = 0.0;

		if(inputLeft)	acc.x = -1;	
		if(inputRight)	acc.x = 1;	
		
		
		if(onGround) jumps = 0;
		if(onWall) jumps = 0;
		
		if(!inputJump)	jumpTime = 0.0;


		if(jumps >= 0 && jumps < maxJumps && inputJump && jumpTime == 0.0)
		{
			jumps += 1;
			jumpTime += HXP.elapsed;
			jumpSound.play();
			if(jumps >= 2) for(i in 1 ... 5) emitter.emit("coins",x,y);


		}
		if(jumpTime > 0 && jumpTime <= 0.2 && inputJump)
		{
			var spY = 150 * HXP.elapsed;

			if(onWall && !onGround) 
			{
				vel.x -= hitDir.x * 200.0 * HXP.elapsed;
				for(i in 1 ... 4) emitter.emit("coins",x,y);
			}
			
			vel.y -= spY;	
			jumpTime += HXP.elapsed;
		}
			
	}

	public function start()
	{
		x = spawn.x;
		y = spawn.y;

		acc.x = vel.x = 0.0;
		acc.y = vel.y = 0.0;


		HXP.camera.x = x - HXP.screen.width / 2;
		HXP.camera.y = y - HXP.screen.width / 2;
		alive = true;

		score = lastScore;
		time = lastTime;
	}

	private function setAnim()
	{
		if(vel.x == 0.0)
			sprite.play("idle");
		else
		{
			sprite.play("walk");
			if(vel.x < 0.0)
				sprite.flipped  = true;
			else if(vel.x > 0.0) 
			sprite.flipped = false;
		}

	}

	private function setCamera()
	{
		var hX = HXP.screen.width / 2;
		var hY = HXP.screen.height / 2;

		var aX = x - hX + (acc.x * hX * 0.5);
		var aY = y - hY + (acc.y * hY * 0.5) - (hY * 0.75);

		var speed = 0.8;
		if(acc.x != 0.0) speed= 4.0;

		HXP.camera.x += ( aX - HXP.camera.x) * HXP.elapsed * 0.8;
		HXP.camera.y += ( aY - HXP.camera.y) * HXP.elapsed *  Math.max(0.8,Math.abs(vel.y));///* HXP.elapsed * 0.001  * Math.abs(aY - HXP.camera.y);
	}

	public override function update()
	{	
		if(alive) handleInput();
		if(alive) move();
		if(y > region.bBottom)
			alive = false;


		if(alive == false || collide("kill",x,y) != null)
		{
			deaths++;
			deathSound.play();
			for(i in 1...10)	emitter.emit("blood",x,y);
			region.reload(this);
			start();
		}
		else time += HXP.elapsed;
		

		var coin:entities.Coin = cast collide("coin",x,y);
		if(coin != null)
		{
			score += coin.value;
			HXP.scene.remove(coin);
			for(i in 1 ... Std.int(coin.value * 0.5)) emitter.emit("coins",coin.x,coin.y);
			scoreSound.play();
		}

		var aim:entities.Aim = cast collide("aim",x,y);
		if(aim != null)
		{
			Main.gameplay.lvl = aim.where;
			Main.score.set(score,time - lastTime,time,deaths);
			lastTime = time;
			lastScore = score;
			deaths = 0;
			levelSound.play();
			HXP.scene = Main.score;
		}
		setAnim();
		setCamera();

		super.update();
	}
	
	private var sprite:Spritemap;

	private var movePoint:flash.geom.Point;
	private var moveImage:Image;


	private var useDelay:Float;

	private var jumps:Int;
	private var maxJumps:Int;
	private var jumpTime:Float;

	private var inputJump:Bool;
	private var inputLeft:Bool;
	private var inputRight:Bool;
	private var slowmot:Float;


	public var spawn:flash.geom.Point;
	public var region:entities.Region;

	public var score:Int;
	public var lastScore:Int;

	public var time:Float;
	public var lastTime:Float;

	public var deaths:Int;

	private var jumpSound:Sfx;
	private var deathSound:Sfx;
	private var scoreSound:Sfx;
	private var levelSound:Sfx;


}