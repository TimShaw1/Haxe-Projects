import flixel.FlxSprite;

class BowlingPin extends FlxSprite
{
	public function new()
	{
		super(0, 0);
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
}
