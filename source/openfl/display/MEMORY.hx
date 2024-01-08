package openfl.display;

import states.MainMenuState;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import backend.Controls;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class MEMORY extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	public static var fullMemory:Float = 0;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("vcx", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

        if(FlxG.mouse.justPressed || FlxG.mouse.justPressedRight || FlxG.mouse.justPressedMiddle) {
			FlxG.sound.play(Paths.sound('click'), 1);
        }

		if (PlayState.stageUI == "pixel") {
			defaultTextFormat = new TextFormat("pixel.otf", 8);
		}
		if (PlayState.stageUI != "pixel") {
			defaultTextFormat = new TextFormat("", 14);
		}

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;

			var memoryMegas:Float = 0;

			#if openfl
			fullMemory = Math.abs(FlxMath.roundDecimal(System.totalMemory, 1));
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			if (ClientPrefs.data.moredebug == false) text = "              [" + memoryMegas + "]MBs";

			if (ClientPrefs.data.moredebug == true) text = "              [" + memoryMegas + "]MBs  [" + ClientPrefs.data.width + "] x [" + ClientPrefs.data.height + "] [" + FlxG.random.float(0.00001, 67535674) + "] KBs";
			#end

			textColor = 0xFFFFFFFF;
			if (memoryMegas > 3000)
			{
				textColor = 0xFFFF0000;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";

		cacheCount = currentCount;
	}
}
