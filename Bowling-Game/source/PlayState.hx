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
	var bowling_ball:FlxSprite;
	var pins:FlxGroup;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(156, 117, 56, 255);

		var lane = FlxGraphic.fromRectangle(Math.round(FlxG.width / 2.4), FlxG.height, FlxColor.fromRGB(221, 178, 105));
		var lane_sprite = new FlxSprite(FlxG.width / 2 - lane.width / 2, 0, lane);
		add(lane_sprite);

		bowling_ball = new FlxSprite(0, 0);
		bowling_ball.loadGraphic("assets/Bowling-Ball-Spritesheet.png", true, 64, 64);
		bowling_ball.screenCenter();
		bowling_ball.setGraphicSize(Math.round(bowling_ball.width), Math.round(bowling_ball.height));
		bowling_ball.x += 30;
		bowling_ball.y += 100;
		bowling_ball.mass = 10;
		bowling_ball.allowCollisions = ANY;
		bowling_ball.velocity.y = -100;
		bowling_ball.velocity.x -= 10;
		add(bowling_ball);

		pins = new FlxGroup();
		create_pins();
		add(pins);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// check for collisions between pins and ball or pins and pins
		FlxG.overlap(bowling_ball, pins, separateCircle);
		FlxG.overlap(pins, pins, separateCircle);

		// Throw ball
		bowling_ball.velocity.y = -150;
	}

	public function create_pins():Void
	{
		// 4 columns
		for (i in 0...4)
		{
			// i+1 pins per row
			for (pin_count in 0...i + 1)
			{
				// Create pin sprite
				var pin = new FlxSprite(0, 0);
				pin.loadGraphic("assets/top-pin.png", false, 0, 0, true);

				// Center on screen
				pin.screenCenter();

				// Place in correct spots
				pin.y -= 80 + 60 * i;
				pin.x += 70 * pin_count - 35 * i;

				// Resize pin and update hitbox
				pin.setGraphicSize(Math.round(pin.width / 1.2), Math.round(pin.height / 1.2));
				pin.updateHitbox();

				// Allow collisions
				pin.allowCollisions = ANY;

				// Apply drag
				pin.drag.x = 6;
				pin.drag.y = 6;

				// add pin to pins group
				pins.add(pin);
			}
		}
	}

	public static function separateCircle(circle1:FlxSprite, circle2:FlxSprite):Bool
	{
		// Determine max distance between center of circles
		var totalRadius:Float = circle1.width / 2 + circle2.width / 2;
		var c1 = circle1.getMidpoint(FlxPoint.weak());
		var c2 = circle2.getMidpoint(FlxPoint.weak());

		// Get squared distance between circle midpoints. We square here to avoid a slow square root.
		var distanceSquared:Float = (c1.x - c2.x) * (c1.x - c2.x) + (c1.y - c2.y) * (c1.y - c2.y);

		// Prevent "Sticking" by checking if circles are actually moving towards each other
		var dx = circle1.x - circle2.x;
		var dy = circle1.y - circle2.y;
		var vx = circle2.velocity.x - circle1.velocity.x;
		var vy = circle2.velocity.y - circle1.velocity.y;

		// Positive if circles are moving towards each other
		var dot = dx * vx + dy * vy;

		// If circles overlap and are moving toward each other...
		if (distanceSquared < totalRadius * totalRadius && dot > 0)
		{
			var d = Math.sqrt(Math.pow(circle1.x - circle2.x, 2) + Math.pow(circle1.y - circle2.y, 2));
			var nx = (circle2.x - circle1.x) / d;
			var ny = (circle2.y - circle1.y) / d;

			var p = 2 * (circle1.velocity.x * nx + circle1.velocity.y * ny - circle2.velocity.x * nx - circle2.velocity.y * ny) / (circle1.mass + circle2.mass);

			// mass is now backwards but works?
			circle1.velocity.x -= p * circle2.mass * nx;
			circle1.velocity.y -= p * circle2.mass * ny;

			circle2.velocity.x += p * circle1.mass * nx;
			circle2.velocity.y += p * circle1.mass * ny;

			return true;
		}

		return false;
	}
}
