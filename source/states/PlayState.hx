package states;

// If you want to add your stage to the game, copy states/stages/Template.hx,
// and put your stage code there, then, on PlayState, search for
// "switch (curStage)", and add your stage to that list.

// If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
// "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
// "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
// "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
// "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for

import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Section;
import backend.Rating;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxPoint;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;


import cutscenes.CutsceneHandler;
import cutscenes.DialogueBoxPsych;

import states.StoryMenuState;
import states.FreeplayState;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import substates.PauseSubState;
import substates.GameOverSubstate;
import substates.ResultsScreen;
import substates.GameplayChangersSubstate;

import options.OptionsState;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if VIDEOS_ALLOWED 
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

import objects.Note.EventNote;
import objects.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.FunkinLua;
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if (SScript >= "3.0.0")
import tea.SScript;
#end

//import substates.PauseModeSubState;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuffESPANISH:Array<Dynamic> = [
		['Malisimo', 0.1],
		['Eres Fatal!', 0.2], //From 0% to 19%
		['Horrible', 0.3],
		['Terrible', 0.4], //From 20% to 39%
		['Eres Malo', 0.5], //From 40% to 49%
		['Eh..', 0.6], //From 50% to 59%
		['Algo es Algo', 0.69], //From 60% to 68%
		['Bueno', 0.7], //69%
		['Buenisimo!!', 0.75],
		['Bien', 0.8], //From 70% to 79%
		['Exelente', 0.9], //From 80% to 89%
		['El Mejor', 0.95],
		['Corrupto!!', 1], //From 90% to 99%
		['Malvado!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	public static var ratingStuffINGLISH:Array<Dynamic> = [
		['You are Fatal!', 0.2], //From 0% to 19%
		['Terrible', 0.4], //From 20% to 39%
		['You are bad', 0.5], //From 40% to 49%
		['Eh..', 0.6], //From 50% to 59%
		['Its something', 0.69], //From 60% to 68%
		['Well', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Excellent', 0.9], //From 80% to 89%
		['Corrupt!!', 1], //From 90% to 99%
		['Wicked!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	public static var ratingStuffPORTUGUES:Array<Dynamic> = [
		['Você é Fatal!', 0.2], //From 0% to 19%
		['Terrível', 0.4], //From 20% to 39%
		['Você é ruim', 0.5], //From 40% to 49%
		['Ei..', 0.6], //From 50% to 59%
		['Algo é algo', 0.69], //From 60% to 68%
		['Bem', 0.7], //69%
		['Bom', 0.8], //From 70% to 79%
		['Excelente', 0.9], //From 80% to 89%
		['Corrupto!!', 1], //From 90% to 99%
		['Malvado!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	public var instancesExclude:Array<String> = [];
	#end

	#if LUA_ALLOWED
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;
	public var inst:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 100;
	public var combo:Int = 0;
	
	public static var highestCombo:Int = 0;
	
	public static var rsNoteMs:Array<Float> = [];
    public static var rsNoteTime:Array<Float> = [];
    public static var rsSongLength:Float = 0;
    
    public static var reMarvelouss:Int = 0;
    public static var rsSicks:Int = 0;
	public static var rsGoods:Int = 0;
	public static var rsBads:Int = 0;
	public static var rsShits:Int = 0;
	public static var rsMisses:Int = 0;
	
	public static var rsACC:Float = 0;
    public static var rsScore:Int = 0;
	public static var rsHits:Int = 0;
	
	public static var rsRatingFC:String = '';
    public static var rsRatingName:String = '';
    var rsCheck:Bool = false;
    
    var numItems:FlxTypedGroup<FlxSprite>;
    
    var comboOffsetFix:Array<Array<Int>> = [
        [0, 0], //num0
        [-2, -1], //num1
        [-6, 6], //num2
        [-4, 6], //num3
        [-2, 9], //num4
        [-12, 12], //num5
        [-11, 8],  //num6
        [1, -2], //num7
        [2, -2], //num8
        [1, -1] //num9
    ];
    
    var notesHitArray:Array<Date> = [];
    var nps:Int = 0;
	var maxNPS:Int = 0;
	var npsCheck:Int = 0;
	
	public var healthBar:Bar;
	public var timeBar:Bar;
	var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = Rating.loadDefault();
	

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	
	public var guitarHeroSustains:Bool = false;
	
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var cpuControlled_opponent:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camHD:FlxCamera;
	public var camNotes:FlxCamera;
	public var camVIP:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var judgementCounter_S:FlxText; //add _S is make sure nobody make a new one broken this
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	
	//Achievement shit
	var keysPressed:Array<Int> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;
    
	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	#if LUA_ALLOWED
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;

	public var precacheList:Map<String, String> = new Map<String, String>();
	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	//TGames Code
		//FIXED
		public static var statusGame:Bool = false;

		public var overlay:FlxSprite;
		public var overlayLoost:FlxSprite;

			//Estadisticas Variables
	public static var hitnotesong:Float;
	public static var missNotesong:Float;
	public static var deaths:Float;
	public static var scoresTotal:Float;
	public static var heyanim:Float;
	public static var pointsWin:Int;

	public var tipControls:FlxText;

	//Experiments
	public static var blackMode:FlxSprite;
	public static var signal:FlxSprite;
	public var transBlack:FlxSprite;
	public var hpBar:HealthBar;
	public var hptext:FlxText;
	public var hpExtra:HealthBar;
	public var hp2:Float = 0;

	public var doge:Bool = false;

	public var difficultysong:String = Difficulty.getString().toUpperCase();

    public var vineta:FlxSprite;

	public var mode:Bool;

	var ModeLimite:Float = 0.7;

	var isDad:Bool;
	var isBF:Bool;

	var mode1:String;
	var mode2:String;
	var TxtScore:String;

	public var colorNum:FlxColor;

	public var statusFade:Bool;
	public var notitext:String = '';

	public var modes1:Bool;
	public var modes2:Bool;

	//Misiones
	public var status1:Bool = false;
	public var status2:Bool = false;
	public var status3:Bool = false;
	public var status4:Bool = false;
	public var status5:Bool = false;

	public var FadeTime:FlxTimer;

	public var failNoti:String = '';

	public var healthTxt:FlxText;

	public function onDodge(Timer:FlxTimer):Void
		{
			doge = false;
		}

	public function onPress(Timer:FlxTimer):Void
		{
			if(ClientPrefs.data.scoreZoom && !cpuControlled)
				{
					camGame.zoom += 0.015 * camZoomingMult;
					camHUD.zoom += 0.03 * camZoomingMult;
		
					hitnotesong += 1;
		
					if(scoreTxtTween != null) {
						scoreTxtTween.cancel();
					}
					//FlxG.camera.zoom = 1.075;
					scoreTxt.scale.x = 1.075;
					scoreTxt.scale.y = 1.075;
					scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
						onComplete: function(twn:FlxTween) {
							scoreTxtTween = null;
						}
					});
				}
		}

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		startCallback = startCountdown;
		endCallback = endSong;
        
		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');
		

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');
        cpuControlled_opponent = ClientPrefs.getGameplaySetting('botplay');
        guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;
        if (ClientPrefs.data.playOpponent) cpuControlled = ClientPrefs.data.botOpponentFix;
        
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		if (ClientPrefs.data.concetration == true) {
		camHD = new FlxCamera();
		camNotes = new FlxCamera();
		}
		camOther = new FlxCamera();
		camVIP = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		if (ClientPrefs.data.concetration == true) {
		camNotes.bgColor.alpha = 0;
		camHD.bgColor.alpha = 0;
		}
		camVIP.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		if (ClientPrefs.data.concetration == true) {
		FlxG.cameras.add(camHD, false);
		FlxG.cameras.add(camNotes, false);
		}
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camVIP, false);

		
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;
		
		#if android
		addAndroidControls();
		MusicBeatState.androidc.visible = true;
		MusicBeatState.androidc.alpha = 0.000001;
		
		#end

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if desktop
		storyDifficultyText = Difficulty.getString();

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1) {
			SONG.stage = StageData.vanillaSongStage(songName);
		}
		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else {
			if (stageData.isPixelStage)
				stageUI = "pixel";
		}
		
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		
		highestCombo = 0;
		rsNoteMs = [];
		rsNoteTime = [];		
		
		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': new states.stages.StageWeek1(); //Week 1
			case 'philly': new states.stages.Philly(); //Week 3
			case 'philly2': new states.stages.Philly_Day2(); //Week 3 //Day 2
			case 'philly3': new states.stages.Philly_Day3(); //Week 3 //Day 3
			case 'school': new states.stages.School(); //Week 6 - Senpai, Roses
			case 'limo': new states.stages.Limo(); //Week 4 - Mom
			case 'limo2': new states.stages.Limo1(); //Week 4 - Mom - Memory
			case 'spooky': new states.stages.Spooky(); //Week 3 - Spookys
			case 'philly_dark': new states.stages.Philly_dark(); //SONG SECRET - VS PICO
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getPreloadPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
			}
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		startLuasNamed('stages/' + curStage + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + curStage + '.hx');
		#end

		if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion, false);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterScripts(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2, false);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterScripts(dad.curCharacter);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterScripts(boyfriend.curCharacter);

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		stagesFunc(function(stage:BaseStage) stage.createPost());

		if (ClientPrefs.data.concetration == true) {
			if (ClientPrefs.data.language == 'Spanish') mode1 = 'ACTIVADO';
			if (ClientPrefs.data.language == 'Inglish') mode1 = 'ACTIVATED';
			if (ClientPrefs.data.language == 'Portuguese') mode1 = 'ATIVADO';
		  }
	  if (ClientPrefs.data.concetration == false) {
			if (ClientPrefs.data.language == 'Spanish') mode1 = 'DESACTIVADO';
			if (ClientPrefs.data.language == 'Inglish') mode1 = 'DISABLED';
			if (ClientPrefs.data.language == 'Portuguese') mode1 = 'DESATIVADO';
		  }

	  if (ClientPrefs.data.alphahud == true) {
			if (ClientPrefs.data.language == 'Spanish') mode2 = 'ACTIVADO';
			if (ClientPrefs.data.language == 'Inglish') mode2 = 'ACTIVATED';
			if (ClientPrefs.data.language == 'Portuguese') mode2 = 'ATIVADO';
	  }
	  if (ClientPrefs.data.alphahud == false) { 
		   if (ClientPrefs.data.language == 'Spanish') mode2 = 'DESACTIVADO';
		   if (ClientPrefs.data.language == 'Inglish') mode2 = 'DISABLED';
		   if (ClientPrefs.data.language == 'Portuguese') mode2 = 'DESATIVADO';
		  }
		
		
		
		
		comboGroup = new FlxSpriteGroup();
		add(comboGroup);
		cachePopUpScore();
		
		uiGroup = new FlxSpriteGroup();
		add(uiGroup);
		
		noteGroup = new FlxTypedGroup<FlxBasic>();
		add(noteGroup);

		blackMode = new FlxSprite().makeGraphic(FlxG.width + 200, FlxG.height + 200, FlxColor.BLACK);
		blackMode.alpha = 1;
		add(blackMode);

		Conductor.songPosition = -5000 / Conductor.songPosition;
		var showTime:Bool = (ClientPrefs.data.timeBarType == 'Song Name');
		timeTxt = new FlxText(0, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.screenCenter();
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', function() return songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = false;
		uiGroup.add(timeBar);
		//uiGroup.add(timeTxt);
		add(timeTxt);
		
		healthBar = new Bar(0, 0, 'healthBar', function() return health, 0, 100, 90);
		healthBar.screenCenter(Y);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = 0;
		reloadHealthBarColors();
		//healthBar.setBounds(3, 6);

		add(healthBar);
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = false;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = false;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP2);

		scoreTxt = new FlxText(0, 0, FlxG.width, "", 32);
		scoreTxt.setFormat(Paths.font("miss.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.antialiasing = ClientPrefs.data.antialiasing;
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		scoreTxt.alpha = 0;
		add(scoreTxt);
		FlxTween.tween(scoreTxt, {alpha: 1}, 8);
		
		var marvelousRate:String = ClientPrefs.data.marvelousRating ? 'NOT FOUND\n' : '';
		judgementCounter_S = new FlxText(10, 0, 0, "", 20);
		judgementCounter_S.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter_S.borderSize = 1.5;
		judgementCounter_S.borderQuality = 2;
		judgementCounter_S.scrollFactor.set();
		judgementCounter_S.cameras = [camHUD];
		judgementCounter_S.text = 'NOT FOUND';
		judgementCounter_S.visible = (ClientPrefs.data.judgementCounter && !ClientPrefs.data.hideHud && !ClientPrefs.getGameplaySetting('botplay'));		
		judgementCounter_S.cameras = [camHUD];
		add(judgementCounter_S);
		judgementCounter_S.y = FlxG.height / 2 - judgementCounter_S.height / 2;


		if (ClientPrefs.data.overlays == true) {
			overlay = new FlxSprite(0, 0).loadGraphic(Paths.image('Overlays/GR23'));
			overlay.screenCenter();
			overlay.scrollFactor.set();
			overlay.height = FlxG.height;
			overlay.width = FlxG.width;
			overlay.antialiasing = ClientPrefs.data.antialiasing;
			overlay.visible = ClientPrefs.data.overlays;
			overlay.alpha = 0;
			}
			
			if (ClientPrefs.data.overlays == true) {
				overlayLoost = new FlxSprite(0, 0).loadGraphic(Paths.image('Overlays/NBG54'));
				overlayLoost.screenCenter();
				overlayLoost.scrollFactor.set();
				overlayLoost.height = FlxG.height;
				overlayLoost.width = FlxG.width;
				overlayLoost.antialiasing = ClientPrefs.data.antialiasing;
				overlayLoost.alpha = 0;
			}

			if (ClientPrefs.data.overlays == true) add(overlay);
			if  (ClientPrefs.data.overlays == true) add(overlayLoost);

			tipControls = new FlxText(-400, 0, 0,
				"MODO CONCENTRACION: \n\n[" + mode1 + "]" + 
				"\n\nEFECTO HUD: \n\n[" + mode2 + "]",
				24);
		   tipControls.setFormat("vcx.ttf", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		   tipControls.alpha = 0;
		   tipControls.screenCenter(Y);
		   tipControls.scrollFactor.set();
		   tipControls.antialiasing = ClientPrefs.data.antialiasing;
		   tipControls.camera = camOther;
		   add(tipControls);
		
		
		
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		noteGroup.add(strumLineNotes);
		
		botplayTxt = new FlxText(400, timeBar.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = ClientPrefs.data.playOpponent ? cpuControlled_opponent : cpuControlled;
		add(botplayTxt); //botplay text is special
		botplayTxt.cameras = [camHUD];	
		uiGroup.add(botplayTxt);
		
		if(ClientPrefs.data.downScroll) {
			botplayTxt.y = timeBar.y - 78;
		}

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}
		
		var splash:NoteSplash = new NoteSplash(100, 100);
		splash.setupNoteSplash(100, 100);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001; //cant make it invisible or it won't allow precaching
        noteGroup.add(grpNoteSplashes);
        
		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();
				
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();
		
		comboGroup.cameras = [camHUD];		
		uiGroup.cameras = [camHUD];				
		noteGroup.cameras = [camHUD];
		healthBar.cameras = [camOther];
		blackMode.cameras = [camVIP];
		timeTxt.cameras = [camOther];
		overlay.cameras = [camOther];
		overlayLoost.cameras = [camOther];

		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');

		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');

		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getPreloadPath(), 'data/' + songName + '/'))
			for (file in FileSystem.readDirectory(folder))
			{
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
			}
		#end

		startCallback();
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.data.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.data.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.data.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');
		resetRPC();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		callOnScripts('onCreatePost');
		
		setOnScripts('portType', 'beihu'); //idk but someone tell that  use getProperty('portType') in lua
		
		if (startTimer != null){
		    if(startTimer.finished){
		    #if android
    		    MusicBeatState.androidc.visible = true;
    			if (MusicBeatState.checkHitbox != true) MusicBeatState.androidc.alpha = 1;
    		    #end		
    		}   //fix mod use setProperty('startTimer.finished') android control cant change alpha
        }

		cacheCountdown();
		
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}

		super.create();
		Paths.clearUnusedMemory();
		
		CustomFadeTransition.nextCamera = camOther;
		if(eventNotes.length < 1) checkEventNote();

		FadeTime = new FlxTimer();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet * 1.5, 350 / songSpeed * playbackRate * 1.5);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		
		FlxG.animationTimeScale = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		
		
		return playbackRate;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:DebugLuaText = luaDebugGroup.recycle(DebugLuaText);
		newText.text = text;
		#if android 
        newText.text = StringTools.replace(text, "/storage/emulated/0/.NF Engine/", ""); //delete stupid path
		#end
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);		
	}

	public function reloadHealthBarColors() {
		healthBar.setColors(FlxColor.GREEN, FlxColor.PURPLE);
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = SUtil.getPath() + Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		{
			scriptFile = SUtil.getPath() + Paths.getPreloadPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}
		
		if(doPush)
		{
			if(SScript.global.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		#end
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
			#if (hxCodec >= "3.0.0")
			// Recent versions
			video.play(filepath);
			video.onEndReached.add(function()
			{
				video.dispose();
				startAndEnd();
				return;
			}, true);
			#else
			// Older versions
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				startAndEnd();
				return;
			}
			#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
			case "normal": ["Ready_EC_Inglish", "Set_EC_Inglish" ,"Go_EC_Inglish"];
			default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}
		
		

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
			}

			strumPlayAnim(true, 0, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			strumPlayAnim(true, 1, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			strumPlayAnim(true, 2, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			strumPlayAnim(true, 3, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
	
			strumPlayAnim(false, 0, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			strumPlayAnim(false, 1, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			strumPlayAnim(false, 2, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			strumPlayAnim(false, 3, Conductor.stepCrochet * 1.25 / 1000 / playbackRate);

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);

			if (cpuControlled == false) {
				if (chartingMode == false) {
			//add(new Notification(camOther, "Jugando Actualmente: [" + songName + " | " + Difficulty.getString().toUpperCase() + "]", "", 2));
			add(new Notification('Jugando...', "Estas Jugando actualmente\n> " + songName + " | [" + Difficulty.getString().toUpperCase() + "]", 2, camVIP, 1.5));
				}	
		}

			
		if (!ClientPrefs.data.noneAnimations) {
			FlxTween.tween(tipControls, {x: 20, alpha: 1}, 2, {
				onComplete: function (twn:FlxTween) {
					FlxTween.tween(tipControls, {x: 100, alpha: 0}, 6, {
						onComplete: function (twn:FlxTween) {
							tipControls.destroy();
						}
					});
				}
			});
		}
		if (ClientPrefs.data.noneAnimations) {
			FlxTween.tween(tipControls, {x: 100, alpha: 1}, 0.001, {
				onComplete: function (twn:FlxTween) {
					FlxTween.tween(tipControls, {alpha: 0}, 0.001, {
						startDelay: 6,
						onComplete: function (twn:FlxTween) {
							tipControls.destroy();
						}
					});
				}
			});
		}

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
			    #if android
			    MusicBeatState.androidc.visible = true;
			    if (MusicBeatState.checkHitbox != true) MusicBeatState.androidc.alpha = 1;
		        #end
				setSongTime(0);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
					case "normal": ["Ready_EC_Inglish", "Set_EC_Inglish" ,"Go_EC_Inglish"];
					default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
					if (!skipCountdown){
					    #if android
			            MusicBeatState.androidc.visible = true;
			            if (MusicBeatState.checkHitbox != true) MusicBeatState.androidc.alpha = 1;
		                #end
					}
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						tick = THREE;
					case 1:
						countdownReady = createCountdownSprite(introAlts[0], antialias);
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						tick = TWO;
					case 2:
						countdownSet = createCountdownSprite(introAlts[1], antialias);
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						tick = ONE;
					case 3:
						countdownGo = createCountdownSprite(introAlts[2], antialias);
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						tick = GO;
					case 4:
						tick = START;
				}

				notes.forEachAlive(function(note:Note) {
					if (ClientPrefs.data.opponentStrums || note.mustPress) {
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if ((ClientPrefs.data.middleScroll && !note.mustPress && !ClientPrefs.data.playOpponent) || (ClientPrefs.data.middleScroll && note.mustPress && ClientPrefs.data.playOpponent))
							note.alpha *= 0.35;
					}
				});

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(noteGroup), spr);
		FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}
    
    // fun fact: Dynamic Functions can be overriden by just doing this
	// `updateScore = function(miss:Bool = false) { ... }
	// its like if it was a variable but its just a function!
	// cool right? -Crow
	public dynamic function updateScore(miss:Bool = false)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == FunkinLua.Function_Stop)
			return;

		var str:String = ratingName;
		if(totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str += ' (${percent}%) - ${ratingFC}';
		}

		if (ClientPrefs.data.language == 'Inglish') {
		scoreTxt.text = "Score: " + songScore + "\nMisses: " + songMisses + " Rating: " + ratingName + "\nVelocity: " + songSpeed + "x";
		}
		if (ClientPrefs.data.language == 'Spanish') {
		scoreTxt.text = "Puntuacion: " + songScore + "\nFallas: " + songMisses + " Calificacion: " + ratingName + "\nVelocidad: " + songSpeed + "x";
		}
		if (ClientPrefs.data.language == 'Portuguese') {
		scoreTxt.text = "Pontuacao: " + songScore + "\nFalhas: " + songMisses + " Qualificacao: " + ratingName + "\nVelocidade: " + songSpeed + "x";
		}
		
		if (ClientPrefs.data.language == 'Inglish') {
		var marvelousRate:String = ClientPrefs.data.marvelousRating ? 'Marvelous: ${ratingsData[4].hits}\n' : '';
		judgementCounter_S.text = marvelousRate
		+ 'Sicks: ${ratingsData[0].hits}\n'
		+ 'Goods: ${ratingsData[1].hits}\n'
		+ 'Bads: ${ratingsData[2].hits}\n'
		+ 'Shits: ${ratingsData[3].hits}\n';
		}
		if (ClientPrefs.data.language == 'Spanish' || ClientPrefs.data.language == 'Portuguese') {
			var marvelousRate:String = ClientPrefs.data.marvelousRating ? 'Maravilloso: ${ratingsData[4].hits}\n' : '';
			judgementCounter_S.text = marvelousRate
			+ 'Sicks: ${ratingsData[0].hits}\n'
			+ 'Buenas: ${ratingsData[1].hits}\n'
			+ 'Malas: ${ratingsData[2].hits}\n'
			+ 'Shits: ${ratingsData[3].hits}\n';
		}
		
		if (!miss && ClientPrefs.data.playOpponent ? !cpuControlled_opponent : !cpuControlled)
			doScoreBop();

		callOnScripts('onUpdateScore', [miss]);
	}
	
	public dynamic function fullComboFunction()
	{
	    var marvelouss:Int = ClientPrefs.data.marvelousRating ? ratingsData[4].hits : 0;
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;

		ratingFC = 'Clear';
		if(songMisses < 1)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
			else if (marvelouss > 0) ratingFC = 'MFC';
		}
		else if (songMisses < 10)
			ratingFC = 'SDCB';
	}

	public function doScoreBop():Void {
		if(!ClientPrefs.data.scoreZoom)
			return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.040;
		scoreTxt.scale.y = 1.040;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0) setSongTime(startOnTime - 500);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		rsSongLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 1, {
			ease: FlxEase.circIn,
		onComplete: function(twn:FlxTween) {
			FlxTween.tween(timeTxt, {alpha: 0}, 1, {
				startDelay: 1.5,
				ease: FlxEase.circOut,
				type: ONESHOT
			});
		}});

		FlxTween.tween(blackMode, {alpha: 0}, 0.5);

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	var debugNum:Int = 0;
	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
				vocals.loadEmbedded(Paths.voices(songData.song));
		}
		catch(e:Dynamic) {}

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);

		inst = new FlxSound().loadEmbedded(Paths.inst(songData.song));
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(SUtil.getPath() + file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
				for (i in 0...event[1].length)
					makeEvent(event, i);
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				
				if (ClientPrefs.data.filpChart) {
				    if (daNoteData == 0) {
				        daNoteData = 3;
				    }    
				    else if (daNoteData == 1) {
				        daNoteData = 2;
				    }    
				    else if (daNoteData == 2) {
				        daNoteData = 1;
				    }   
				    else if (daNoteData == 3) {
				        daNoteData = 0;
				    } 
				}

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				unspawnNotes.push(swagNote);

				final susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				final floorSus:Int = Math.floor(susLength) - ClientPrefs.data.fixLNL;

				if(floorSus > 0) {
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.updateHitbox();
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.updateHitbox();
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypes.contains(swagNote.noteType)) {
					noteTypes.push(swagNote.noteType);
				}
			}
		}
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
				
			
			case 'Play Sound':
				precacheList.set(event.value1, 'sound');
				Paths.sound(event.value1);
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != FunkinLua.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2],
			value3: event[1][i][3]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.value3 != null ? subEvent.value3 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var strumLineX:Float = ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if(!ClientPrefs.data.playOpponent) {
				if (player == 0) {
					if (!ClientPrefs.data.opponentStrums)
						targetAlpha = 0;
					else if (ClientPrefs.data.middleScroll)
						targetAlpha = 0.35;
				}
			} else {
				if (player == 1) {
					if (!ClientPrefs.data.opponentStrums)
						targetAlpha = 0;
					else if (ClientPrefs.data.middleScroll)
						targetAlpha = 0.35;
				}
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1){
				if(ClientPrefs.data.middleScroll && ClientPrefs.data.playOpponent){
				    babyArrow.x += 310;
				    babyArrow.x -= FlxG.width / 2;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				playerStrums.add(babyArrow);
		    }else{
				if(ClientPrefs.data.middleScroll && !ClientPrefs.data.playOpponent)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				if(ClientPrefs.data.middleScroll && ClientPrefs.data.playOpponent){
				    babyArrow.x += FlxG.width / 2;
				}
				opponentStrums.add(babyArrow);
			}
			

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished) startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished) finishTimer.active = false;
			if (songSpeedTween != null) songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
				if(char != null && char.colorTween != null)
					char.colorTween.active = false;

			#if LUA_ALLOWED
			for (tween in modchartTweens) tween.active = false;
			for (timer in modchartTimers) timer.active = false;
			#end
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
    		if (paused)
    		{
    			if (FlxG.sound.music != null && !startingSong){
				    resyncVocals();
    			}

    			if (startTimer != null && !startTimer.finished) startTimer.active = true;
    			if (finishTimer != null && !finishTimer.finished) finishTimer.active = true;
    			if (songSpeedTween != null) songSpeedTween.active = true;
        
    			var chars:Array<Character> = [boyfriend, gf, dad];
    			for (char in chars)
    				if(char != null && char.colorTween != null)
					char.colorTween.active = true;

    			#if LUA_ALLOWED
    			for (tween in modchartTweens) tween.active = true;
    			for (timer in modchartTimers) timer.active = true;
    			#end

    			paused = false;
    			callOnScripts('onResume');
    			resetRPC(startTimer != null && startTimer.finished);
    		}
    		
    		#if android
    		MusicBeatState.androidc.y = 0;
    		#end
				
		super.closeSubState();
	}

	override public function onFocus():Void
	{
		if (health > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);
		super.onFocus();
	}
    
	override public function onFocusLost():Void
	{			
		#if desktop
		if (health > 0 && !paused && autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#else		
		if (FlxG.autoPause && startedCountdown && !paused && canPause){
		    var ret:Dynamic = callOnScripts('onPause', null, true);
		
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
	    }  //at android it auto work well for psych0.63h but now it broken, so use code add again
        #end        
        
		super.onFocusLost();
	}

	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if desktop
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
		else
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
    var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;
	
	override public function update(elapsed:Float)
	{
		if(!inCutscene && !paused && !freezeCamera) {
			FlxG.camera.followLerp = 0.04 * cameraSpeed * playbackRate;
			if(!startingSong && !endingSong && boyfriend.animOffsets.exists('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}
		else FlxG.camera.followLerp = 0;
		callOnScripts('onUpdate', [elapsed]);

		super.update(elapsed);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		if(botplayTxt != null && botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
		    var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (!ClientPrefs.data.noneAnimations && ClientPrefs.data.overlays == true) {
			if (healthBar.percent > 51) FlxTween.tween(overlay, {alpha: 1}, 0.1);
	
			if (healthBar.percent <= 49) FlxTween.tween(overlay, {alpha: 0}, 0.1);
	
			if (healthBar.percent < 25) FlxTween.tween(overlayLoost, {alpha: 1}, 0.1);
				
			if (healthBar.percent > 26) FlxTween.tween(overlayLoost, {alpha: 0}, 0.1);
		}
		if (ClientPrefs.data.noneAnimations && ClientPrefs.data.overlays == true) {
	
			if (healthBar.percent > 51) overlay.alpha = 1;
	
			if (healthBar.percent <= 49) overlay.alpha = 0;
	
			if (healthBar.percent < 25) overlayLoost.alpha = 1;
	
			if (healthBar.percent > 26) overlayLoost.alpha = 0;
		}

		if(!endingSong && !inCutscene && allowDebugKeys)
		{
			if (controls.justPressed('debug_1'))
				//openChartEditor();
			if (ClientPrefs.data.flashing == true) {
				FlxG.camera.flash(0x6E8D0000, 0.2);
				}
				if (ClientPrefs.data.language == 'Spanish') {
					add(new Notification("Error", "Lastimosamente esta opcion esta desactivada por el Creador o no estas Conectado a Internet", 1, camOther, 1));
					}
					if (ClientPrefs.data.language == 'Inglish') {
						add(new Notification("Mistake", "Unfortunately this option is disabled by the Creator or you are not connected to the Internet", 1, camOther, 1));
					}
					if (ClientPrefs.data.language == 'Portuguese') {
						add(new Notification("Erro", "Infelizmente esta opção está desabilitada pelo Criador ou você não está conectado à Internet", 1, camOther, 1));
					}
			else if (controls.justPressed('debug_2'))
				//openCharacterEditor();
			if (ClientPrefs.data.flashing == true) {
				FlxG.camera.flash(0x6E8D0000, 0.2);
				}
				if (ClientPrefs.data.language == 'Spanish') add(new Notification("Error", "Lastimosamente esta opcion esta desactivada por el Creador o no estas Conectado a Internet", 1, camOther, 1));
				
				if (ClientPrefs.data.language == 'Inglish') add(new Notification("Mistake", "Unfortunately this option is disabled by the Creator or you are not connected to the Internet", 1, camOther, 1));

				if (ClientPrefs.data.language == 'Portuguese') add(new Notification("Erro", "Infelizmente esta opção está desabilitada pelo Criador ou você não está conectado à Internet", 1, camOther, 1));
		}
		
		if (healthBar.bounds.max != null && health > healthBar.bounds.max)
			health = healthBar.bounds.max;
        
        
        updateIconsScale(elapsed);
		updateIconsPosition();
		
		if (startedCountdown && !paused)
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, FlxMath.bound(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, FlxMath.bound(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(ClientPrefs.data.playOpponent ? !cpuControlled_opponent : !cpuControlled) {
					keysCheck();
				} else
					ClientPrefs.data.playOpponent ? opponentDance() : playerDance();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if(daNote.mustPress)
							{
							    if (!ClientPrefs.data.playOpponent){
								    if (cpuControlled && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition)){
									    goodNoteHit(daNote);
									}    
								}else{
								    if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								    goodNoteHitForOpponent(daNote);
								}
							}else{
							    if (!ClientPrefs.data.playOpponent){
							        if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote){
								        opponentNoteHit(daNote);
								    }
								}else{
								    if (cpuControlled_opponent && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition)){
									    opponentNoteHitForOpponent(daNote);
								    }
                                }
                            }   
                            
							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
							{
								if (((!daNote.mustPress && !cpuControlled_opponent && ClientPrefs.data.playOpponent) || (daNote.mustPress && !cpuControlled && !ClientPrefs.data.playOpponent))
								 && !daNote.ignoreNote && !endingSong
								 && (daNote.tooLate == true || daNote.wasGoodHit == false)
								 ){
									noteMiss(daNote);
                                 }
                                
								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end
		
		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
				
			setOnLuas('nps', nps);
			setOnLuas('maxFPS', maxNPS);	
				
		}
        
		setOnScripts('cameraX', camFollow.x);
		setOnScripts('cameraY', camFollow.y);
		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		if (FlxG.keys.justPressed.SHIFT || MusicBeatState._virtualpad.buttonF.justPressed) {
			boyfriend.playAnim('hey');
			boyfriend.specialAnim = true;

			heyanim += 1;
		}

		if (ClientPrefs.data.dodge == true) {
			if (FlxG.keys.justPressed.SPACE || MusicBeatState._virtualpad.buttonG.justPressed) {
				if (boyfriend.animOffsets.exists('dodge')) boyfriend.playAnim('dodge');
				if (boyfriend.animOffsets.exists('dodge')) boyfriend.specialAnim = true;
				doge = true;
				if (doge != false) {
				FadeTime.start(0.7, onDodge, 1);
				}
			}
		}

	}
	
	// Health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, FlxMath.bound((1 - (elapsed * 9 * playbackRate)) / 1.25, 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, FlxMath.bound((1 - (elapsed * 9 * playbackRate)) / 1.25, 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		
	}

	public dynamic function updateIconsPosition()
	{
		var iconOffset:Int = 26;		
		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float // You can alter how icon animations work here
	{
		if(!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		// update health bar
		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		if (healthBar.percent < 20) // losing
        {
            if(ClientPrefs.data.playOpponent){
                iconP1.animation.curAnim.curFrame = iconP1.numFrames > 2 ? 2 : 0;
                iconP2.animation.curAnim.curFrame = 1;
            }else{
                iconP1.animation.curAnim.curFrame = 1;
                iconP2.animation.curAnim.curFrame = iconP2.numFrames > 2 ? 2 : 0;
            }
        }
        else if (healthBar.percent > 80) // winning
        {
            if(!ClientPrefs.data.playOpponent){
                iconP1.animation.curAnim.curFrame = iconP1.numFrames > 2 ? 2 : 0;
                iconP2.animation.curAnim.curFrame = 1;
            }else{
                iconP1.animation.curAnim.curFrame = 1;
                iconP2.animation.curAnim.curFrame = iconP2.numFrames > 2 ? 2 : 0;
            }
        }
        else // neutral
        {
            iconP1.animation.curAnim.curFrame = 0;
            iconP2.animation.curAnim.curFrame = 0;
        }
		return health;
	}

	function openPauseMenu()
	{
	    if (FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		
		#if android
			MusicBeatState.androidc.y = 720;
		#end
		if(ClientPrefs.data.playOpponent ? !cpuControlled_opponent : !cpuControlled)
		{
		    var Strums = ClientPrefs.data.playOpponent ? opponentStrums : playerStrums;
			for (note in Strums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		

		#if desktop
		if(autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}
    
    function openChangersMenu()
	{
	    FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		
		#if android
			MusicBeatState.androidc.y = 720;
			//MusicBeatState.androidc.visible = true;
		#end

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new GameplayChangersSubstate(true));
	}
	
	function openOptionMenu()
	{
	    FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
		
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		#if android
			MusicBeatState.androidc.y = 720;
			//MusicBeatState.androidc.visible = true;
		#end
		//openSubState(new OptionsState());
	}
	
	function openChartEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		chartingMode = true;

		#if desktop
		if(autoUpdateRPC) DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end
		
		MusicBeatState.switchState(new ChartingState());
	}

	function openCharacterEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		#if desktop DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead && !rsCheck && ClientPrefs.getGameplaySetting('botplay') == false)
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				#if LUA_ALLOWED
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				#end
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollow.x, camFollow.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			var value3:String = '';
			if(eventNotes[0].value3 != null)
				value3 = eventNotes[0].value3;

			triggerEvent(eventNotes[0].event, value1, value2, value3, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, value3:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		var flValue3:Null<Float> = Std.parseFloat(value3);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;
		if(Math.isNaN(flValue3)) flValue3 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.35) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					isCameraOnForcedPos = false;
					if(flValue1 != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if(flValue1 == null) flValue1 = 0;
						if(flValue2 == null) flValue2 = 0;
						camFollow.x = flValue1;
						camFollow.y = flValue2;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
				

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				try
				{
					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], value2);
					} else {
						LuaUtils.setVarInArray(this, value1, value2);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
				}
			
			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);

			case 'Alpha HUD':
				if(flValue1 == null) flValue1 = 1;
				if(flValue2 == null) flValue2 = 0.5;

						if (ClientPrefs.data.alphahud == true) {
							FlxTween.tween(camHUD, {alpha: flValue1}, flValue2);
						if (flValue1 == 0 && ClientPrefs.data.concetration == false) {
								FlxTween.tween(camOther, {alpha: flValue1 + 1}, flValue2);
							}
								
							}
			
							if (ClientPrefs.data.concetration == true) {
								FlxTween.tween(camHD, {alpha: flValue1}, 0.2);
								FlxTween.tween(camNotes, {alpha: flValue1}, flValue2);
								FlxTween.tween(camOther, {alpha: flValue1}, flValue2);
							}
	
			case 'Fade Camera':
				if (flValue1 == null) flValue1 = 1;
				if (flValue2 == null) flValue2 = 1;
	
				if (flValue1 == 1) statusFade = true;
				if (flValue1 == 0) statusFade = false;
	
				camGame.fade(FlxColor.BLACK, flValue2, statusFade);
				camHUD.fade(FlxColor.BLACK, flValue2, statusFade);
		}
		
		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		if (gf != null && SONG.notes[sec].gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		moveCamera(isDad);
		callOnScripts('onMoveCamera', [isDad ? 'dad' : 'boyfriend']);
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	public function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return false;
			}
		}
        #if android
		MusicBeatState.androidc.alpha = 0.00001;
		#end
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		var weekNoMiss:String = WeekData.getWeekFileName() + '_nomiss';
		checkForAchievement([weekNoMiss, 'ur_bad', 'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);
		#end

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != FunkinLua.Function_Stop && !transitioning)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			if (!ClientPrefs.data.playOpponent)Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					Mods.loadTopMod();
					if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'));

					if (ClientPrefs.data.music == 'Hallucination') FlxG.sound.playMusic(Paths.music('Hallucination'), 1.2);

					if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'));
					#if desktop DiscordClient.resetClientID(); #end

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					
					#if android		
                		MusicBeatState.androidc.visible = false;				
            		#end
            		
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay') && !ClientPrefs.data.playOpponent) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					
					#if android		
                		MusicBeatState.androidc.visible = false;				
            		#end
            		
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				Mods.loadTopMod();
				#if desktop DiscordClient.resetClientID(); #end

				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				
				#if android		
                		MusicBeatState.androidc.visible = false;				
            	#end												
				
				if(ClientPrefs.data.ResultsScreen){
				
				    rsSicks = ratingsData[0].hits;
	                rsGoods = ratingsData[1].hits;
	                rsBads = ratingsData[2].hits;
	                rsShits = ratingsData[3].hits;
	                if (ClientPrefs.data.marvelousRating) reMarvelouss = ratingsData[4].hits;
	                
	                rsACC = ratingPercent;
	                rsScore = songScore;
	                rsHits = songHits;
	                rsMisses = songMisses;
	                
	                rsRatingFC = ratingFC;
                    rsRatingName = ratingName;
                    rsCheck = true;
                    
					if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'));

					if (ClientPrefs.data.music == 'Hallucination') FlxG.sound.playMusic(Paths.music('Hallucination'), 1.2);

					if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'));

					FlxG.cameras.fade(FlxColor.BLACK, 0.1, true);
                    
				    openSubState(new ResultsScreen(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
				else{
				    MusicBeatState.switchState(new FreeplayState());
					if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'));

					if (ClientPrefs.data.music == 'Hallucination') FlxG.sound.playMusic(Paths.music('Hallucination'), 1.2);

					if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'));
				    FlxG.sound.music.fadeIn(4, 0, 0.7);
				    
				}
				persistentUpdate = false;
        		persistentDraw = true;

				changedDifficulty = false;
			}
			transitioning = true;
		}
		return true;
	}
    
	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;
    
	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;
	// Stores HUD Objects in a Group
	public var uiGroup:FlxSpriteGroup;
	// Stores Note Objects in a Group
	public var noteGroup:FlxTypedGroup<FlxBasic>;
	
	//it not use because new way
		
	var rateSpr_S:FlxSprite;
    var comboSpr_S:FlxSprite; 
    
    var rateTween:FlxTween;
    var comboTween:FlxTween;
    var comboNumTween:Array<FlxTween> = [];
    
    var rateTweenScaleX:FlxTween;
    var comboTweenScaleX:FlxTween;
    var comboNumTweenScaleX:Array<FlxTween> = [];
    
    var rateTweenScaleY:FlxTween;
    var comboTweenScaleY:FlxTween;
    var comboNumTweenScaleY:Array<FlxTween> = [];
    
    var seperatedScore:Array<Int> = [];
	private function cachePopUpScore()
	{
		var uiPrefix:String = '';
		var uiSuffix:String = '';
		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
		}

		for (rating in ratingsData){
			Paths.image(uiPrefix + rating.image + uiSuffix);
			var Spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + rating.image + uiSuffix));
			add(Spr);
            
            for (i in 0...ratingsData.length){
                if (ratingsData[i].name == rating.name){
    		        ratingsData[i].color = FlxColor.fromInt(CoolUtil.getComboColor(Spr));
    		        Spr.destroy();
    		        continue;
    		    }
		    }
		}
		
		for (i in 0...10)
		Paths.image(uiPrefix + 'num' + i + uiSuffix);		
		
		var antialias:Bool = ClientPrefs.data.antialiasing;

		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
			antialias = !isPixelStage;
		}
		
		var placement:Float = FlxG.width * 0.35;
		
		rateSpr_S = new FlxSprite().loadGraphic(Paths.image(uiPrefix + ratingsData[ClientPrefs.data.marvelousRating ? 4 : 0].image + uiSuffix));
		rateSpr_S.cameras = [camHUD];
		rateSpr_S.screenCenter();
		rateSpr_S.x = placement - 40;
		rateSpr_S.y -= 60;
		rateSpr_S.x += ClientPrefs.data.comboOffset[0];
		rateSpr_S.y -= ClientPrefs.data.comboOffset[1];
		rateSpr_S.x += rateSpr_S.width * 0.7 * 0.5;
		rateSpr_S.y += rateSpr_S.height * 0.7 * 0.5;
		rateSpr_S.antialiasing = antialias;
		rateSpr_S.alpha = 0.000001;
		rateSpr_S.visible = showRating;
		comboGroup.add(rateSpr_S);
		
				
		comboSpr_S = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'combo' + uiSuffix));
		comboSpr_S.cameras = [camHUD];
		comboSpr_S.screenCenter();
		comboSpr_S.x = placement;
		comboSpr_S.x += ClientPrefs.data.comboOffset[0];
		comboSpr_S.y -= ClientPrefs.data.comboOffset[1];
		comboSpr_S.antialiasing = antialias;
		comboSpr_S.y += 60;
		comboSpr_S.alpha = 0.000001;
		comboSpr_S.visible = showCombo;
		comboGroup.add(comboSpr_S);
		
		
		var xThing:Float = 0;
		
		numItems = new FlxTypedGroup<FlxSprite>();
		numItems.visible = showComboNum;
		add(numItems);
		numItems.cameras = [camHUD];
		
		for (comboNum in 0...4) //9999 //why last get null?
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'num' + 0 + uiSuffix));
			numScore.screenCenter();
			numScore.x = placement + (50 * comboNum) - 90 + ClientPrefs.data.comboOffset[2];
			numScore.y += 80 - ClientPrefs.data.comboOffset[3];
			
			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			numScore.updateHitbox();			
			numScore.antialiasing = antialias;
            numScore.alpha = 0.000001;
            
            comboGroup.add(numScore);
            numItems.add(numScore);            

			if(numScore.x > xThing) xThing = numScore.x;
		}
		
		comboSpr_S.x = xThing + 50 * 2;
		
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset;
		
		if ((ClientPrefs.data.playOpponent && cpuControlled_opponent) || (!ClientPrefs.data.playOpponent && cpuControlled)) noteDiff = 0;
		//best botplay for real lmao
		
		rsNoteMs.push(noteDiff / playbackRate);
		rsNoteTime.push(note.strumTime);
		
		vocals.volume = 1;

		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, Math.abs(noteDiff) / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashData.disabled)
			spawnNoteSplashOnNote(note);

		if(!practiceMode && ClientPrefs.data.playOpponent ? !cpuControlled_opponent : !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var uiPrefix:String = "";
		var uiSuffix:String = '';
		var antialias:Bool = ClientPrefs.data.antialiasing;

		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
			antialias = !isPixelStage;
		}
		
		rateSpr_S.loadGraphic(Paths.image(uiPrefix + daRating.image + uiSuffix));
		rateSpr_S.antialiasing = antialias;		
        
        //comboSpr_S.loadGraphic(Paths.image(uiPrefix + 'combo' + uiSuffix));
		comboSpr_S.antialiasing = antialias;		
		
		var scale:Float = 0;
		
		if (!PlayState.isPixelStage)
		{
			rateSpr_S.setGraphicSize(Std.int(rateSpr_S.width * 0.7));
			comboSpr_S.setGraphicSize(Std.int(comboSpr_S.width * 0.6));
			scale = 0.7;
		}
		else
		{
			rateSpr_S.setGraphicSize(Std.int(rateSpr_S.width * daPixelZoom * 0.85));
			comboSpr_S.setGraphicSize(Std.int(comboSpr_S.width * daPixelZoom * 0.85));
			scale = 0.85;
		}

		comboSpr_S.updateHitbox();
		rateSpr_S.updateHitbox();

		var seperatedScore:Array<Int> = [];
        var startShow = 1; //use for combo 1000+

		if (combo >= 10000) seperatedScore.push(Math.floor(combo / 10000) % 10);
		if(combo >= 1000) seperatedScore.push(Math.floor(combo / 1000) % 10);
		if (combo >= 100) seperatedScore.push(Math.floor(combo / 100) % 10);
		if (combo >= 10) seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		for (comboNum in 0...seperatedScore.length)
		{
		    var numScore:FlxSprite = numItems.members[comboNum + startShow];
			numScore.loadGraphic(Paths.image(uiPrefix + 'num' + seperatedScore[comboNum] + uiSuffix));
			if (ClientPrefs.data.comboColor) numScore.color = daRating.color;
			
			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			numScore.updateHitbox();			
			numScore.antialiasing = antialias;
			
			if (comboNumTween[comboNum + startShow] != null) comboNumTween[comboNum + startShow].cancel();
            numScore.alpha = 1;                        
            comboNumTween[comboNum + startShow] = FlxTween.tween(numScore, {alpha: 0}, 0.4 / playbackRate, {
			startDelay: 0.6 / playbackRate
		    });
		    
		    if (comboNumTweenScaleX[comboNum] != null) comboNumTweenScaleX[comboNum].cancel();
            numScore.scale.x = 0.5 + 0.07;                        
            comboNumTweenScaleX[comboNum] = FlxTween.tween(numScore.scale, {x: 0.5}, 0.2 / playbackRate);
		    
		    if (comboNumTweenScaleY[comboNum] != null) comboNumTweenScaleY[comboNum].cancel();
            numScore.scale.y = 0.5 + 0.07;                        
            comboNumTweenScaleY[comboNum] = FlxTween.tween(numScore.scale, {y: 0.5}, 0.2 / playbackRate);
            
            numScore.offset.x -= comboOffsetFix[seperatedScore[comboNum]][0] * 0.5;
			numScore.offset.y += comboOffsetFix[seperatedScore[comboNum]][1] * 0.5;
			
		}
		
		if (rateTween != null) rateTween.cancel();
		rateSpr_S.alpha = 1;
		rateTween = FlxTween.tween(rateSpr_S, {alpha: 0}, 0.4 / playbackRate, {
			startDelay: 0.6 / playbackRate
		});
        
        if (comboTween != null) comboTween.cancel();
        comboSpr_S.alpha = 1;
		comboTween = FlxTween.tween(comboSpr_S, {alpha: 0}, 0.4 / playbackRate, {
			startDelay: 0.6 / playbackRate
		});
		
		if (rateTweenScaleX != null) rateTweenScaleX.cancel();
		rateSpr_S.scale.x = scale + 0.07;
		rateTweenScaleX = FlxTween.tween(rateSpr_S.scale, {x: scale}, 0.2 / playbackRate);
        
        if (comboTweenScaleX != null) comboTweenScaleX.cancel();
        comboSpr_S.scale.x = scale + 0.07;
		comboTweenScaleX = FlxTween.tween(comboSpr_S.scale, {x: scale}, 0.2 / playbackRate);
		
		if (rateTweenScaleY != null) rateTweenScaleY.cancel();
		rateSpr_S.scale.y = scale + 0.07;
		rateTweenScaleY = FlxTween.tween(rateSpr_S.scale, {y: scale}, 0.2 / playbackRate);
        
        if (comboTweenScaleY != null) comboTweenScaleY.cancel();
        comboSpr_S.scale.y = scale + 0.07;
		comboTweenScaleY = FlxTween.tween(comboSpr_S.scale, {y: scale}, 0.2 / playbackRate);
		
		rateSpr_S.offset.x += rateSpr_S.width / 2;
        rateSpr_S.offset.y += rateSpr_S.height / 2;
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if (!controls.controllerMode && FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
	}
	
	private function keyPressed(key:Int)
	{
		if(ClientPrefs.data.playOpponent ? cpuControlled_opponent : cpuControlled || paused || key < 0) return;
		var char:Character = ClientPrefs.data.playOpponent ? dad : boyfriend;
		if(!generatedMusic || endingSong || char.stunned) return;

		// had to name it like this else it'd break older scripts lol
		var ret:Dynamic = callOnScripts('preKeyPress', [key], true);
		if(ret == FunkinLua.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = !strumsBlocked[n.noteData] && n.canBeHit && ((n.mustPress && !ClientPrefs.data.playOpponent) || (!n.mustPress && ClientPrefs.data.playOpponent)) && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return n != null && canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		var shouldMiss:Bool = !ClientPrefs.data.ghostTapping;

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime && !doubleNote.hitCausesMiss)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}

			if (!ClientPrefs.data.playOpponent) goodNoteHit(funnyNote);
			else opponentNoteHitForOpponent(funnyNote);
		}
		else {
			if (shouldMiss && !char.stunned) {
				callOnScripts('onGhostTap', [key]);
				noteMissPress(key);
			}
		}
		
		// Needed for the  "Just the Two of Us" achievement.
		//									- Shadow Mario
		if(!keysPressed.contains(key)) keysPressed.push(key);

		
		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = ClientPrefs.data.playOpponent ? opponentStrums.members[key] : playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		//trace('Pressed: ' + eventKey);

		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(ClientPrefs.data.playOpponent ? !cpuControlled_opponent : !cpuControlled && startedCountdown && !paused)
		{
			var spr:StrumNote = ClientPrefs.data.playOpponent ? opponentStrums.members[key] : playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnScripts('onKeyRelease', [key]);
		}
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			pressArray.push(controls.justPressed(key));
			releaseArray.push(controls.justReleased(key));
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);
        var char:Character = ClientPrefs.data.playOpponent ? dad : boyfriend;
		if (startedCountdown && !char.stunned && generatedMusic)
		{
			// rewritten inputs???
			if(notes.length > 0)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					// hold note functions
					if (strumsBlocked[daNote.noteData] != true 
				    && daNote.isSustainNote 
					&& holdArray[daNote.noteData] 
					&& daNote.canBeHit
					&& !daNote.tooLate 
					&& !daNote.wasGoodHit
					&& !daNote.blockHit) 
					{
						if (daNote.mustPress && !ClientPrefs.data.playOpponent){
						goodNoteHit(daNote);
						}
						if (!daNote.mustPress && ClientPrefs.data.playOpponent){
						opponentNoteHitForOpponent(daNote);
						}
					}
				});
			}

			if (!holdArray.contains(true) || endingSong)
				ClientPrefs.data.playOpponent ? opponentDance() : playerDance();

			#if ACHIEVEMENTS_ALLOWED
			else checkForAchievement(['oversinging']);
			#end
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove

		switch(daNote.noteType) {
			case 'Glitch Note':
				FlxG.sound.play(Paths.sound('notes-sound/glitch'), 0.6);
				
				health -= 15;

				status2 = true;

			case 'nota de peligro':
				FlxG.sound.play(Paths.sound('notes-sound/sonido-de-disparo'));
				if (ClientPrefs.data.flashing == true) {
					FlxG.camera.flash(FlxColor.WHITE, 1);
				}

				if (doge == true){
					boyfriend.playAnim('dodge');
					boyfriend.specialAnim = true;
				}

				status2 = true;

				if (doge == false) {
				health = 0;

				boyfriend.playAnim('hurt', true);
				boyfriend.specialAnim = true;
				}

			dad.playAnim('singDOWN', true);
			dad.specialAnim = true;
		}

		notes.forEachAlive(function(note:Note) {
			if (daNote != note && (!daNote.mustPress && ClientPrefs.data.playOpponent || daNote.mustPress && !ClientPrefs.data.playOpponent) && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});
		
		noteMissCommon(daNote.noteData, daNote);
		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null)
	{
		// score and data
		var subtract:Float = 0.05;
		if(note != null) subtract = note.missHealth;
        
		// GUITAR HERO SUSTAIN CHECK LOL!!!!

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}
		
		var lastCombo:Int = combo;
		combo = 0;
        
        if (!note.isSustainNote && note != null){
		    rsNoteMs.push(167);
		    rsNoteTime.push(note.strumTime);
		}
		
		health -= 5;
		if(!practiceMode) songScore -= 10;
		if(!endingSong) songMisses++;
		totalPlayed++;
		RecalculateRating(true);

		// play character anims
		var char:Character = ClientPrefs.data.playOpponent ? dad : boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;
		
			var charColor:FlxColor = 0x5BFF6666;
			var chars:Array<Character> = [boyfriend, gf];

			var suffix:String = '';
			if(note != null) suffix = note.animSuffix;

			
			if(!note.noMissAnimation) {//var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + suffix;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			char.playAnim(animToPlay + note.animSuffix, true);

			for (who in chars)
				{
					who.color = charColor;
				}
		}
		vocals.volume = 0;

		FlxTween.tween(gf, {alpha: 0}, 0.5, {
			onComplete: function (twn:FlxTween) {

				for (who in chars)
					{
						who.color = FlxColor.WHITE;
					}
			}
		});
	}

	public function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		if (health >= note.hitHealth * healthLoss + note.hitHealth * healthLoss) {
			health -= note.hitHealth * healthLoss;
		}

		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		note.hitByOpponent = true;
		
        var functionReturn:String = 'opponentNoteHit';
		var result:Dynamic = callOnLuas(functionReturn, [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript(functionReturn, [note]);

		if (!note.isSustainNote)
		{
			invalidateNote(note);
		}
	}	

	public function opponentNoteHitForOpponent(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled_opponent && (note.ignoreNote || note.hitCausesMiss)) return;
		
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		note.wasGoodHit = true;
		if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), ClientPrefs.data.hitsoundVolume);
        /*
		if(note.hitCausesMiss) {
			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote)
				spawnNoteSplashOnNote(note);
            /*
			if(!note.noMissAnimation)
			{
				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(dad.animation.getByName('hurt') != null) {
							dad.playAnim('hurt', true);
							dad.specialAnim = true;
						}
				}
			}
            
			if (!note.isSustainNote)
				invalidateNote(note);
			return;
		}
        */ // opponent dont need 
        
		if (!note.isSustainNote)
		{
			combo++;
			if(combo > 9999) combo = 9999;
			if (combo > highestCombo) highestCombo = combo;
			notesHitArray.unshift(Date.now());
			popUpScore(note);
		}
		var gainHealth:Bool = true; // prevent health gain, as sustains are threated as a singular note
		if (guitarHeroSustains && note.isSustainNote)
			gainHealth = false;

		if (gainHealth)
			health += note.hitHealth * healthGain;

		if(!note.noAnimation) {
		    var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}
			
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + altAnim;

			var char:Character = dad;
			var animCheck:String = 'hey';
			if(note.gfNote)
			{
				char = gf;
				animCheck = 'cheer';
			}
			
			if(char != null)
			{
				char.playAnim(animToPlay + note.animSuffix, true);
				char.holdTimer = 0;
				
				if(note.noteType == 'Hey!') {
					if(char.animOffsets.exists(animCheck)) {
						char.playAnim(animCheck, true);
						char.specialAnim = true;
						char.heyTimer = 0.6;
					}
				}
			}
		}

		if(!cpuControlled_opponent)
		{
			var spr = opponentStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true);
		}
		else strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		vocals.volume = 1;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;
		
		var functionReturn:String = ClientPrefs.data.OpponentCodeFix ? 'goodNoteHit' : 'opponentNoteHit';
		var result:Dynamic = callOnLuas(functionReturn, [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript('goodNoteHit', [note]);

		if (!note.isSustainNote)
			invalidateNote(note);
	}
	
	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

		if (!cpuControlled) hitnotesong += 1;

		note.wasGoodHit = true;
		if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), ClientPrefs.data.hitsoundVolume);

		if(note.hitCausesMiss) {
			if(!note.noMissAnimation)
			{
				switch(note.noteType) {
					case 'Glitch Note':
						FlxG.sound.play(Paths.sound('notes-sound/glitch'), 0.4);
						
						health += 5;

					case 'Hurt Note': //Hurt note
							boyfriend.playAnim('dodge', true);
							boyfriend.specialAnim = true;

					case 'nota de peligro': //Fire Note
							FlxG.sound.play(Paths.sound('notes-sound/sonido-de-disparo'));
							if (ClientPrefs.data.flashing == true) {
								FlxG.camera.flash(FlxColor.WHITE, 1);
							}
							boyfriend.playAnim('dodge', true);
							boyfriend.specialAnim = true;
							dad.playAnim('singDOWN', true);
							dad.specialAnim = true;
				}
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			return;
		}

		if (!note.isSustainNote)
		{
			combo++;
			if(combo > 9999) combo = 9999;
			if (combo > highestCombo) highestCombo = combo;
			notesHitArray.unshift(Date.now());
			popUpScore(note);
		}


		if(!note.noAnimation) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];

			strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			if (difficultysong == 'DEMENTIA') strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);

			var char:Character = boyfriend;
			var animCheck:String = 'hey';
			if(note.gfNote)
			{
				char = gf;
				animCheck = 'cheer';
			}
			
			if(char != null)
			{
				char.playAnim(animToPlay + note.animSuffix, true);
				char.holdTimer = 0;
				
				if(note.noteType == 'Hey!') {
					if(char.animOffsets.exists(animCheck)) {
						char.playAnim(animCheck, true);
						char.specialAnim = true;
						char.heyTimer = 0.6;
					}
				}
			}
		}

		if (!note.noAnimation) {
			isBF = true;
			}

		if(!cpuControlled)
		{
			var spr = playerStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true);
		}
		else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		vocals.volume = 1;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;
		
		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript('goodNoteHit', [note]);

		if (!note.isSustainNote)
			invalidateNote(note);
	}
	
	public function goodNoteHitForOpponent(note:Note):Void
	{
		if(note.noteType == 'Hey!' && boyfriend.animOffsets.exists('hey')) {
			boyfriend.playAnim('hey', true);
			boyfriend.specialAnim = true;
			boyfriend.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			
			var char:Character = boyfriend;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		note.hitByOpponent = true;
        
        var functionReturn:String = ClientPrefs.data.OpponentCodeFix ? 'opponentNoteHit' : 'goodNoteHit';
		var result:Dynamic = callOnLuas(functionReturn, [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != FunkinLua.Function_Stop && result != FunkinLua.Function_StopHScript && result != FunkinLua.Function_StopAll) callOnHScript(functionReturn, [note]);

		if (!note.isSustainNote)
		{
			invalidateNote(note);
		}
	}
	
	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = ClientPrefs.data.playOpponent ? opponentStrums.members[note.noteData] : playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		#if LUA_ALLOWED
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				script.call('onDestroy');
				script.destroy();
			}

		while (hscriptArray.length > 0)
			hscriptArray.pop();
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);		
		FlxG.animationTimeScale = 1;
		FlxG.sound.music.pitch = 1;
		Note.globalRgbShaders = [];
		backend.NoteTypesConfig.clearNoteTypesData();
		instance = null;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		if(FlxG.sound.music.time >= -ClientPrefs.data.noteOffset)
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
				|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
			{
				resyncVocals();
			}
		}

		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		characterBopper(curBeat);

		super.beatHit();
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}
	
	public function characterBopper(beat:Int):Void {
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			dad.dance();
	}

	public function playerDance(force:Bool = false):Void {
		if(force || boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			boyfriend.dance();
	}
	
	public function opponentDance(force:Bool = false):Void {
		if(force || dad.animation.curAnim != null && dad.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
			dad.dance();
	}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();
		
		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = SUtil.getPath() + Paths.getPreloadPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = SUtil.getPath() + Paths.getPreloadPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = SUtil.getPath() + Paths.getPreloadPath(scriptFile);

		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			if(newScript.parsingException != null)
			{
				addTextToDebug('ERROR ON LOADING: ${newScript.parsingException.message}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
					{
						if (e != null)														
						{
							var len:Int = e.message.indexOf('\n') + 1;
							if(len <= 0) len = e.message.length;
								addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, len)}', FlxColor.RED);
						}
					}

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize tea interp!!! ($file)');
				}
				else trace('initialized tea interp successfully: $file');
			}

		}
		catch(e)
		{
			var len:Int = e.message.indexOf('\n') + 1;
			if(len <= 0) len = e.message.length;
			addTextToDebug('ERROR - ' + e.message.substr(0, len), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = psychlua.FunkinLua.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [psychlua.FunkinLua.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [FunkinLua.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == FunkinLua.Function_StopLua || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = psychlua.FunkinLua.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(psychlua.FunkinLua.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;
		for(i in 0...len) {
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try {
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
					{
						var len:Int = e.message.indexOf('\n') + 1;
						if(len <= 0) len = e.message.length;
						addTextToDebug('ERROR (${callValue.calledFunction}) - ' + e.message.substr(0, len), FlxColor.RED);
					}
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == FunkinLua.Function_StopHScript || myValue == FunkinLua.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}

					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			if(!instancesExclude.contains(variable))
				instancesExclude.push(variable);
			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		var spr2:StrumNote = null;
		var pos:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		var posx:Float = ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;

			spr = opponentStrums.members[id];

			spr2 = playerStrums.members[id];

			if (difficultysong == 'DEMENTIA') {
				opponentStrums.members[id].alpha = 0.6;
				opponentStrums.members[id].x = playerStrums.members[id].x;
			}

			if (!ClientPrefs.data.noneAnimations) {
				if(spr != null) {
					if (ClientPrefs.data.downScroll == true) FlxTween.tween(spr2, {y: pos - 15}, 0.2, {
						type: PERSIST,
						onComplete: function (twn:FlxTween) {
							FlxTween.tween(spr2, {y: pos}, 0.1);
						}
					});
					if (ClientPrefs.data.downScroll == false) FlxTween.tween(spr2, {y: pos + 15}, 0.2, {
						type: PERSIST,
						onComplete: function (twn:FlxTween) {
							FlxTween.tween(spr2, {y: pos}, 0.1);
						}
					});
				}
				if (spr != null) {
					if (ClientPrefs.data.downScroll == true) FlxTween.tween(spr, {y: pos - 15}, 0.2, {
						type: PERSIST,
						onComplete: function (twn:FlxTween) {
							FlxTween.tween(spr, {y: pos}, 0.1);
						}
					});
					if (ClientPrefs.data.downScroll == false) FlxTween.tween(spr, {y: pos + 15}, 0.2, {
						type: PERSIST,
						onComplete: function (twn:FlxTween) {
							FlxTween.tween(spr, {y: pos}, 0.1);
						}
					});
				}
			}
	}

	public var ratingName:String = 'N/A';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != FunkinLua.Function_Stop)
		{
			ratingName = 'N/A';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if (ClientPrefs.data.language == 'Inglish') {
				ratingName = ratingStuffINGLISH[ratingStuffINGLISH.length-1][0]; //Uses last string
				if(ratingPercent < 1)
					for (i in 0...ratingStuffINGLISH.length-1)
						if(ratingPercent < ratingStuffINGLISH[i][1])
						{
							ratingName = ratingStuffINGLISH[i][0];
							break;
						}
					}
					if (ClientPrefs.data.language == 'Spanish') {
						ratingName = ratingStuffESPANISH[ratingStuffESPANISH.length-1][0]; //Uses last string
						if(ratingPercent < 1)
							for (i in 0...ratingStuffESPANISH.length-1)
								if(ratingPercent < ratingStuffESPANISH[i][1])
								{
									ratingName = ratingStuffESPANISH[i][0];
									break;
								}
					}
					if (ClientPrefs.data.language == 'Portuguese') {
						ratingName = ratingStuffPORTUGUES[ratingStuffPORTUGUES.length-1][0]; //Uses last string
						if(ratingPercent < 1)
							for (i in 0...ratingStuffPORTUGUES.length-1)
								if(ratingPercent < ratingStuffPORTUGUES[i][1])
								{
									ratingName = ratingStuffPORTUGUES[i][0];
									break;
								}
					}
			}
			fullComboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
	}

	

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null)
	{
		if(chartingMode) return;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));
		if(cpuControlled) return;

		for (name in achievesToCheck) {
			var unlock:Bool = false;
			if (name != WeekData.getWeekFileName() + '_nomiss' && Achievements.exists(name)) // common achievements
			{
				switch(name)
				{
					case 'ur_bad':
						unlock = (ratingPercent < 0.2 && !practiceMode);

					case 'ur_good':
						unlock = (ratingPercent >= 1 && !usedPractice);

					case 'oversinging':
						unlock = (boyfriend.holdTimer >= 10 && !usedPractice);

					case 'hype':
						unlock = (!boyfriendIdled && !usedPractice);

					case 'two_keys':
						unlock = (!usedPractice && keysPressed.length <= 2);

					case 'toastie':
						unlock = (!ClientPrefs.data.cacheOnGPU && !ClientPrefs.data.shaders && ClientPrefs.data.lowQuality && !ClientPrefs.data.antialiasing);

					case 'debugger':
						unlock = (Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice);
				}
			}
			else // any FC achievements, name should be "weekFileName_nomiss", e.g: "week3_nomiss";
			{
				if(isStoryMode && campaignMisses + songMisses < 1 && Difficulty.getString().toUpperCase() == 'HARD'
					&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
					unlock = true;
			}

			if(unlock) Achievements.unlock(name);
		}
	}
	#end

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}


        #if android
	public function initLuaShader(name:String, ?glslVersion:Int = 100)
        #else
        public function initLuaShader(name:String, ?glslVersion:Int = 120)
        #end
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/shaders/'));

		for(mod in Mods.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if(FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
		#else
		FlxG.log.warn("This platform doesn\'t support Runtime Shaders!");
		#end
		return false;
	}
	#end
}