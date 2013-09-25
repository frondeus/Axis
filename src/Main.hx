import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.RenderMode;

class Main extends Engine
{
	override public function init()
	{
		// HXP.console.enable();
		title = new scenes.TitleScene();
		howto = new scenes.HowToScene();
		gameplay = new scenes.GameScene();
		score = new scenes.ScoreScene();
		HXP.scene = title;
	}

	public static function main() { new Main(); }

	public static var title:scenes.TitleScene;
	public static var howto:scenes.HowToScene;
	public static var gameplay:scenes.GameScene;
	public static var score:scenes.ScoreScene;
}