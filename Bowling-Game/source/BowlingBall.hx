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

	/** TODO: Refactor this later pls */
	public function update_ball(seconds_since_epoch:Float, gutter_sprite_left:FlxSprite, gutter_sprite_right:FlxSprite)
	{
		if (ball_thrown && FlxG.mouse.pressed && !release_flag && FlxG.mouse.y > 500)
		{
			this.x = FlxG.mouse.x - this.width / 2;
			this.y = FlxG.mouse.y - this.height / 2;
		}
		else if (!ball_thrown
			&& !FlxG.mouse.pressed
			&& FlxG.mouse.x > gutter_sprite_left.x + gutter_sprite_left.width
			&& FlxG.mouse.x < gutter_sprite_right.x)
			this.x = FlxG.mouse.x - this.width / 2;
		else if (!ball_thrown && FlxG.mouse.pressed && this.overlapsPoint(FlxG.mouse.getPosition()))
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
		else if (ball_thrown && FlxG.mouse.justReleased && !release_flag)
		{
			mouse_end = FlxG.mouse.getPosition();
			this.velocity.x = (-(mouse_start.x - mouse_end.x) / (seconds_since_epoch - move_time)) / 2;
			this.velocity.y = (-(mouse_start.y - mouse_end.y) / (seconds_since_epoch - move_time)) / 2;

			if (this.velocity.y < -1000)
				this.velocity.y = -1000;

			release_flag = true;
		}
	}
}
