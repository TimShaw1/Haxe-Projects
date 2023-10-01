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
	var bowling_ball:FlxSprite;
	var pins:FlxGroup;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(156, 117, 56, 255);

		var lane = FlxGraphic.fromRectangle(Math.round(FlxG.width / 2.4), FlxG.height, FlxColor.fromRGB(221, 178, 105));
		var lane_sprite = new FlxSprite(FlxG.width / 2 - lane.width / 2, 0, lane);
		add(lane_sprite);

		bowling_ball = new FlxSprite(0, 0);
		bowling_ball.loadGraphic("assets/Bowling-Ball-Spritesheet.png", true, 64, 64);
		bowling_ball.screenCenter();
		bowling_ball.setGraphicSize(Math.round(bowling_ball.width), Math.round(bowling_ball.height));
		// bowling_ball.x += 20;
		bowling_ball.y += 100;
		bowling_ball.allowCollisions = ANY;
		// bowling_ball.collisionXDrag = CollisionDragType.IMMOVABLE;
		// bowling_ball.collisionYDrag = CollisionDragType.IMMOVABLE;
		bowling_ball.velocity.y = -100;
		bowling_ball.velocity.x -= 1;
		add(bowling_ball);

		pins = new FlxGroup();
		create_pins();
		add(pins);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		FlxG.overlap(bowling_ball, pins, separateCircle);
		FlxG.overlap(pins, pins, separateCircle);
		bowling_ball.velocity.y = -100;
	}

	public function create_pins():Void
	{
		// 4 columns
		for (i in 0...4)
		{
			// i+1 pins per row
			for (pin_count in 0...i + 1)
			{
				var pin = new FlxSprite(0, 0);
				pin.loadGraphic("assets/top-pin.png", false, 0, 0, true);
				pin.screenCenter();
				pin.y -= 80 + 60 * i;
				pin.x += 70 * pin_count - 35 * i;
				pin.setGraphicSize(Math.round(pin.width / 1.2), Math.round(pin.height / 1.2));
				pin.updateHitbox();
				pin.allowCollisions = ANY;
				pin.drag.x = 10;
				pin.drag.y = 10;
				pins.add(pin);
			}
		}
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
			// Get normalized tangent vector
			var tangentVector = new FlxPoint(circle2.y - circle1.y, -(circle2.x - circle1.x));
			tangentVector = tangentVector.normalize();

			// Determine relative velocity
			var relativeVelocity = new FlxPoint(circle2.velocity.x - circle1.velocity.x, circle2.velocity.y - circle1.velocity.y);
			var length = relativeVelocity.dot(tangentVector);

			// set tangent vector to correct length for velocity calculation
			var velocityComponentOnTangent = tangentVector * length;

			// get velocity perpendicular to our tangent line
			var velocityComponentPerpendicularToTangent = relativeVelocity - velocityComponentOnTangent;

			// Apply velocity to circles
			circle1.velocity.x += velocityComponentPerpendicularToTangent.x;
			circle1.velocity.y += velocityComponentPerpendicularToTangent.y;

			circle2.velocity.x -= velocityComponentPerpendicularToTangent.x;
			circle2.velocity.y -= velocityComponentPerpendicularToTangent.y;

			return true;
		}

		return false;
	}
}
