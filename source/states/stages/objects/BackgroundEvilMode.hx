package states.stages.objects;

class BackgroundEvilMode extends FlxSprite
{
	var isPissed:Bool = true;
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		antialiasing = false;
		swapDanceType();

		setGraphicSize(Std.int(width * PlayState.daPixelZoom), Std.int(height * PlayState.daPixelZoom));
		updateHitbox();
		animation.play('Not');
	}

	var danceDir:Bool = false;

	public function swapDanceType():Void
	{
		isPissed = !isPissed;
		if(!isPissed) { //Gets unpissed
			animation.addByIndices('Not', 'background', CoolUtil.numberArray(41,40), "", 24, true);
		} else { //Pisses
			animation.addByIndices('Yes', 'background', CoolUtil.numberArray(39, 0), "", 24, true);
		}
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('Yes', true);
		else
			animation.play('Not', true);
	}
}