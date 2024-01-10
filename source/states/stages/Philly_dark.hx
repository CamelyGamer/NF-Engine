package states.stages;

import states.stages.objects.*;
import objects.Character;

class Philly_dark extends BaseStage
{
	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:PhillyTrain;
	var curLight:Int = -1;

	var phillyStreetDark:BGSprite;
	var streetBehindDark:BGSprite;
	var cityBack:BGSprite;
	var streetBehind:BGSprite;
	var sky:BGSprite;

	var bg:BGSprite;
	var city:BGSprite;

	//For Philly Glow events
	var blammedLightsBlack:FlxSprite;
	var phillyGlowGradient:PhillyGlowGradient;
	var phillyWindowEvent:BGSprite;
	var curLightEvent:Int = -1;

	override function create()
	{
		bg = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
		add(bg);

		city = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
		city.setGraphicSize(Std.int(city.width * 0.85));
		city.updateHitbox();
		add(city);

		streetBehind = new BGSprite('philly/behindTrain', -40, 50);
		add(streetBehind);

		phillyStreet = new BGSprite('philly/street', -40, 50);
		add(phillyStreet);


		//SPRITES ORIGINALS

		sky = new BGSprite('philly/Original/sky1', -100, 0, 0.1, 0.1);
		sky.visible = false;
		add(sky);

		cityBack = new BGSprite('philly/Original/city1', -10, 0, 0.3, 0.3);
		cityBack.setGraphicSize(Std.int(cityBack.width * 0.85));
		cityBack.updateHitbox();
		cityBack.visible = false;
		add(cityBack);

		streetBehindDark = new BGSprite('philly/Original/behindTrain1', -40, 50);
		streetBehindDark.visible = false;
		add(streetBehindDark);

		phillyStreetDark = new BGSprite('philly/Original/street1', -40, 50);
		phillyStreetDark.visible = false;
		add(phillyStreetDark);
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		switch(event.event)
		{
			case "Philly Glow":
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', 0, 0, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.data.flashing) phillyGlowGradient.intendedAlpha = 0.7;
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "change stage":
				camGame.flash(FlxColor.WHITE, 0.3);

				if (flValue1 == 1) {
				bg.visible = false;
				city.visible = false;
				streetBehind.visible = false;
				phillyStreet.visible = false;
				
				sky.visible = true;
				cityBack.visible = true;
				streetBehindDark.visible = true;
				phillyStreetDark.visible = true;
			}
			if (flValue1 == 0) {
				bg.visible = true;
				city.visible = true;
				streetBehind.visible = true;
				phillyStreet.visible = true;
				
				sky.visible = false;
				cityBack.visible = false;
				streetBehindDark.visible = false;
				phillyStreetDark.visible = false;
			}
			
			case "Change Character":
				if (value2 == 'pico_dark' || value2 == 'bf_dark') {
					camGame.flash(FlxColor.WHITE, 0.2);

					bg.visible = true;
					city.visible = true;
					streetBehind.visible = true;
					phillyStreet.visible = true;
					
					sky.visible = false;
					cityBack.visible = false;
					streetBehindDark.visible = false;
					phillyStreetDark.visible = false;
				}
				if (value2 == 'pico' || value2 == 'bf-origin') {
					camGame.flash(FlxColor.WHITE, 0.2);

					bg.visible = false;
					city.visible = false;
					streetBehind.visible = false;
					phillyStreet.visible = false;
					
					sky.visible = true;
					cityBack.visible = true;
					streetBehindDark.visible = true;
					phillyStreetDark.visible = true;
				}

			case "Philly Glow":
				if(flValue1 == null || flValue1 <= 0) flValue1 = 0;
				var lightId:Int = Math.round(flValue1);

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.data.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.data.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
						}
						else if(ClientPrefs.data.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						//var who = chars;
						if(!ClientPrefs.data.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.data.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
						}
						phillyGlowGradient.bop();
				}
		}
	}

	function doFlash()
	{
		var color:FlxColor = FlxColor.WHITE;
		if(!ClientPrefs.data.flashing) color.alphaFloat = 0.5;

		FlxG.camera.flash(color, 0.15, null, true);
	}
}