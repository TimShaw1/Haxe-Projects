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
import haxe.Timer;
import openfl.Assets;

class PlayState extends FlxState
{
	var bowling_ball:FlxSprite;
	var pins:FlxGroup;
	var lane_sprite:FlxSprite;

	var gutter_sprite_left:FlxSprite;
	var gutter_sprite_right:FlxSprite;

	var wall_left:FlxSprite;
	var wall_right:FlxSprite;

	var ball_thrown = false;

	var mouse_start:FlxPoint;
	var mouse_end:FlxPoint;
	var move_time:Float;

	var seconds_since_epoch:Float = 0;
	var release_flag:Bool = false;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.BLACK;

		var lane_rect = FlxGraphic.fromRectangle(Math.round(FlxG.width / 2), FlxG.height, FlxColor.fromRGB(221, 178, 105));
		lane_sprite = new FlxSprite(FlxG.width / 2 - lane_rect.width / 2, 0, lane_rect);
		add(lane_sprite);

		create_gutters();

		create_walls();

		create_bowling_ball();

		create_pins();
		add(pins);
	}

	override public function update(elapsed:Float):Void
	{
		seconds_since_epoch += elapsed;
		super.update(elapsed);

		if (bowling_ball.y < -64)
			reset_scene();

		trace(bowling_ball.velocity);

		if (ball_thrown && FlxG.mouse.pressed && !release_flag && FlxG.mouse.y > 550)
		{
			bowling_ball.x = FlxG.mouse.x - bowling_ball.width / 2;
			bowling_ball.y = FlxG.mouse.y - bowling_ball.height / 2;
		}
		else if (!ball_thrown
			&& !FlxG.mouse.pressed
			&& FlxG.mouse.x > gutter_sprite_left.x + gutter_sprite_left.width
			&& FlxG.mouse.x < gutter_sprite_right.x)
			bowling_ball.x = FlxG.mouse.x - bowling_ball.width / 2;
		else if (!ball_thrown && FlxG.mouse.pressed && bowling_ball.overlapsPoint(FlxG.mouse.getPosition()))
		{
			mouse_start = FlxG.mouse.getPosition();
			if (FlxG.mouse.justMoved)
			{
				ball_thrown = true;
				move_time = seconds_since_epoch;
			}
			else
				ball_thrown = false;
		}
		else if (ball_thrown && FlxG.mouse.justReleased)
		{
			mouse_end = FlxG.mouse.getPosition();
			bowling_ball.velocity.x = (-(mouse_start.x - mouse_end.x) / (seconds_since_epoch - move_time)) / 2;
			bowling_ball.velocity.y = (-(mouse_start.y - mouse_end.y) / (seconds_since_epoch - move_time)) / 2;

			if (bowling_ball.velocity.y < -1000)
				bowling_ball.velocity.y = -1000;

			release_flag = true;
		}
		// check for collisions between pins and ball or pins and pins
		FlxG.overlap(bowling_ball, pins, separateCircle);
		FlxG.overlap(pins, pins, separateCircle);
		FlxG.overlap(bowling_ball, gutter_sprite_left, gutter_collision);
		FlxG.overlap(bowling_ball, gutter_sprite_right, gutter_collision);
		FlxG.collide(bowling_ball, wall_left);
		FlxG.collide(bowling_ball, wall_right);
	}

	public function create_walls()
	{
		var wall_rect = FlxGraphic.fromRectangle(200, FlxG.height, FlxColor.fromRGB(156, 117, 56, 255));
		wall_left = new FlxSprite(gutter_sprite_left.x - wall_rect.width, 0, wall_rect);
		wall_left.immovable = true;
		wall_right = new FlxSprite(gutter_sprite_right.x + gutter_sprite_right.width, 0, wall_rect);
		wall_right.immovable = true;

		add(wall_left);
		add(wall_right);
	}

	public function create_bowling_ball()
	{
		bowling_ball = new FlxSprite(0, 0);

		// Load bowling ball sprite and center/size it
		bowling_ball.loadGraphic("assets/Bowling-Ball-Spritesheet.png", true, 64, 64);
		bowling_ball.screenCenter();
		bowling_ball.setGraphicSize(Math.round(bowling_ball.width), Math.round(bowling_ball.height));

		// position ball
		// bowling_ball.x += 40;
		bowling_ball.y += 300;

		// Set ball mass and allow collisions
		bowling_ball.mass = 10;
		bowling_ball.allowCollisions = ANY;

		// Throw ball
		// bowling_ball.velocity.y = -300;
		// bowling_ball.velocity.x -= 10;

		// Add ball to scene
		add(bowling_ball);
	}

	public function create_pins():Void
	{
		pins = new FlxGroup();

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
				pin.y -= 100 + 50 * i;
				pin.x += 60 * pin_count - 30 * i + 10;

				// Resize pin and update hitbox
				pin.setGraphicSize(Math.round(pin.width / 1.5), Math.round(pin.height / 1.5));
				pin.updateHitbox();

				// Allow collisions
				pin.allowCollisions = ANY;

				// Apply drag
				pin.drag.x = 3;
				pin.drag.y = 3;

				pin.mass = 3;

				// add pin to pins group
				pins.add(pin);
			}
		}
	}

	public function create_gutters()
	{
		var gutter_rect = FlxGraphic.fromRectangle(74, FlxG.height, FlxColor.GRAY);
		gutter_sprite_left = new FlxSprite(lane_sprite.x - gutter_rect.width, 0, gutter_rect);
		gutter_sprite_right = new FlxSprite(lane_sprite.x + lane_sprite.width, 0, gutter_rect);

		add(gutter_sprite_left);
		add(gutter_sprite_right);
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
		if (distanceSquared < totalRadius * totalRadius && dot >= 0)
		{
			var d = Math.sqrt(Math.pow(circle1.x - circle2.x, 2) + Math.pow(circle1.y - circle2.y, 2));
			var nx = (circle2.x - circle1.x) / d;
			var ny = (circle2.y - circle1.y) / d;

			var dampening_factor = 1.5;
			var p = dampening_factor * (circle1.velocity.x * nx + circle1.velocity.y * ny - circle2.velocity.x * nx - circle2.velocity.y * ny) / (circle1.mass
				+ circle2.mass);

			// mass is now backwards but works?
			circle1.velocity.x -= p * circle2.mass * nx;
			circle1.velocity.y -= p * circle2.mass * ny;

			circle2.velocity.x += p * circle1.mass * nx;
			circle2.velocity.y += p * circle1.mass * ny;

			return true;
		}

		return false;
	}

	public function gutter_collision(ball:FlxSprite, gutter:FlxSprite):Bool
	{
		if (gutter.overlapsPoint(ball.getMidpoint()))
		{
			if (Math.abs(ball.getMidpoint().x - gutter.getMidpoint().x) < 10)
				ball.velocity.x = 0;
			return true;
		}

		return false;
	}

	public function reset_scene()
	{
		FlxG.resetState();
	}
}
