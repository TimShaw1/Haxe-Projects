package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import openfl.Assets;

class PlayState extends FlxState
{
	override public function create():Void
	{
		super.create();
		var bowling_ball = new FlxSprite(0, 0);
		bowling_ball.loadGraphic("assets/bowling-ball.png");
		bowling_ball.screenCenter();
		bowling_ball.setGraphicSize(Math.round(bowling_ball.width / 2), Math.round(bowling_ball.height / 2));

		add(bowling_ball);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
