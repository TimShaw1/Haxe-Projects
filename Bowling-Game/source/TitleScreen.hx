import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class TitleScreen extends FlxState
{
	var titleText:FlxText;
	var play_button:FlxButton;
	var AI_button:FlxButton;

	override public function create():Void
	{
		super.create();
		titleText = new FlxText(0, 0, FlxG.width / 2, "Bowling\nGame");
		titleText.setFormat(null, 32, FlxColor.ORANGE);
		titleText.screenCenter();
		titleText.x -= 40;
		add(titleText);

		play_button = new FlxButton(0, 0, "Play", play);
		play_button.screenCenter();
		play_button.x += 80;
		play_button.y -= 50;

		add(play_button);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public function play()
	{
		FlxG.switchState(new PlayState());
	}
}
