import flixel.FlxSprite;
import flixel.math.FlxPoint;

class BowlingPin extends FlxSprite
{
	public var knocked_over:Bool = false;
	public var original_position:FlxPoint;

	public function new()
	{
		super(0, 0);
		original_position = new FlxPoint(0, 0);
		this.loadGraphic("assets/top-pin.png", false, 0, 0, true);

		// Center on screen
		this.screenCenter();

		// Resize pin and update hitbox
		this.setGraphicSize(Math.round(this.width / 1.5), Math.round(this.height / 1.5));
		this.updateHitbox();

		// Allow collisions
		this.allowCollisions = ANY;

		// Apply drag
		this.drag.x = 3;
		this.drag.y = 3;

		this.mass = 3;
	}

	/**
	 * Checks if the pin was knocked over
	 */
	public function check_knocked_over()
	{
		if (Math.abs(this.velocity.x) > 80 || Math.abs(this.velocity.y) > 80)
			this.knocked_over = true;
	}

	/**
	 * Resets the pin
	 */
	public function reset_pin()
	{
		if (!this.knocked_over)
		{
			this.visible = true;
			this.allowCollisions = ANY;
			this.setPosition(this.original_position.x, this.original_position.y);
			this.velocity.x = 0;
			this.velocity.y = 0;
		}
		else
		{
			this.visible = false;
			this.allowCollisions = NONE;
		}
	}
}
