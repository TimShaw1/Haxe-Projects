package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import openfl.Assets;

class PlayState extends FlxState
{
	var pins:FlxGroup;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(156, 117, 56, 255);

		var bowling_ball = new FlxSprite(0, 0);
		bowling_ball.loadGraphic("assets/Bowling-Ball-Spritesheet.png", true, 64, 64);
		bowling_ball.screenCenter();
		bowling_ball.setGraphicSize(Math.round(bowling_ball.width), Math.round(bowling_ball.height));
		bowling_ball.y += 100;

		var lane = FlxGraphic.fromRectangle(Math.round(FlxG.width / 2.4), FlxG.height, FlxColor.fromRGB(221, 178, 105));
		var lane_sprite = new FlxSprite(FlxG.width / 2 - lane.width / 2, 0, lane);
		add(lane_sprite);
		add(bowling_ball);

		pins = new FlxGroup();

		create_pins();

		add(pins);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public function create_pins():Void
	{
		for (i in 0...4)
		{
			for (pin_count in 0...i + 1)
			{
				var pin = new FlxSprite(0, 0);
				pin.loadGraphic("assets/top-pin.png", false, 0, 0, true);
				pin.screenCenter();
				pin.y -= 80 + 60 * i;
				pin.x += 70 * pin_count - 35 * i;
				pin.setGraphicSize(Math.round(pin.width / 1.2), Math.round(pin.height / 1.2));
				pins.add(pin);
			}
		}
	}
}
