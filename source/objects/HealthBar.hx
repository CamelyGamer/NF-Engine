package objects;

import flixel.effects.FlxFlicker;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import flixel.tweens.misc.ColorTween;
import flixel.tweens.FlxTween;

class HealthBar extends FlxSpriteGroup
{
	public var leftBar:FlxSprite;
	public var rightBar:FlxSprite;
	public var bg:FlxSprite;
	public var valueFunction:Void->Float = function() return 0;
	public var percent(default, set):Float = 0;
	public var bounds:Dynamic = {min: 0, max: 1};
	public var leftToRight(default, set):Bool = true;
	public var barCenter(default, null):Float = 0;

	// you might need to change this if you want to use a custom bar
	public var barWidth(default, set):Int = 1;
	public var barHeight(default, set):Int = 1;
	public var barOffset:FlxPoint = new FlxPoint(3, 3);

	public function new(x:Float, y:Float, image:String = 'healthBar', valueFunction:Void->Float = null, boundX:Float = 0, boundY:Float = 1, ?angle:Float)
	{
		super(x, y);
		
		if(valueFunction != null) this.valueFunction = valueFunction;
		setBounds(boundX, boundY);
		
		bg = new FlxSprite(x, y).loadGraphic(Paths.image(image));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		//bg.screenCenter(Y);
		barWidth = Std.int(bg.width - 6);
		barHeight = Std.int(bg.height - 6);

		leftBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height), FlxColor.WHITE);
		//leftBar.color = FlxColor.WHITE;
		leftBar.antialiasing = antialiasing = ClientPrefs.data.antialiasing;

		rightBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height), FlxColor.WHITE);
		rightBar.color = FlxColor.BLACK;
		rightBar.antialiasing = ClientPrefs.data.antialiasing;

		bg.angle = angle;
		leftBar.angle = angle;
		rightBar.angle = angle;

		add(leftBar);
		add(rightBar);
		add(bg);
		regenerateClips();
	}

	override function update(elapsed:Float) {
		var value:Null<Float> = FlxMath.remapToRange(FlxMath.bound(valueFunction(), bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
		percent = (value != null ? value : 0);
		super.update(elapsed);

		if (percent > 65 && leftBar.color == FlxColor.GREEN || percent > 65 && leftBar.color == FlxColor.GRAY) FlxTween.color(leftBar, 1, FlxColor.GREEN, FlxColor.RED);
		if (percent < 65 && leftBar.color == FlxColor.RED || percent < 65 && leftBar.color == FlxColor.GRAY) FlxTween.color(leftBar, 1, FlxColor.RED, FlxColor.GREEN);

		if (percent > 35 && rightBar.color == FlxColor.RED || percent > 35 && rightBar.color == FlxColor.GRAY) FlxTween.color(rightBar, 1, FlxColor.RED, FlxColor.PURPLE);
		if (percent < 35 && rightBar.color == FlxColor.PURPLE || percent < 35 && rightBar.color == FlxColor.GRAY) FlxTween.color(rightBar, 1, FlxColor.PURPLE, FlxColor.RED);
	}
	
	public function setBounds(min:Float, max:Float)
	{
		bounds.min = min;
		bounds.max = max;
	}

	public function setColors(left:FlxColor, right:FlxColor)
	{
		FlxTween.color(leftBar, 1, FlxColor.BLACK, FlxColor.GRAY);
		FlxTween.color(rightBar, 1, FlxColor.BLACK, FlxColor.GRAY);
	}

	public function updateBar()
	{
		if(leftBar == null || rightBar == null) return;
		
		FlxTween.tween(leftBar, {x: bg.x, y: bg.y}, 1);
		FlxTween.tween(rightBar, {x: bg.x, y: bg.y}, 1);

		var leftSize:Float = 0;
		if(leftToRight) leftSize = FlxMath.lerp(0, barWidth, percent / 100);
		else leftSize = FlxMath.lerp(0, barWidth, 1 - percent / 100);

		leftBar.clipRect.width = leftSize;
		leftBar.clipRect.height = barHeight;
		leftBar.clipRect.x = barOffset.x;
		leftBar.clipRect.y = barOffset.y;

		rightBar.clipRect.width = barWidth - leftSize;
		rightBar.clipRect.height = barHeight;
		rightBar.clipRect.x = barOffset.x + leftSize;
		rightBar.clipRect.y = barOffset.y;

		barCenter = leftBar.x + leftSize + barOffset.x;

		// flixel is retarded
		leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;
	}

	public function regenerateClips()
	{
		if(leftBar != null)
		{
			leftBar.setGraphicSize(Std.int(bg.width), Std.int(bg.height));
			leftBar.updateHitbox();
			leftBar.clipRect = new FlxRect(0, 0, Std.int(bg.width), Std.int(bg.height));
		}
		if(rightBar != null)
		{
			rightBar.setGraphicSize(Std.int(bg.width), Std.int(bg.height));
			rightBar.updateHitbox();
			rightBar.clipRect = new FlxRect(0, 0, Std.int(bg.width), Std.int(bg.height));
		}
		updateBar();
	}

	private function set_percent(value:Float)
	{
		var doUpdate:Bool = false;
		if(value != percent) doUpdate = true;
		percent = value;

		if(doUpdate) updateBar();
		return value;
	}

	private function set_leftToRight(value:Bool)
	{
		leftToRight = value;
		updateBar();
		return value;
	}

	private function set_barWidth(value:Int)
	{
		barWidth = value;
		regenerateClips();
		return value;
	}

	private function set_barHeight(value:Int)
	{
		barHeight = value;
		regenerateClips();
		return value;
	}
}