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
import openfl.text.Font;

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

	var game_ended:Bool = false;

	var frame_num = 1;
	var frame_scores = [
		new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0),
		new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0), new FlxPoint(0, 0)]; // 11-12 frames if strikes/spare on 10th
	var frame_display = ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"]; // total score or X or O

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(156, 117, 56, 255);

		// Create the lane graphic
		var lane_rect = FlxGraphic.fromRectangle(Math.round(FlxG.width / 2.5), FlxG.height, FlxColor.fromRGB(221, 178, 105));
		lane_sprite = new FlxSprite(FlxG.width / 2 - lane_rect.width / 2, 0, lane_rect);
		add(lane_sprite);

		var red_line_rect = FlxGraphic.fromRectangle(Math.round(FlxG.width / 2.5), 4, FlxColor.fromRGB(255, 0, 0));
		var red_line_sprite = new FlxSprite(FlxG.width / 2 - red_line_rect.width / 2, 500, red_line_rect);
		add(red_line_sprite);

		create_and_draw_gutters();

		create_walls();

		create_bowling_ball();

		create_pins();
		add(pins);
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

		if (game_ended)
			return;

		// Throw is done
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

		// check for collisions between ball and gutters
		FlxG.overlap(bowling_ball, gutter_sprite_left, gutter_collision);
		FlxG.overlap(bowling_ball, gutter_sprite_right, gutter_collision);

		// collide ball with walls
		FlxG.collide(bowling_ball, wall_left);
		FlxG.collide(bowling_ball, wall_right);

		for (pin in pins)
		{
			pin.check_knocked_over();
			// Collide pins with walls
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
		// Create gutter graphic
		var gutter_rect = FlxGraphic.fromRectangle(74, FlxG.height - 300, FlxColor.GRAY);

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

			// Credit to https://ericleong.me/research/circle-circle/ for the fancy math
			var nx = (circle2.x - circle1.x) / d;
			var ny = (circle2.y - circle1.y) / d;

			var dampening_factor = 1.5; // 2 is no dampening
			var p = dampening_factor * (circle1.velocity.x * nx + circle1.velocity.y * ny - circle2.velocity.x * nx - circle2.velocity.y * ny) / (circle1.mass
				+ circle2.mass);

			// Apply velocities on collision, accounting for mass
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

		// Next frame if we knocked over all pins
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
			frame_display[frame_num - 1] = bowling_ball.throw_counter == 1 || frame_num == 12 ? "X" : "O";
		else
			frame_display[frame_num - 1] = Std.string(frame_scores[frame_num - 1].y); // Display score if not strike/spare

		// Fully reset ball
		bowling_ball.full_reset_ball();

		// Increment frame count if we aren't done
		if (frame_num < 9)
			frame_num += 1;
		else if (frame_num < 12)
			if (frame_display[frame_num - 1] == "X")
				frame_num += 1;
			else if (frame_display[frame_num - 1] == "O" && frame_num == 9)
				frame_num += 1;
			else
			{
				end_game();
			}
		// else end game
		else
		{
			end_game();
		}

		// 12th frame only gets 1 throw
		if (frame_num == 12)
			bowling_ball.throw_counter = 1;
	}

	/**
	 * Calculates the player's final score
	 * @param frames_score_text the scoring text to be displayed at the end
	 * @return The final score
	 */
	public function calculate_final_score(frames_score_text:FlxText):Int
	{
		var score:Float = 0;

		// Loop through each frame
		for (i in 0...12)
		{
			var current_score:Float = 0;

			// Frame 1-9
			if (i < 9)
			{
				if (frame_display[i] == "X")
				{
					if (frame_display[i + 1] == "X")
					{
						current_score = 20 + frame_scores[i + 2].x; // 2/3 strike case
					}
					else
					{
						current_score = 10 + frame_scores[i + 1].y; // 1 strike case
					}
				}
				else if (frame_display[i] == "O")
				{
					current_score = 10 + frame_scores[i + 1].x; // spare case
				}
				else
				{
					current_score = frame_scores[i].y; // Score only case
				}

				// Add frame score to total score
				score += current_score;

				// Format text for each frame
				frames_score_text.text += score + "  ";
				if (score / 10 < 1)
				{
					frames_score_text.text += "  ";
				}
				if (score / 10 < 10)
				{
					frames_score_text.text += " ";
				}
			}
			// 10th frame scoring
			else
			{
				current_score = frame_scores[i].y;
				score += current_score;

				// Only draw score after last frame is calculated
				if (i == 11)
				{
					frames_score_text.text += score + "  ";
					if (score / 10 < 1)
					{
						frames_score_text.text += "  ";
					}
					if (score / 10 < 10)
					{
						frames_score_text.text += " ";
					}
				}
			}
		}

		// Hack to cast score to int
		return Math.round(score);
	}

	/**
	 * Generates the text for displaying each throw's score
	 * @return String
	 */
	public function generate_score_text():String
	{
		var score_text = "";
		for (i in 0...9)
		{
			var point = frame_scores[i];
			if (i != 8)
			{
				if (point.x != 10)
					score_text += point.x + "  " + frame_display[i] + "    ";
				else
					score_text += "    " + frame_display[i] + "    ";
			}
			else
			{
				if (point.x != 10)
					score_text += point.x + "  " + frame_display[i] + "  ";
				else
					score_text += "    " + frame_display[i] + "  ";
			}
		}
		score_text += frame_display[9];
		if (frame_display[10] != "0")
			score_text += frame_display[10];
		else
			score_text += "  ";
		if (frame_display[11] != "0")
			score_text += frame_display[11];
		else
			score_text += "  ";

		return score_text;
	}

	public function end_game()
	{
		// Initialize the per-frame score display text
		var frames_score_text = new FlxText(0, 0, 256, "");
		calculate_final_score(frames_score_text);

		// Game has ended
		game_ended = true;

		// Rectangle for dimming screen
		var dim_rect = new FlxSprite(0, 0);
		dim_rect.loadGraphic(FlxGraphic.fromRectangle(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 0, 0, 127)));
		add(dim_rect);

		// Load and format frames sprite to display scores
		var frames_sprite = new FlxSprite(0, 0);
		frames_sprite.loadGraphic("assets/Bowling_Frames_Sprite.png");
		frames_sprite.screenCenter();
		frames_sprite.scale.x *= 1.25;
		frames_sprite.scale.y *= 1.25;
		add(frames_sprite);

		// Create text for per-throw scores
		var score_text = new FlxText(0, 0, 0, generate_score_text());
		score_text.screenCenter();
		score_text.scale.x *= 2.68;
		score_text.scale.y *= 2.68;
		score_text.y -= 18;
		add(score_text);

		// Format text for frame aggregate scores
		frames_score_text.screenCenter();
		frames_score_text.scale.x *= 3.8;
		frames_score_text.scale.y *= 3.8;
		frames_score_text.x += 90;
		frames_score_text.y += 14;
		add(frames_score_text);

		// Create a button to return to title screen
		var title_button;
		title_button = new FlxButton(0, 0, "Title Screen", back_to_title);
		title_button.screenCenter();
		title_button.y += 180;
		title_button.setGraphicSize(Math.round(title_button.width * 2), Math.round(title_button.height * 2));

		add(title_button);
	}

	/**
	 * Returns the game to the title screen
	 */
	public function back_to_title()
	{
		FlxG.switchState(new TitleScreen());
	}
}
