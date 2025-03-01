package states;

import backend.WeekData;
import backend.Highscore;
import backend.AndroidDialogsExtend;

import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import tjson.TJSON as Json;
import lime.system.System;

import flixel.effects.FlxFlicker;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.utils.Assets;

import shaders.ColorSwap;
import shaders.ColorblindFilter;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

import backend.VideoHandler_Title;


typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public static var initialized:Bool = false;
	public static var inGame:Bool = false;
	public static var introfaded:Bool = false;
	
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	
	var skipVideo:FlxText;

	var textShow:String;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	#if TITLE_SCREEN_EASTER_EGG
	var easterEggKeys:Array<String> = [
		'SHADOW', 'RIVER', 'SHUBS', 'BBPANZU'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	var mustUpdate:Bool = false;
    
    public static var checkOpenFirst:Bool = false;
    
	var titleJSON:TitleData;

	public static var updateVersion:String = '';
	

	var indexCurret:Int = 0;

	public static var bpm:Float = 0;
    
    var lang:String = '';

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
		//titleTxt.text = textShow;
    }
    
	override public function create():Void
	{
		if(checkOpenFirst){
    		Paths.clearStoredMemory();
    		Paths.clearUnusedMemory();
		}
		
		Lib.application.window.title = " NF - Engine - Title";
		
		//https://github.com/beihu235/AndroidDialogs
		
		#if android
		/*
		if (lime.app.Application.current.meta.get('title') != "Friday Night Funkin' NF Engine"
		 || lime.app.Application.current.meta.get("packageName") != "com.NFengine"
		 || lime.app.Application.current.meta.get("package") != "com.NFengine"
		 || lime.app.Application.current.meta.get("version") != '1.1.0'
		){
		    
		    //Sys.exit(1);		
		   // return;
		}
		if (DeviceLanguage.getLang() == 'zh') 
    		lang = '检测到引擎被修改，请使用官方版本' + System.platformVersion;
    		else
    		lang = 'The engine has been modified. Please use the official version';
		    
		    AndroidDialogsExtend.OpenToast(lang,2);
		*/
		if (DeviceLanguage.getLang() == 'zh') 
		lang = '欢迎使用NF引擎\n版本: 1.1.0';
		else
		lang = 'Wellcome to NF Engine\nVersion: 1.1.0';
		#end
			
		if(!checkOpenFirst){
		
		FlxTransitionableState.skipNextTransOut = true;
										
		checkOpenFirst = true;
		
		}
		
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		removeVirtualPad();
		noCheckPress();
		#end

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
        
		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.data.checkForUpdates && !closedState) {
			//trace('checking for update');
			var http = new haxe.Http("https://github.com/beihu235/NF-Engine-new/blob/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				
				if(updateVersion != '1.1.0(beta)') {
				var lang:String = '';
		                if (DeviceLanguage.getLang() == 'zh') 
		                lang = '发现新版本! 请前往作者主页了解略详';
		                else
		                lang = "find new version! press ok toGo to the author's home page for more details";
		                AndroidDialogsExtend.OpenToast(lang,2);
		               // SUtil.applicationAlert('!', 'find new version!');
		                CoolUtil.browserLoad('https://b23.tv/jvrOG5G');
		            
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		#if TITLE_SCREEN_EASTER_EGG
		if (FlxG.save.data.psychDevsEasterEgg == null) FlxG.save.data.psychDevsEasterEgg = ''; //Crash prevention
		switch(FlxG.save.data.psychDevsEasterEgg.toUpperCase())
		{
			case 'SHADOW':
				titleJSON.gfx += 210;
				titleJSON.gfy += 40;
			case 'RIVER':
				titleJSON.gfx += 180;
				titleJSON.gfy += 40;
			case 'SHUBS':
				titleJSON.gfx += 160;
				titleJSON.gfy -= 10;
			case 'BBPANZU':
				titleJSON.gfx += 45;
				titleJSON.gfy += 100;
		}
		#end

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
		
		ColorblindFilter.UpdateColors();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		//FlxG.mouse.visible = true;
		//FlxG.mouse.load(Paths.image('menuExtend/cursor').bitmap,1,0,0);
		
        
        
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			if (initialized)
				startCutscenesIn();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startCutscenesIn();
				});
			}
		}
		#end
		
		
		
		bpm = titleJSON.bpm;
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleTxt:FlxText;
	var titleTxt2:FlxText;
	var swagShader:ColorSwap = null;

	var FadeTimer:FlxTimer;
	var TextTime:FlxTimer;
	
	function startCutscenesIn()
	{
		if (inGame) {
			startIntro();
			return;
		}
		if (!ClientPrefs.data.skipTitleVideo)
			startVideo('menuExtend/titleIntro');
		else
			startCutscenesOut();
	}
	
	function startCutscenesOut()
	{
	    #if android
		AndroidDialogsExtend.OpenToast(lang,2);
		#end
		inGame = true;
		startIntro();
	}
	
	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'), 1.2);

				if (ClientPrefs.data.music == 'Hallucination') FlxG.sound.playMusic(Paths.music('Hallucination'), 1.2);

				if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'), 1.2);
		}
		}

		Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
			bg.visible = false;
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}

		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new FlxSprite().loadGraphic(Paths.image('corruption-logo'));
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.updateHitbox();
		logoBl.screenCenter();
		logoBl.alpha = 1;
		logoBl.scale.x = 0.9;
		logoBl.scale.y = 0.9;

		if(ClientPrefs.data.shaders) swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;

		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		if(easterEgg == null) easterEgg = ''; //html5 fix

		switch(easterEgg.toUpperCase())
		{
			// IGNORE THESE, GO DOWN A BIT
			#if TITLE_SCREEN_EASTER_EGG
			case 'SHADOW':
				gfDance.frames = Paths.getSparrowAtlas('ShadowBump');
				gfDance.animation.addByPrefix('danceLeft', 'Shadow Title Bump', 24);
				gfDance.animation.addByPrefix('danceRight', 'Shadow Title Bump', 24);
			case 'RIVER':
				gfDance.frames = Paths.getSparrowAtlas('RiverBump');
				gfDance.animation.addByIndices('danceLeft', 'River Title Bump', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'River Title Bump', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			case 'SHUBS':
				gfDance.frames = Paths.getSparrowAtlas('ShubBump');
				gfDance.animation.addByPrefix('danceLeft', 'Shubs Title Bump', 24, false);
				gfDance.animation.addByPrefix('danceRight', 'Shubs Title Bump', 24, false);
			case 'BBPANZU':
				gfDance.frames = Paths.getSparrowAtlas('BBBump');
				gfDance.animation.addByIndices('danceLeft', 'BB Title Bump', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'BB Title Bump', [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
			#end

			default:
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
			//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD!!!!
				gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
				gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}

		gfDance.visible = false;
		add(gfDance);
		add(logoBl);
		if(swagShader != null)
		{
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}

		if (ClientPrefs.data.language == 'Spanish') {
			titleTxt = new FlxText(0, 650, FlxG.width, "Presiona la Pantalla para Continuar".toUpperCase(), 48);
		}
		if (ClientPrefs.data.language == 'Inglish') {
			titleTxt = new FlxText(0, 650, FlxG.width, "Press the Screen to Continue".toUpperCase(), 48);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			titleTxt = new FlxText(0, 650, FlxG.width, "Pressione a tela para continuar".toUpperCase(), 48);
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

		add(titleTxt);
		add(titleTxt2);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized) {
			skipIntro();
		} else {
			initialized = true;
		}

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

		if (ClientPrefs.data.username == 'User') {
			ClientPrefs.data.username = 'User' + FlxG.random.int(0, 100) + FlxG.random.int(0, 200);
			ClientPrefs.saveSettings();
			ClientPrefs.loadPrefs();
		}

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
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

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				//titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				//titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				//titleText.color = FlxColor.WHITE;
				//titleText.alpha = 1;
				
				//if(titleText != null) titleText.animation.play('press');

				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				titleTxt.visible = false;

				FlxG.cameras.fade(FlxColor.BLACK, ClientPrefs.data.timetrans + 2, false);
				FlxTween.tween(titleTxt2, {alpha: 0}, ClientPrefs.data.timetrans + 3);
				FlxFlicker.flicker(titleTxt2, ClientPrefs.data.timetrans + 3, 0.2, true, true);
				if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(ClientPrefs.data.timetrans, 1);
				FlxTween.tween(logoBl, {alpha: 0}, ClientPrefs.data.timetrans + 2, {
					onComplete: function (twn:FlxTween) {

						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
									MusicBeatState.switchState(new MainMenuState());
									//MusicBeatState.switchState(new ActAvailableState());
								closedState = true;
							});
					}
				});
			}
			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							//trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('ToggleJingle'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							FlxG.sound.music.fadeOut();
							if(FreeplayState.vocals != null)
							{
								FreeplayState.vocals.fadeOut();
							}
							closedState = true;
							transitioning = true;
							playJingle = true;
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'), 0);
	
					if (ClientPrefs.data.music == 'Hallucination')	FlxG.sound.playMusic(Paths.music('Hallucination'), 0);
	
					if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'), 0);
					
					if (ClientPrefs.data.musicState != 'disabled')	FlxG.sound.music.fadeIn(2, 0, 1.2);
					case 2:
						addMoreText('Ending');
					case 3:
						addMoreText('Corruption');
					case 4:
						addMoreText(ClientPrefs.data.endingcorruption);
					case 5:
						deleteCoolText();
					case 6:
						FlxG.cameras.fade(FlxColor.BLACK, 0.4, true);
						skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (playJingle) //Ignore deez
			{
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch(easteregg)
				{
					case 'RIVER':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHUBS':
						sound = FlxG.sound.play(Paths.sound('JingleShubs'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));

					default: //Go back to normal ugly ass boring GF
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 2);
						skippedIntro = true;
						playJingle = false;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if(easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
					});
				}
				else
				{
					remove(ngSpr);
					remove(credGroup);
					FlxG.camera.flash(FlxColor.WHITE, 3);
					sound.onComplete = function() {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
					};
				}
				playJingle = false;
			}
			else //Default! Edit this one!!
			{
				FlxG.cameras.flash(FlxColor.BLACK, 2.5);
				remove(credGroup);
				if (ClientPrefs.data.recordoptimization == 'enabled') add(new objects.Notification('Optimizacion de Grabacion..', "la optimizacio de Grabacion se encuentra Activada Actualmente", 0, null, 1));

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if(easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
					if(FreeplayState.vocals != null)
					{
						FreeplayState.vocals.fadeOut();
					}
				}
				#end
			}
			skippedIntro = true;
		}
	}
	var video:VideoSprite;
	function startVideo(name:String)
	{
	    skipVideo = new FlxText(0, FlxG.height - 26, 0, "Press " + #if android "Back on your phone " #else "Enter " #end + "to skip", 18);
		skipVideo.setFormat(Assets.getFont("assets/fonts/montserrat.ttf").fontName, 18);
		skipVideo.alpha = 0;
		skipVideo.alignment = CENTER;
        skipVideo.screenCenter(X);
        skipVideo.scrollFactor.set();
		skipVideo.antialiasing = ClientPrefs.data.antialiasing;
		
		
		#if VIDEOS_ALLOWED

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			videoEnd();
			return;
		}
        
        
		var video:VideoSprite = new VideoSprite(0, 0, 1280, 720);
			video.playVideo(filepath);
			add(video);
			video.updateHitbox();
			video.finishCallback = function()
			{
				videoEnd();
				return;
			}
		showText();	
		#else
		FlxG.log.warn('Platform not supported!');
		videoEnd();
		return;
		#end
	}

	function videoEnd()
	{
	    skipVideo.visible = false;
	    //video.visible = false;
		startCutscenesOut();
	}
	
	function showText(){
	    add(skipVideo);
		FlxTween.tween(skipVideo, {alpha: 1}, 1, {ease: FlxEase.quadIn});
		FlxTween.tween(skipVideo, {alpha: 0}, 1, {ease: FlxEase.quadIn, startDelay: 4});
	
	}
}
