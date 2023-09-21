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

class AgainstAI_State extends FlxState
{
	var _tileMap:FlxTilemap;
	var tiles:FlxTypedGroup<FlxSprite>;

	var board = [0, 0, 0, 0, 0, 0, 0, 0, 0];

	var X_Sprite:FlxSprite;
	var O_Sprite:FlxSprite;

	var Xturn:Bool = true;

	var game_over:Bool = false;

	override public function create():Void
	{
		super.create();
		bgColor = FlxColor.fromRGB(255, 0, 0, 20);

		tiles = new FlxTypedGroup<FlxSprite>();

		// Generate grid
		for (width in 0...3)
		{
			for (height in 0...3)
			{
				var tile = new FlxSprite(width * Math.round(FlxG.width / 3), height * Math.round(FlxG.height / 3));
				tile.makeGraphic(Math.round(FlxG.width / 3), Math.round(FlxG.height / 3), FlxColor.GRAY, true);
				for (x in 0...Math.round(FlxG.width / 3))
				{
					for (y in 0...Math.round(FlxG.height / 3))
					{
						if ((x != 0 && y != 0 && (x != Math.round(FlxG.width / 3) - 1) && y != Math.round(FlxG.height / 3) - 1))
							tile.pixels.setPixel(x, y, FlxColor.TRANSPARENT);

						if ((x == 0 && width == 0)
							|| (y == 0 && height == 0)
							|| (x == Math.round(FlxG.width / 3) - 1 && width == 2)
							|| (y == Math.round(FlxG.height / 3) - 1 && height == 2))
							tile.pixels.setPixel(x, y, FlxColor.TRANSPARENT);
					}
				}
				tiles.add(tile);
			}
		}

		add(tiles);

		X_Sprite = new FlxSprite(0, 0);
		X_Sprite.loadGraphic("assets/X.png", false, Math.round(FlxG.width / 3), Math.round(FlxG.height / 3));

		O_Sprite = new FlxSprite(0, 0);
		O_Sprite.loadGraphic("assets/O.png", false, Math.round(FlxG.width / 3), Math.round(FlxG.height / 3));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!is_board_terminal(board))
		{
			for (tile in tiles)
			{
				if (FlxG.mouse.overlaps(tile))
				{
					// cool highlight effect
					if (board[tiles.members.indexOf(tile)] == 0)
						tile.visible = false;

					// handle clicking a tile
					if (FlxG.mouse.justPressed)
					{
						place_sprite_on_tile(tile, tiles.members.indexOf(tile));

						// Bot turn - run minimax
						if (!Xturn)
							place_sprite_on_tile(tiles.members[min_board_val(board)[1]], min_board_val(board)[1]);
					}
				}
				else
				{
					tile.visible = true;
				}
			}
		}
		else
		{
			// Show game result screen
			if (!game_over)
			{
				var win_string = check_win(board) == 0 ? "Tie" : check_win(board) == 1 ? "Player wins" : "Bot wins";
				var win_popup = new FlxText(0, 0, FlxG.width, win_string, 64);
				win_popup.setFormat(null, 64, FlxColor.WHITE, FlxTextAlign.CENTER);
				win_popup.screenCenter();

				var play_again_button = new FlxButton(0, 0, "Play again", FlxG.resetState);
				play_again_button.screenCenter();
				play_again_button.y += 70;

				add(win_popup);
				add(play_again_button);

				game_over = true;
			}
		}
	}

	public function place_sprite_on_tile(tile:FlxSprite, index:Int):Void
	{
		// Don't allow placement on used tiles
		if (board[index] != 0)
			return;
		if (Xturn)
		{
			var placedX = X_Sprite.clone();
			placedX.scale.x = 0.2;
			placedX.scale.y = 0.2;
			placedX.updateHitbox();
			placedX.x = tile.x + 18;
			placedX.y = tile.y;

			add(placedX);
			board[index] = 1;
		}
		else
		{
			var placedO = O_Sprite.clone();
			placedO.scale.x = 0.8;
			placedO.scale.y = 0.8;
			placedO.updateHitbox();
			placedO.x = tile.x + 18;
			placedO.y = tile.y;

			add(placedO);
			board[index] = -1;
		}

		// Switch player turn
		Xturn = !Xturn;
		bgColor = (bgColor == FlxColor.fromRGB(255, 0, 0, 20) ? FlxColor.fromRGB(0, 0, 255, 20) : FlxColor.fromRGB(255, 0, 0, 20));

		// remove highlight effect
		tile.visible = true;

		return;
	}

	/** returns 0 on no win, 1 on X win, 2 on O win
			
		*	board[i]
		*	0 3 6
		*	1 4 7
		*	2 5 8

	 */
	public function check_win(board:Array<Int>)
	{
		for (i in 0...3)
		{
			// vertical
			if (board[0 + i * 3] == board[1 + i * 3] && board[1 + i * 3] == board[2 + i * 3] && board[0 + i * 3] != 0)
				return board[0 + i * 3];

			// horizontal
			if (board[0 + i] == board[3 + i] && board[3 + i] == board[6 + i] && board[0 + i] != 0)
				return board[0 + i];
		}

		// diagonal down
		if (board[0] == board[4] && board[4] == board[8] && board[0] != 0)
			return board[0];

		// diagonal up
		if (board[2] == board[4] && board[4] == board[6] && board[2] != 0)
			return board[2];

		return 0;
	}

	/** returns true if someone one or there are no spaces left */
	public function is_board_terminal(board:Array<Int>):Bool
	{
		if (check_win(board) != 0)
			return true;

		var used_space_count = 0;
		for (tile in board)
		{
			if (tile != 0)
				used_space_count += 1;
		}

		if (used_space_count == 9)
		{
			return true;
		}

		return false;
	}

	/**
	 * Helper function that gets max between two floats
	 * @param a : A Float
	 * @param b : A Float
	 */
	public function max(a:Int, b:Int)
	{
		return a > b ? a : b;
	}

	/**
	 * Helper function that gets min between two floats
	 * @param a : A Float
	 * @param b : A Float
	 */
	public function min(a:Int, b:Int)
	{
		return a < b ? a : b;
	}

	/**
	 * Minimax max segment
	 * @param board : The game board
	 */
	public function max_board_val(board:Array<Int>):Array<Int>
	{
		if (is_board_terminal(board))
			return [check_win(board), -1];

		var max_val = -1;
		var best_move = -1;
		for (i in 0...board.length)
		{
			if (board[i] == 0)
			{
				var newBoard = board.copy();
				newBoard[i] = 1;
				var min_ret = min_board_val(newBoard)[0];
				if (min_ret >= max_val)
				{
					max_val = min_ret;
					best_move = i;
				}
			}
		}
		return [max_val, best_move];
	}

	/**
	 * Minimax min segment
	 * @param board : The game board
	 */
	public function min_board_val(board):Array<Int>
	{
		if (is_board_terminal(board))
			return [check_win(board), -1];

		var min_val = 1;
		var best_move = -1;
		for (i in 0...board.length)
		{
			if (board[i] == 0)
			{
				var newBoard = board.copy();
				newBoard[i] = -1;
				var max_ret = max_board_val(newBoard)[0];
				if (max_ret <= min_val)
				{
					min_val = max_ret;
					best_move = i;
				}
			}
		}
		return [min_val, best_move];
	}
}
