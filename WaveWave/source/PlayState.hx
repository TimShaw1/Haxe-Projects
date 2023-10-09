package;

import Player;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	var player:Player;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.WHITE;
		player = new Player();
		add(player);
		add(player.trail);

		draw_triangle(50, 500, 300);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		player.onUpdate();
		draw_line(player.x, player.y, player.x + 100, player.y + 100);
	}

	public function draw_line(xStart:Float, yStart:Float, xEnd:Float, yEnd:Float, color:FlxColor = FlxColor.BLACK):Void
	{
		var line = new FlxSprite();
		line.makeGraphic(FlxG.width, FlxG.height, 0, true);
		FlxSpriteUtil.fill(line, FlxColor.fromRGB(0, 0, 0, 0));
		FlxSpriteUtil.drawLine(line, xStart, yStart, xEnd, yEnd, {
			thickness: 3,
			color: color
		});
		add(line);
	}

	public function draw_triangle(x, y, h)
	{
		draw_line(x, y, x + (h / 2), y - h);
		draw_line(x + (h / 2), y - h, x + h, y);
		draw_line(x, y, x + h, y);
	}
}
