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

class HowToScene extends Scene
{
	public function new()
	{
		super();

#if (android || ios)
		text = new Text("tap to continue");
		img = new Image("gfx/howtoa.png");
#else
		text = new Text("press any key to continue");
		img = new Image("gfx/howto.png");
#end
		
		img.x = HXP.halfWidth - (img.width * 0.5);
		img.y = HXP.halfHeight - (img.height * 0.5);

		HXP.screen.color = 0;
		addGraphic(img);

		text.x = HXP.halfWidth - (text.textWidth * 0.5);
		text.y = img.y + img.height + 10;
		addGraphic(text);

		Input.define("any",[Key.ANY]);
		
		
	}
	public override function begin()
	{
		img.alpha = 0.0;

		var bgT:VarTween = new VarTween(onBgEnd);
		bgT.tween(img,"alpha",1.0,1.0);
		addTween(bgT,true);

		text.visible = false;
	}

 	function onBgEnd(event:Dynamic)
	{
		text.visible = true;
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
					if(text.visible)	HXP.scene = Main.gameplay;
					else 
					{
						img.alpha = 1.0;
						text.visible = true;
					}
				}
			}
		}
#end
		if(Input.mousePressed || Input.pressed("any"))
		{
			if(text.visible)	HXP.scene = Main.gameplay;
			else 
			{
				img.alpha = 1.0;
				text.visible = true;
			}
		}
		super.update();
	}

	private var img:Image;
	private var text:Text;
}