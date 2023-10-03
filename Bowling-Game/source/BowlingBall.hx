import flixel.FlxSprite;

class BowlingBall extends FlxSprite
{
	public function new()
	{
		super(0, 0);
		// Load bowling ball sprite and center/size it
		this.loadGraphic("assets/Bowling-Ball-Spritesheet.png", true, 64, 64);
		this.screenCenter();
		this.setGraphicSize(Math.round(this.width), Math.round(this.height));
		// position ball
		// bowling_ball.x += 40;
		this.y += 300;
		// Set ball mass and allow collisions
		this.mass = 10;
		this.allowCollisions = ANY;
	}
}
