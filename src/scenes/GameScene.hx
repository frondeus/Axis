package scenes;

import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Touch;
import com.haxepunk.Entity;
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

	public override function update()
	{
		var t:Int = Std.int(player.time - player.lastTime);
		text.text = "Score: " + player.score + "\n";
		var minutes:Int = Std.int(t /60.0);
		var seconds = t - (minutes * 60.0);
		text.text += "Time: " + minutes + ":" + Std.int(seconds);
		
		super.update();
	}
	private var map:entities.Region;
	public var lvl:String;
	private var text:Text;
	private var player:entities.Player;

}