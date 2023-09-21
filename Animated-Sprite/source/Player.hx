package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * Extends FlxSprite to create an animated player with movement 
 */
class Player extends FlxSprite
{
	static inline var SPEED:Float = 500;

	public function new(x:Float = 0, y:Float = 0, w:Int, h:Int, ?path_to_spritesheet:String = "assets/spritesheet.png")
	{
		super(x, y);

		// Add drag so player slows down
		drag.x = drag.y = 800;

		// Load sprite sheet and enable animation
		loadGraphic(path_to_spritesheet, true, w, h);

		// Flip sprite on left/right
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);

		updateHitbox();

		// Add animation frames
		animation.add("idle", [0]);
		animation.add("walk", [0, 1, 2, 3, 4, 5, 6, 7], 15);
	}

	/**
	 * Helper function to handle player movement and animations
	 */
	public function updateMovement()
	{
		// Create directional booleans
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		// Define directional booleans
		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);

		// Opposite directions cancel out
		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up || down || left || right)
		{
			// Run angle to handle diagonal movement
			var newAngle:Float = 0;
			if (up)
			{
				// Straight up
				newAngle = -90;

				// Up and Left
				if (left)
					newAngle -= 45;
				// Up and right
				else if (right)
					newAngle += 45;

				// Update facing direction
				facing = UP;
			}
			else if (down)
			{
				// Straight down
				newAngle = 90;

				// Down and left
				if (left)
					newAngle += 45;
				// Down and right
				else if (right)
					newAngle -= 45;

				// Update facign direction
				facing = DOWN;
			}
			else if (left)
			{
				// Straight left
				newAngle = 180;
				facing = LEFT;
			}
			else if (right)
			{
				// Straight right
				newAngle = 0;
				facing = RIGHT;
			}

			// determine velocity based on angle + speed
			velocity.setPolarDegrees(SPEED, newAngle);
		}

		// Default to idle animation
		var action = "idle";

		// check if player is moving, and not colliding with walls
		if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
		{
			action = "walk";
		}

		switch (facing)
		{
			// Animate player if moving
			case LEFT, RIGHT:
				animation.play(action);
			case UP:
				animation.play(action);
			case DOWN:
				animation.play(action);

			// Do nothing if not moving
			case _:
		}
	}

	override public function update(elapsed:Float)
	{
		// Animate and move player as needed
		updateMovement();
		super.update(elapsed);
	}
}
