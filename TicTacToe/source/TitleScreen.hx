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
		titleText = new FlxText(0, 0, FlxG.width / 2, "Tic\nTac\nToe");
		titleText.setFormat(null, 64, FlxColor.ORANGE);
		titleText.screenCenter();
		titleText.x -= 40;
		add(titleText);

		play_button = new FlxButton(0, 0, "2 Player", play);
		play_button.screenCenter();
		play_button.x += 80;
		play_button.y -= 50;
		AI_button = new FlxButton(0, 0, "Play Bot", play_bot);
		AI_button.screenCenter();
		AI_button.x += 80;
		AI_button.y += 50;

		add(play_button);
		add(AI_button);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public function play()
	{
		FlxG.switchState(new Players_State());
	}

	public function play_bot()
	{
		FlxG.switchState(new AgainstAI_State());
	}
}
