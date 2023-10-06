import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class BowlingBall extends FlxSprite
{
	var ball_thrown = false;

	var release_flag:Bool = false;

	var mouse_start:FlxPoint;
	var mouse_end:FlxPoint;
	var move_time:Float;

	public var throw_counter:Int = 0;

	public function new()
	{
		super(0, 0);
		// Load bowling ball sprite and center/size it
		this.loadGraphic("assets/Bowling-Ball-Spritesheet.png", true, 64, 64);
		this.screenCenter();
		this.setGraphicSize(Math.round(this.width), Math.round(this.height));
		// position ball
		// this.x += 40;
		this.y += 300;
		// Set ball mass and allow collisions
		this.mass = 10;
		this.allowCollisions = ANY;
	}

	/**
	 * Updates the ball
	 * @param seconds_since_epoch how long since the scene started
	 * @param gutter_sprite_left the left gutter
	 * @param gutter_sprite_right the right gutter
	 */
	public function update_ball(seconds_since_epoch:Float, gutter_sprite_left:FlxSprite, gutter_sprite_right:FlxSprite)
	{
		// Ball follows mouse when mouse is pressed (not when thrown tho)
		if (ball_thrown && FlxG.mouse.pressed && !release_flag && FlxG.mouse.y > 500)
		{
			this.x = FlxG.mouse.x - this.width / 2;
			this.y = FlxG.mouse.y - this.height / 2;
		}
		// Ball is not thrown and mouse is within bounds -> ball follows mouse left/right only
		else if (!ball_thrown
			&& !FlxG.mouse.pressed
			&& FlxG.mouse.x > gutter_sprite_left.x + gutter_sprite_left.width
			&& FlxG.mouse.x < gutter_sprite_right.x)
			this.x = FlxG.mouse.x - this.width / 2;
		// Ball is being thrown
		else if (!ball_thrown && FlxG.mouse.pressed && FlxG.mouse.getPosition().y > 500)
		{
			// Get mouse start position for throw physics later
			mouse_start = FlxG.mouse.getPosition();

			// If mouse moves, get time when it moved.
			if (FlxG.mouse.justMoved)
			{
				ball_thrown = true;
				move_time = seconds_since_epoch;
			}
			else
				ball_thrown = false;
		}
		// Throw ball when mouse released
		else if (ball_thrown && FlxG.mouse.justReleased && !release_flag)
		{
			// Get where mouse was released
			mouse_end = FlxG.mouse.getPosition();

			// Calculate ball velocity
			var xVelocity = (-(mouse_start.x - mouse_end.x) / (seconds_since_epoch - move_time)) / 2;
			var yVelocity = (-(mouse_start.y - mouse_end.y) / (seconds_since_epoch - move_time)) / 2;

			// If valid y velocity,
			if (yVelocity < -30)
			{
				// Set velocity
				this.velocity.x = xVelocity;
				this.velocity.y = yVelocity;

				// Ensure ball is not going too fast
				if (this.velocity.y < -1000)
					this.velocity.y = -1000;

				release_flag = true;

				// Increment throw count
				throw_counter += 1;
			}
			// Otherwise reset the ball
			else
			{
				this.reset_ball();
			}
		}
	}

	/**
	 * Resets the ball's position and velocity
	 */
	public function reset_ball()
	{
		ball_thrown = false;
		release_flag = false;

		this.screenCenter();
		this.y += 300;
		this.velocity.x = 0;
		this.velocity.y = 0;
	}

	/**
	 * Resets throw count and calls reset_ball()
	 */
	public function full_reset_ball()
	{
		this.throw_counter = 0;
		this.reset_ball();
	}
}
