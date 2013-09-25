package scenes;

import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;

import com.haxepunk.utils.Key;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.utils.Ease;
import com.haxepunk.Tween;

class ScoreScene extends Scene
{
	public function new()
	{
		super();

#if (android || ios)
		exitText = new Text("tap to continue");
#else
		exitText = new Text("press any key to continue");
#end

		scoreText = new Text("Score: ");
		leveltimeText = new Text("Level Time: ");
		timeText = new Text("Time: ");
		deathsText = new Text("Deaths: ");

		img = new Image("gfx/score.png");
		img.x = HXP.halfWidth - (img.width * 0.5);
		img.y = HXP.halfHeight - (img.height * 0.5);
		
		HXP.screen.color = 0;
		addGraphic(img);

		exitText.x = HXP.halfWidth - (exitText.textWidth * 0.5);
		scoreText.x = HXP.halfWidth - (scoreText.textWidth * 0.5);
		leveltimeText.x = HXP.halfWidth - (leveltimeText.textWidth * 0.5);
		timeText.x = HXP.halfWidth - (timeText.textWidth * 0.5);
		deathsText.x = HXP.halfWidth - (deathsText.textWidth * 0.5);

		leveltimeText.y = (img.y +100 +20);
		timeText.y = (img.y + 100 +40);
		deathsText.y = (img.y + 100 + 60);
		scoreText.y = (img.y + 100 +80);



		exitText.y = (img.y + 200);

		addGraphic(exitText);
		addGraphic(scoreText);
		addGraphic(leveltimeText);
		addGraphic(timeText);
		addGraphic(deathsText);

		Input.define("any",[Key.ANY]);
	}
	private function date(t:Float)
	{
		var minutes:Int = Std.int(t /60.0);
		var seconds = t - (minutes * 60.0);
		return minutes + ":" + Std.int(seconds);
	}
	public function set(score:Int,leveltime:Float, time:Float, deaths:Int)
	{
		

		scoreText.text = "Score: " + score;
		leveltimeText.text = "Level Time: " + date(leveltime);
		timeText.text = "Time: " + date(time);
		deathsText.text = "Deaths: " + deaths;
	}
	public override function begin()
	{

		img.alpha = exitText.alpha = scoreText.alpha = timeText.alpha = leveltimeText.alpha  = deathsText.alpha= 0.0;

		var bgT:VarTween = new VarTween(onBgEnd);
		bgT.tween(img,"alpha",1.0,1.0);
		addTween(bgT,true);


	}

 	function onBgEnd(event:Dynamic)
	{
		var bgT:VarTween = new VarTween(onLevelTimeEnd);
		bgT.tween(leveltimeText,"alpha",1.0,1.0);
		addTween(bgT,true);
	}

	function onLevelTimeEnd(event:Dynamic)
	{
		var bgT:VarTween = new VarTween(onTimeEnd);
		bgT.tween(timeText,"alpha",1.0,1.0);
		addTween(bgT,true);
	}

	function onTimeEnd(event:Dynamic)
	{
		var bgT:VarTween = new VarTween(onDeathEnd);
		bgT.tween(deathsText,"alpha",1.0,1.0);
		addTween(bgT,true);
	}

	function onDeathEnd(event:Dynamic)
	{
		var bgT:VarTween = new VarTween(onScoreEnd);
		bgT.tween(scoreText,"alpha",1.0,1.0);
		addTween(bgT,true);
	}

	function onScoreEnd(event:Dynamic)
	{
		var bgT:VarTween = new VarTween();
		bgT.tween(exitText,"alpha",1.0,1.0);
		addTween(bgT,true);
	}


	public override function update()
	{
#if (android || ios)
		if(Input.multiTouchSupported)
		{
			if(Input.touches.exists(0))
			{
				if(Input.touches[0].pressed)
				{
					if(exitText.alpha == 1.0)	HXP.scene = Main.gameplay;
					else {
						img.alpha = deathsText.alpha = scoreText.alpha = leveltimeText.alpha = timeText.alpha = exitText.alpha = 1.0;
						clearTweens();
					}
				}
			}
		}
#end
		if(Input.mousePressed || Input.pressed("any"))
		{
			if(exitText.alpha == 1.0)	HXP.scene = Main.gameplay;
			else {
				deathsText.alpha = img.alpha = scoreText.alpha = leveltimeText.alpha = timeText.alpha = exitText.alpha = 1.0;
				clearTweens();
			}
		}
		super.update();
	}

	private var img:Image;
	private var exitText:Text;
	private var scoreText:Text;
	private var leveltimeText:Text;
	private var timeText:Text;
	private var deathsText:Text;
}