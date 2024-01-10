package states.stages;

import backend.StageData;
import states.stages.objects.*;

class Limo1 extends BaseStage
{
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var fastCarCanDrive:Bool = true;

	// event
	var bgLimo2:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var dancersDiff:Float = 320;
	var changespeed:FlxTimer;

	var skyBG:BGSprite;
	var skyBG2:BGSprite;
	var limo2:BGSprite;
	var limo:BGSprite;

	public function onMovimentspeed(Timer:FlxTimer)
		{
			if (bgLimo2.visible == true)  {
				FlxTween.tween(bgLimo2, {x: bgLimo2.x - 120}, 3, {
					onComplete: function (twn:FlxTween) {
						FlxTween.tween(bgLimo2, {x: bgLimo2.x + 120}, 3, {
							onComplete: function (twn:FlxTween) {
								FlxTween.tween(bgLimo2, {x: bgLimo2.x + 120}, 3, {
									onComplete: function (twn:FlxTween) {
										FlxTween.tween(bgLimo2, {x: bgLimo2.x - 120}, 3);
									}
								});
							}
						});
					}
				});
			}

			if (bgLimo2.visible == false)  {
			FlxTween.tween(bgLimo, {x: bgLimo.x - 120}, 3, {
				onComplete: function (twn:FlxTween) {
					FlxTween.tween(bgLimo, {x: bgLimo.x + 120}, 3, {
						onComplete: function (twn:FlxTween) {
							FlxTween.tween(bgLimo, {x: bgLimo.x + 120}, 3, {
								onComplete: function (twn:FlxTween) {
									FlxTween.tween(bgLimo, {x: bgLimo.x - 120}, 3);
								}
							});
						}
					});
				}
			});
		}
		}

	override function create()
	{
		skyBG = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
		skyBG.visible = true;
		add(skyBG);

		skyBG2 = new BGSprite('limo/limoSunset-2', -120, -50, 0.1, 0.1);
		skyBG2.visible = false;
		add(skyBG2);

		bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
		bgLimo.visible = true;
		add(bgLimo);
		bgLimo2 = new BGSprite('limo/bgLimo-2', -120, 480, 0.4, 0.4, ['background limo pink'], true);
		bgLimo2.visible = false;
		add(bgLimo2);

		changespeed = new FlxTimer();
		changespeed.start(15, onMovimentspeed, 0);
	}
	override function createPost()
	{
		limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
		limo.visible = true;
		addBehindGF(limo); //Shitty layering but whatev it works LOL
		limo2 = new BGSprite('limo/limoDrive-2', -120, 550, 1, 1, ['Limo stage'], true);
		limo2.visible = false;
		addBehindGF(limo2);
	}

	override function eventPushed(event:objects.Note.EventNote)
		{
			switch(event.event)
			{
				case "change stage":

			}
		}

	var limoSpeed:Float = 0;
	override function update(elapsed:Float)
	{
		if(!ClientPrefs.data.lowQuality) {
			grpLimoParticles.forEach(function(spr:BGSprite) {
				if(spr.animation.curAnim.finished) {
					spr.kill();
					grpLimoParticles.remove(spr, true);
					spr.destroy();
				}
			});
		}
	}


	override function beatHit()
	{
		if(!ClientPrefs.data.lowQuality) {
			grpLimoDancers.forEach(function(dancer:BackgroundDancer)
			{
				dancer.dance();
			});
		}

		//if (FlxG.random.bool(10) && fastCarCanDrive)
		//	fastCarDrive();
	}
	
	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			if(carTimer != null) carTimer.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			if(carTimer != null) carTimer.active = false;
		}
	}

	/*override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Kill Henchmen":
				killHenchmen();
		}
	}*/

	function dancersParenting()
	{
		var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
		for (i in 0...dancers.length) {
			dancers[i].x = (370 * i) + dancersDiff + bgLimo.x;
		}
	}
	
	function resetLimoKill():Void
	{
		limoMetalPole.x = -500;
		limoMetalPole.visible = false;
		limoLight.x = -500;
		limoLight.visible = false;
		limoCorpse.x = -500;
		limoCorpse.visible = false;
		limoCorpseTwo.x = -500;
		limoCorpseTwo.visible = false;
	}

	/*function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}*/

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		////FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			//resetFastCar();
			carTimer = null;
		});
	}
}