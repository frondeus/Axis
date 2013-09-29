package scenes;

import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Touch;
import com.haxepunk.Entity;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.utils.Ease;
//https://www.dropbox.com/sh/ewsopuvx8f1m3ev/LDg4eqhX1N
class GameScene extends Scene
{
	public function new()
	{
		super();

		map = new entities.Region();
		add(map);

		player = new entities.Player(512,128);
		player.region = map;
		add(player);
		
		
		//HXP.console.enable();
		

		text = new Text("Score:");
		text.scrollX = text.scrollY = 0.0;
		var e = new Entity(10,10,text);
		e.layer = -100;
		add(e);

		lvl = "1";
	}

	public override function begin()
	{
		map.load("Level_"+lvl,player);
		player.start();
	}

	private function getTime(t:Int)
	{
		var minutes:Int = Std.int(t /60.0);
		var seconds = t - (minutes * 60.0);
		return minutes + ":" + Std.int(seconds);
	}

	public override function update()
	{
		text.text = "Time: " + getTime(Std.int(player.lastTime)) + " +" + getTime(Std.int(player.time - player.lastTime)) + "\n";

		text.text += "Deaths: " + player.lastDeaths + " +" + (player.deaths - player.lastDeaths) + "\n";
		text.text += "Score: " + player.lastScore + " +" +(player.score - player.lastScore) + "\n";
		text.text += "Level: " + lvl + "\n";
		super.update();
	}

	public function shakeScreen(value:Float, duration:Float)
	{
		var tween:VarTween = new VarTween();

		tween.tween(HXP.camera,"x",HXP.camera.x + (Math.random() * value), duration,Ease.sineInOut );
		tween.tween(HXP.camera,"y",HXP.camera.y - (Math.random() * value), duration,Ease.sineInOut );
		addTween(tween,true);
	}

	public function popUp(text:String, duration:Float, x:Float, y:Float)
	{
		var tp = new Text(text);
		tp.scrollX = tp.scrollY = 1.0;
		var e = new Entity(x,y,tp);
		e.layer = -100;
		
		add(e);

		tp.alpha = 0.0;

		var tween:VarTween = new VarTween(popUpEnd);
		tween.tween(tp,"alpha",1.0,duration,Ease.sineInOut);
		addTween(tween,true);

		
	}

	public function popUpEnd(event:Dynamic)
	{
		remove(event);
	}



	private var map:entities.Region;
	public var lvl:String;
	private var text:Text;
	private var player:entities.Player;

}