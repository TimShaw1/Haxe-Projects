# Sprite Animation
For this project, I created a Player class that extends FlxSprite to handle animation and movement.

### Movement
Movement was done by changing the player velocity using a speed value and an angle value. Handling movement this way prevents diagonal movement from being faster than it should be.

### Animation
Animation was done by packing the textures into a spritesheet and using Flixel's built-in animation tools. 
- When switching directions, the sprite is mirrored.
- The sprite has two states: "idle" and "walk". When idle, the sprite is a still frame. When moving, the sprite has a running animation.

![Sprite-GIF](https://github.com/TimShaw1/Haxe-Projects/assets/70497517/a6d25724-d7bc-4e10-b34d-a917f34b9f4d)
