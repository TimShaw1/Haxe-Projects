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
	var animatedPlayer:Player;

	override public function create():Void
	{
		super.create();
		animatedPlayer = new Player(0, 0, 80, 101);

		add(animatedPlayer);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
