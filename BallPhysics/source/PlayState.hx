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
	var line:FlxSprite;
	var yellowCircle:FlxSprite;
	var orangeCircle:FlxSprite;
	var navyCircle:FlxSprite;
	var redCircle:FlxSprite;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(84, 182, 180);

		// Initialize line to bounce on
		line = new FlxSprite(0, 0, FlxGraphic.fromRectangle(Math.round(FlxG.width / 1.2), 4, FlxColor.fromRGB(210, 210, 210)));
		line.screenCenter();
		line.y += 200;
		line.allowCollisions = UP;
		line.immovable = true;

		add(line);

		// Initialize circle sprites
		yellowCircle = new FlxSprite(0, 0);
		yellowCircle.loadGraphic("assets/Yellow_Ball.png");
		yellowCircle.scale.x = 0.05;
		yellowCircle.scale.y = 0.05;
		yellowCircle.updateHitbox();
		yellowCircle.acceleration.y = 1800; // gravity
		yellowCircle.screenCenter();
		yellowCircle.y -= 500;
		yellowCircle.x -= 200;

		add(yellowCircle);

		orangeCircle = new FlxSprite(0, 0);
		orangeCircle.loadGraphic("assets/BasketBall.png");
		orangeCircle.scale.x = 0.05;
		orangeCircle.scale.y = 0.05;
		orangeCircle.updateHitbox();
		orangeCircle.acceleration.y = 3000; // gravity
		orangeCircle.screenCenter();
		orangeCircle.y -= 500;
		orangeCircle.x -= 100;

		add(orangeCircle);

		navyCircle = new FlxSprite(0, 0);
		navyCircle.loadGraphic("assets/soccerBall.png");
		navyCircle.scale.x = 0.12;
		navyCircle.scale.y = 0.12;
		navyCircle.updateHitbox();
		navyCircle.acceleration.y = 1800; // gravity
		navyCircle.screenCenter();
		navyCircle.y -= 500;
		navyCircle.x += 50;

		add(navyCircle);

		redCircle = new FlxSprite(0, 0);
		redCircle.loadGraphic("assets/bowlingBall.png");
		redCircle.scale.x = 0.35;
		redCircle.scale.y = 0.35;
		redCircle.updateHitbox();
		redCircle.acceleration.y = 1200; // gravity
		redCircle.screenCenter();
		redCircle.y -= 500;
		redCircle.x += 150;

		add(redCircle);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		applyBallPhysics(yellowCircle, 0.5, 0, 0);
		applyBallPhysics(orangeCircle, 0.8, 0, 0);
		applyBallPhysics(navyCircle, 0.2, 0.7, 30);
		applyBallPhysics(redCircle, 0.5, 0.2, 100);
	}

	/** Helper function to apply ball physics
		@param ball : a FlxSprite of a ball
		@param dragY : how much energy is lost after a bounce
		@param dragX : how much energy is lost as it moves 
		@param xVelocityOnCollide : how fast the ball bounces right on collide
	 */
	public function applyBallPhysics(ball:FlxSprite, dragY:Float, dragX:Float, xVelocityOnCollide:Float):Void
	{
		// Get velocity ore-collision
		var prevVelocity = ball.velocity.clone();

		// Prevent jitter
		if (prevVelocity.y < ball.acceleration.y / 15)
			prevVelocity.y = 0;

		if (FlxG.collide(line, ball))
		{
			// invert velocity
			ball.velocity.y = -prevVelocity.y * dragY;
			if (ball.velocity.x == 0 && xVelocityOnCollide != 0)
			{
				ball.velocity.x = xVelocityOnCollide;
				ball.angularVelocity = 80;
			}
		}

		// Slow down rotation and movement
		ball.velocity.x *= 1 - (dragX / 100);
		ball.angularVelocity *= 1 - (dragX / 100);
	}
}
