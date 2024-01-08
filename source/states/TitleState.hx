package states;

import flixel.FlxState;
import openfl.display.MEMORY;
import openfl.ui.MouseCursor;
import backend.WeekData;
import backend.Highscore;
import objects.Notification;
import sys.io.File;
import lime.app.Application;
import openfl.system.System;

import flixel.ui.FlxButton;
import flixel.math.FlxPoint;

import shaders.ColorSwap;

import flixel.tweens.misc.ColorTween;
import flixel.input.keyboard.FlxKey;

import openfl.display.MEMORY;
//
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import tjson.TJSON as Json;

import flixel.effects.FlxFlicker;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import flixel.input.mouse.FlxMouse;

import substates.Prompt;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;
//import openfl.display.Internet;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

typedef TitleData =
{

	titlex:Float,
	titley:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public var ignoreWarnings:Bool = false;

	var selected:Bool = false;

	public var notSkip:Bool = false;

	public static var urlUpdate:String = '';

	var textTitle:String;

	//var timetran:Int = ClientPrefs.data.timeTransaction;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var phantomSr:FlxSprite;

	var saturated:ColorSwap;

	var titleTxt:FlxText;
	var titleTxt2:FlxText;

	var TextMove:FlxTimer;
	
	var textShow:String;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var curThonny:Array<String> = [];

	public static var editorresult:Bool;

	var wackyImage:FlxSprite;

	#if TITLE_SCREEN_EASTER_EGG
	var easterEggKeys:Array<String> = [
		'SHADOW', 'RIVER', 'SHUBS', 'BBPANZU'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	//var mustUpdate:Bool = false;
	public static var UpdateEC:Bool = false;

	//public static var fpsalpha:Float = 0;

	var TitleTxt:String;
	var coolText:FlxText;

	var titleJSON:TitleData;
	var Bit:Bool;

	var indexCurret:Int = 0;

	public static var updateVersion:String = '';
	public static var updateVersionEC:String = '';
	public static var editorverification:String = 'disabled';
	public static var editorpermiss:String = '';
	public static var releasevideolink:String = '';
	public static var pathVersionOnline:String = '';
	public static var pathVersionOnlineM:Bool = true;

//	public var BitLogo:FlxTimer;

	public function onAlpha(Timer:FlxTimer):Void {
		FlxTween.tween(logoBl, {"scale.x": 1, "scale.y": 1}, 0.1, {
			onComplete: function (twn:FlxTween) {
				FlxTween.tween(logoBl, {"scale.x": 0.9, "scale.y": 0.9}, 0.1);
		}});
	}

	public function onText(Timer:FlxTimer):Void {
		FlxTween.tween(titleTxt, {alpha: 0}, 2, {
			onComplete: function (twn:FlxTween) {
				FlxTween.tween(titleTxt, {alpha: 1}, 2);
			}
		});
	}

	function onGenerate(Timer:FlxTimer):Void {
        if (indexCurret < textShow.length) {
            titleTxt.text += textShow.charAt(indexCurret);
            indexCurret++;
        }
    }

	override public function create():Void
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		ClientPrefs.loadPrefs();

		#if desktop
		if (ClientPrefs.data.Welcome == true) {
			trace('cheking for release video');
			var htss = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/Link_video.txt");

			htss.onData = function (data:String)
				{
					releasevideolink = data.split("*")[0].trim();
					trace("Video Saved: [" + releasevideolink + "]");
				}

				htss.onError = function (error) {
					trace('error: $error');
					trace('Release Video. Cargara el Guardado en El juego');
					releasevideolink = "https://www.youtube.com/watch?v=M67O8wIE-2U";
				}

				htss.request();
		}

		if (ClientPrefs.data.Welcome) {
			trace('cheking for Path Version');
			var hpss = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/pathVersion.txt");

			hpss.onData = function (data:String)
				{
					pathVersionOnline = data.split("*")[0].trim();
					trace("Path Version: [" + pathVersionOnline + "]");

					if (pathVersionOnline != MainMenuState.pathVersion) {
						pathVersionOnlineM = true;
					}
				}

				hpss.onError = function (error) {
					trace('error: $error');
					trace('Paths Version Error. No cargara la desactualizacion');
					pathVersionOnlineM = false;
				}

				hpss.request();
		}

		if (ClientPrefs.data.Welcome == true) {
			trace('cheking for editors permiss');
			var htsp = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/Editor-Permiss.txt");

			htsp.onData = function (data:String)
				{
					editorpermiss = data.split("!")[0].trim();
					var curVerificator:String = editorverification.trim();
					trace('Editor Permiss Online is in  [' + editorpermiss + "]");
					if (editorpermiss != curVerificator) {
						trace('enabled!!');
						editorresult = true;
					}
					if (editorpermiss == curVerificator) {
						trace('disabled!!');
						editorresult = false;
					}
				}

				htsp.onError = function (error) {
					trace('error: $error');
					trace('Editor Permiss. Desabilitado por seguridad');
					editorresult = false;
				}

				htsp.request();
		}

		if(ClientPrefs.data.Welcome == true) {
			trace('checking for update');
			var htps = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/GitVersion.txt");

			htps.onData = function (data:String)
			{
				updateVersionEC = data.split('\n')[0].trim();
				var curVersionEC:String = MainMenuState.endingcorruptionVersion.trim();
				trace('version online: ' + updateVersionEC + ', your version: ' + curVersionEC);
				if(updateVersionEC != curVersionEC) {
					trace('versions arebt matching!');
					UpdateEC = true;
				}
			}

			htps.onError = function (error) {
				trace('error: $error');
			}

			htps.request();
		}
		#end

		Highscore.load();

		if(ClientPrefs.data.Welcome == false) MusicBeatState.switchState(new PreloadingState());

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = true;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		#end
	}

	var logoBl:FlxSprite;
	var swagShader:ColorSwap = null;
	var FadeTimer:FlxTimer;
	var TextTime:FlxTimer;
	var errorTimer:FlxTimer;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				if (ClientPrefs.data.musicState != 'disabled') {
				FlxG.sound.playMusic(Paths.music('Hallucination'), 1.2);
			}
		}
			if(Main.memoryVar != null && !ClientPrefs.data.noneAnimations) {
				FlxTween.tween(Main.memoryVar, {x: 10}, 3);
				FlxTween.tween(Main.memoryVar, {alpha: 1}, 2.5);
			}
			if(Main.coinVar != null && !ClientPrefs.data.noneAnimations) {
				FlxTween.tween(Main.coinVar, {x: 10}, 3);
				FlxTween.tween(Main.coinVar, {alpha: 1}, 2.5);
			}
			if(Main.fpsVar != null && !ClientPrefs.data.noneAnimations) {
				FlxTween.tween(Main.fpsVar, {x: 10}, 3);
				FlxTween.tween(Main.fpsVar, {alpha: 1}, 2.5);
			}
			Main.memoryVar.visible = ClientPrefs.data.showFPS;
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
			Main.coinVar.visible = ClientPrefs.data.showFPS;
	}

		//Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		var bg:FlxSprite;
		//bg.antialiasing = ClientPrefs.data.antialiasing; //Esto es inecesario ya que creo una imagen de Color Negro no veo que tengo que suavizar
		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var tweens:ColorTween;

		logoBl = new FlxSprite().loadGraphic(Paths.image('corruption-logo'));
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.updateHitbox();
		logoBl.screenCenter();
		logoBl.alpha = 1;
		logoBl.scale.x = 0.9;
		logoBl.scale.y = 0.9;

		if (ClientPrefs.data.language == 'Spanish') {
			titleTxt = new FlxText(0, 650, FlxG.width, 48);
			textShow = "Presiona 'Enter' para Continuar";
		}
		if (ClientPrefs.data.language == 'Inglish') {
			titleTxt = new FlxText(0, 650, FlxG.width, 48);
			textShow = "Press 'Enter' to Continue";
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			titleTxt = new FlxText(0, 650, FlxG.width, 48);
			textShow = "Pressione 'Enter' para Continuar";
		}
		titleTxt.setFormat(Paths.font("vnd.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.visible = true;
		titleTxt.screenCenter(X);


		titleTxt2 = new FlxText(0, 650, FlxG.width, "", 48);
		titleTxt2.setFormat(Paths.font("vnd.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt2.visible = false;
		titleTxt2.screenCenter(X);

		if (ClientPrefs.data.language == 'Spanish') titleTxt2.text = "Iniciando";

		if (ClientPrefs.data.language == 'Inglish') titleTxt2.text = "Starting";

		if (ClientPrefs.data.language == 'Portuguese') titleTxt2.text = "Iniciando";

		var clientSettings:String = ClientPrefs.data.graphics_internal;

		if (clientSettings == 'Low') {
			ClientPrefs.data.antialiasing = false;
			ClientPrefs.data.lowQuality = true;
			ClientPrefs.data.framerate = 60;
			ClientPrefs.data.recordoptimization = "enabled";
			ClientPrefs.data.shaders = false;
			ClientPrefs.data.SpritesFPS = 16;
			ClientPrefs.data.alphahud = true;
		}
		if (clientSettings == 'Medium') {
			ClientPrefs.data.antialiasing = false;
			ClientPrefs.data.lowQuality = true;
			ClientPrefs.data.framerate = 75;
			ClientPrefs.data.recordoptimization = "Disabled";
			ClientPrefs.data.shaders = false;
			ClientPrefs.data.SpritesFPS = 24;
		}
		if (clientSettings == 'High') {
			ClientPrefs.data.antialiasing = true;
			ClientPrefs.data.lowQuality = false;
			ClientPrefs.data.framerate = 85;
			ClientPrefs.data.recordoptimization = "Disabled";
			ClientPrefs.data.shaders = true;
			ClientPrefs.data.SpritesFPS = 24;
		}
		if (clientSettings == 'Ultra') {
			ClientPrefs.data.antialiasing = true;
			ClientPrefs.data.lowQuality = false;
			ClientPrefs.data.framerate = 100;
			ClientPrefs.data.recordoptimization = "Disabled";
			ClientPrefs.data.shaders = true;
			ClientPrefs.data.SpritesFPS = 32;
			ClientPrefs.data.alphahud = true;
		}

		//add(gfDance);
		add(logoBl);
		add(titleTxt);
		add(titleTxt2);

		if(swagShader != null)
		{
			logoBl.shader = swagShader.shader;
		}

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();

		new ColorSwap();

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		phantomSr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('phantom_fear_logo'));
		add(phantomSr);
		phantomSr.visible = false;
		phantomSr.setGraphicSize(Std.int(phantomSr.width * 0.8));
		phantomSr.updateHitbox();
		phantomSr.screenCenter(X);
		phantomSr.antialiasing = ClientPrefs.data.antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		if (!ClientPrefs.data.noneAnimations) {
			FadeTimer = new FlxTimer();
			FadeTimer.start(0.8, onAlpha, 0);
		}

		if (!ClientPrefs.data.noneAnimations) {
			TextTime = new FlxTimer();
			TextTime.start(4, onText, 0);
		}
		if (ClientPrefs.data.noneAnimations) {
			titleTxt.alpha = 1;
		}

		trace('Total Memory: ' + System.totalMemory + " bytes");

		if (System.totalMemory < 2000000) {
			MusicBeatState.notiWindows("Tu Dispositivo no cumple con los requisitos limite. tu memoria no es superior a 2GBs", "Incompatible");
		}

			errorTimer = new FlxTimer();
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getPreloadPath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	var noModsSine:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.Y) {
			MusicBeatState.notiWindows("No encontramos el archivo [ttRead.dll] porfavor contacte a soporte tecnico", "ERR:20T");
			FlxG.sound.play(Paths.sound('confirmMenu'));
			openSubState(new options.PluginSubState());
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		if (!ClientPrefs.data.noneFixeds) {
		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle) {
			pressedEnter = true;
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (!ClientPrefs.data.noneFixeds) {
		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
	}
}

		if (initialized  && skippedIntro)
		{
			if(pressedEnter && selected == false)
			{
				titleTxt.visible = false;
				titleTxt2.visible = true;
				selected = true;

					FlxG.sound.play(Paths.sound('confirmMenu'), 0.2);

					transitioning = true;

					FlxG.cameras.fade(FlxColor.BLACK, ClientPrefs.data.timetrans + 2, false);
					FlxTween.tween(titleTxt2, {alpha: 0}, ClientPrefs.data.timetrans + 3);
					FlxFlicker.flicker(titleTxt2, ClientPrefs.data.timetrans + 3, 0.2, true, true);
					if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(ClientPrefs.data.timetrans, 1);
					FlxTween.tween(logoBl, {alpha: 0}, ClientPrefs.data.timetrans + 2, {
						onComplete: function (twn:FlxTween) {
	
							new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									if (UpdateEC == true) {
										MainMenuState.outdate = false;
									}
										MusicBeatState.switchState(new MainMenuState());
										//MusicBeatState.switchState(new ActAvailableState());
									closedState = true;
								});
						}
					});
			}
		}

		if (initialized && pressedEnter)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		ClientPrefs.loadPrefs();

		ClientPrefs.saveSettings();

		super.update(elapsed);
	}

	function addMoreText(text:String, ?offset:Float = 0, ?Color:FlxColor = FlxColor.BLACK)
	{
		if(textGroup != null && credGroup != null) {

			coolText = new FlxText(0, 0, 0, text, 64);
			coolText.screenCenter(X);
			coolText.setFormat("vcx.ttf", 64, Color, CENTER, OUTLINE_FAST, FlxColor.WHITE);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		FlxTween.tween(coolText, {alpha: 0}, 0.1, {
			onComplete: function (twn:FlxTween) {
				while (textGroup.members.length > 0)
					{
								credGroup.remove(textGroup.members[0], true);
								textGroup.remove(textGroup.members[0], true);
					}
			}
		});
	}

	private var sickBeats:Int = 1; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(!closedState) {
			if (notSkip == false) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
				if (ClientPrefs.data.musicState != 'disabled') {
					FlxG.sound.playMusic(Paths.music('Hallucination'), 0);
				}
				if (ClientPrefs.data.musicState != 'disabled')	FlxG.sound.music.fadeIn(2, 0, 1.2);
				case 2:
					addMoreText('Friday');
				case 3:
					addMoreText('Night');
				case 4:
					addMoreText('Funkin');
				case 5:
					deleteCoolText();
				case 6:
					addMoreText('Ending');
				case 7:
					addMoreText('Corruption');
				case 8:
					addMoreText(MainMenuState.endingcorruptionVersion, 0, FlxColor.RED);
				case 9:
					deleteCoolText();
				case 10:
					FlxG.cameras.fade(FlxColor.BLACK, 0.4, true);
					skipIntro();
			}
		}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.cameras.flash(FlxColor.BLACK, 2.5);
				remove(phantomSr);
				remove(credGroup);
			if (ClientPrefs.data.recordoptimization == 'enabled') add(new Notification('Optimizacion de Grabacion..', "la optimizacio de Grabacion se encuentra Activada Actualmente", 0, null, 1));
			skippedIntro = true;
			notSkip = true;

			TextMove = new FlxTimer();
			TextMove.start(0.09, onGenerate, 0);
		}
	}
}
