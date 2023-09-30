import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;

class TitleScreen extends FlxState
{
	var titleText:FlxText;
	var play_button:FlxButton;
	var AI_button:FlxButton;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(0, 150, 230, 200);
		titleText = format_text("Bowling\nGame");
		titleText.x -= 40;
		add(titleText);

		play_button = new FlxButton(0, 0, "Play", play);
		play_button.screenCenter();
		play_button.x += 80;
		play_button.setGraphicSize(Math.round(play_button.width * 2), Math.round(play_button.height * 2));

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

	public function format_text(text:String):FlxText
	{
		var formatted_text:FlxText;
		formatted_text = new FlxText(0, 0, FlxG.width / 2, text);
		formatted_text.setFormat(null, 32, FlxColor.WHITE);
		formatted_text.borderStyle = OUTLINE;
		formatted_text.borderSize = 3;
		formatted_text.borderColor = FlxColor.BLACK;
		formatted_text.screenCenter();

		return formatted_text;
	}
}
