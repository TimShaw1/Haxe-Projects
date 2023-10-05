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
	var bowling_ball:BowlingBall;
	var pins:FlxTypedGroup<BowlingPin>;
	var lane_sprite:FlxSprite;

	var gutter_sprite_left:FlxSprite;
	var gutter_sprite_right:FlxSprite;

	var wall_left:FlxSprite;
	var wall_right:FlxSprite;

	var seconds_since_epoch:Float = 0;

	var frame_num = 1;
	var frame_scores = [
		new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0),
		new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0)]; // 11-12 frames if strikes/spare on 10th
	var frame_display = ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"]; // total score or X or O

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.BLACK;

		var lane_rect = FlxGraphic.fromRectangle(Math.round(FlxG.width / 2.5), FlxG.height, FlxColor.fromRGB(221, 178, 105));
		lane_sprite = new FlxSprite(FlxG.width / 2 - lane_rect.width / 2, 0, lane_rect);
		add(lane_sprite);

		create_and_draw_gutters();

		create_walls();

		create_bowling_ball();

		create_pins();
		add(pins);

		trace(calculate_final_score());
	}

	/**
	 * Handles updating physics and collision
	 * @param elapsed how long the last frame took
	 */
	override public function update(elapsed:Float):Void
	{
		// Useful for physics calculations
		seconds_since_epoch += elapsed;

		super.update(elapsed);

		if (bowling_ball.y < -128)
		{
			if (bowling_ball.throw_counter < 2)
				re_place_pins_and_ball();
			else
				set_frame();
		}

		bowling_ball.update_ball(seconds_since_epoch, gutter_sprite_left, gutter_sprite_right);

		// check for collisions between pins and ball or pins and pins
		FlxG.overlap(bowling_ball, pins, collide_circles);
		FlxG.overlap(pins, pins, collide_circles);
		FlxG.overlap(bowling_ball, gutter_sprite_left, gutter_collision);
		FlxG.overlap(bowling_ball, gutter_sprite_right, gutter_collision);
		FlxG.collide(bowling_ball, wall_left);
		FlxG.collide(bowling_ball, wall_right);

		for (pin in pins)
		{
			pin.check_knocked_over();
			if (FlxG.overlap(pin, wall_left) || FlxG.overlap(pin, wall_right))
			{
				pin.velocity.x *= -1;
				pin.x += pin.velocity.x / 60;
			}
		}
	}

	/**
	 * Creates and draws the walls
	 */
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

	/**
	 * Creates and draws the bowling ball
	 */
	public function create_bowling_ball()
	{
		bowling_ball = new BowlingBall();
		bowling_ball.reset_ball();

		// Add ball to scene
		add(bowling_ball);
	}

	/**
	 * Creates and draws 10 pins in a group.
	 */
	public function create_pins():Void
	{
		pins = new FlxTypedGroup<BowlingPin>();

		// 4 columns
		for (i in 0...4)
		{
			// i+1 pins per row
			for (pin_count in 0...i + 1)
			{
				// Create pin sprite
				var pin = new BowlingPin();

				// Place in correct spots
				pin.y -= 100 + 50 * i;
				pin.x += 80 * pin_count - 40 * i + 10;

				pin.original_position.x = pin.x;
				pin.original_position.y = pin.y;

				// add pin to pins group
				pins.add(pin);
			}
		}
	}

	/**
	 * Creates and draws the gutters
	 */
	public function create_and_draw_gutters()
	{
		var gutter_rect = FlxGraphic.fromRectangle(74, FlxG.height, FlxColor.GRAY);

		gutter_sprite_left = new FlxSprite(lane_sprite.x - gutter_rect.width, 0, gutter_rect);
		gutter_sprite_right = new FlxSprite(lane_sprite.x + lane_sprite.width, 0, gutter_rect);

		add(gutter_sprite_left);
		add(gutter_sprite_right);
	}

	/**
	 * Custom circle collision
	 * @param circle1 a circular FlxSprite
	 * @param circle2 a circular FlxSprite
	 * @return true if collision, else false
	 */
	public static function collide_circles(circle1:FlxSprite, circle2:FlxSprite):Bool
	{
		if (circle1.allowCollisions == NONE || circle2.allowCollisions == NONE)
			return false;
		// Determine max distance between center of circles
		var totalRadius:Float = circle1.width / 2 + circle2.width / 2;
		var c1 = circle1.getMidpoint();
		var c2 = circle2.getMidpoint();

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
			// Distance between circles
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

	/**
	 * Handles ball colliding with gutter by setting ball's x velocity to 0
	 * @param ball the ball
	 * @param gutter the gutter
	 * @return true if collision
	 */
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

	/**
	 * Sets up pins and ball for second throw of a frame
	 */
	public function re_place_pins_and_ball()
	{
		var knocked_pin_counter = 0;
		for (pin in pins)
		{
			if (pin.knocked_over)
				knocked_pin_counter += 1;
			pin.reset_pin();
		}

		frame_scores[frame_num - 1].x += knocked_pin_counter;

		if (knocked_pin_counter == 10)
		{
			set_frame();
		}
		bowling_ball.reset_ball();
	}

	/**
	 * Sets up pins and ball for new frame
	 */
	public function set_frame()
	{
		// reset pins
		for (pin in pins)
		{
			if (pin.knocked_over)
				frame_scores[frame_num - 1].y += 1;
			pin.knocked_over = false;
			pin.reset_pin();
		}

		// Handle displaying strikes/spares
		if (frame_scores[frame_num - 1].y == 10)
			frame_display[frame_num - 1] = bowling_ball.throw_counter == 1 ? "X" : "O";

		// Display score if not strike/spare
		else
			frame_display[frame_num - 1] = Std.string(frame_scores[frame_num - 1].y);

		// Fully reset ball
		bowling_ball.full_reset_ball();

		// Increment frame count if we aren't done
		if (frame_num < 10 || (frame_num < 12 && frame_scores[frame_num - 1].y == 10))
			frame_num += 1;
		// else end game
		else
		{
			trace(calculate_final_score());
			FlxG.switchState(new TitleScreen());
		}

		// 12th frame only gets 1 throw
		if (frame_num == 12)
			bowling_ball.throw_counter = 1;

		// show score
		trace(frame_scores);
		trace(frame_display);
	}

	public function calculate_final_score():Int
	{
		var score:Float = 0;
		for (i in 0...10)
		{
			if (frame_display[i] == "X")
			{
				if (frame_display[i + 1] == "X")
				{
					score += 20 + frame_scores[i + 2].x; // 2/3 strike case
				}
				else
				{
					score += 10 + frame_scores[i + 1].x; // 1 strike case
				}
			}
			else if (frame_display[i] == "O")
			{
				score += 10 + frame_scores[i + 1].x; // spare case
			}
			else
			{
				score += frame_scores[i].y;
			}
		}
		return Math.round(score);
	}
}
