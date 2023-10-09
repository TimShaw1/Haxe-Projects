import Math;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSplash;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	var angleRadians:Float = (3 * Math.PI / 8);
	var up_or_down:Int = 1;
	var move_speed = 120;

	public var trail:FlxSprite;

	public function new()
	{
		super(0, 0);
		this.loadGraphic("assets/Right-Arrow.png");
		this.setGraphicSize(20, 20);
		this.screenCenter();

		this.velocity.y = Math.sin(angleRadians) * 80 * up_or_down;
		this.velocity.x = Math.cos(angleRadians) * 80;

		// this.create_trail();
		trail = this.create_trail();
	}

	public function onUpdate()
	{
		if (FlxG.mouse.justReleased || FlxG.mouse.justPressed)
		{
			up_or_down *= -1;
			this.velocity.y = Math.sin(angleRadians) * move_speed * up_or_down;
			this.velocity.x = Math.cos(angleRadians) * move_speed;
		}
	}

	public function create_trail(color:FlxColor = FlxColor.BLACK):FlxSprite
	{
		var trail_temp = new FlxSprite();
		trail_temp.makeGraphic(FlxG.width, FlxG.height, 0, true);
		FlxSpriteUtil.fill(trail_temp, FlxColor.fromRGB(0, 0, 0, 0));
		trace(this.getPosition());
		return FlxSpriteUtil.drawLine(trail_temp, this.getPosition().x, 0, 100, 100, {
			thickness: 3,
			color: FlxColor.BLACK
		});
	}

	public function draw_line(xStart:Float, yStart:Float, xEnd:Float, yEnd:Float, color:FlxColor = FlxColor.BLACK):FlxSprite
	{
		var line = new FlxSprite();
		line.makeGraphic(FlxG.width, FlxG.height, 0, true);
		FlxSpriteUtil.fill(line, FlxColor.fromRGB(0, 0, 0, 0));
		FlxSpriteUtil.drawLine(line, xStart, yStart, xEnd, yEnd, {
			thickness: 3,
			color: color
		});
		return line;
	}
}
