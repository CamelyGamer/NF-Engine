package states;

//import flixel.addons.editors.spine.FlxSpine;
import flixel.ui.FlxButton;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import objects.MenuItem;
import objects.MenuCharacter;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	public var bgYellow:FlxSprite;
	public var bg_Warning:FlxSprite;
	public var warningText:FlxText;
	var bgSprite:FlxSprite;

	var bgArray:String;

	var arrowleftButton:FlxButton;
	var arrowrightButton:FlxButton;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var gogo:FlxTimer;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var DiffDement:Bool;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekType:MenuItem;

	var bGame:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];
	var twn(default, null):FlxTween;


	public function onWarning(Timer:FlxTimer):Void {
		if (DiffDement == true) {
			FlxTween.tween(warningText, {alpha: 1}, 0.4, {
				onComplete: function (twn:FlxTween) {
					FlxTween.tween(warningText, {alpha: 0}, 0.4);
				}
			});
			FlxTween.tween(bg_Warning, {alpha: 1}, 0.4, {
				onComplete: function(twn:FlxTween) {
					FlxTween.tween(bg_Warning, {alpha: 0}, 0.4);
				}
			});
		}
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.sound.music.fadeIn(2, 0, 1.2);

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		bGame = new FlxSprite(0, 0);
		bGame.antialiasing = ClientPrefs.data.antialiasing;

		txtWeekTitle = new FlxText(0, 10, 0, "", 60);
		txtWeekTitle.setFormat("miss.ttf", 60, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		bg_Warning = new FlxSprite().loadGraphic(Paths.image('Peligro_BG'));
		bg_Warning.antialiasing = ClientPrefs.data.antialiasing;
		bg_Warning.screenCenter();
		bg_Warning.width = FlxG.width;
		bg_Warning.height = FlxG.height;
		bg_Warning.alpha = 0;

		if (ClientPrefs.data.language == 'Spanish') {
		warningText = new FlxText(0, FlxG.height - 50, 0, "DIFICIL!!", 10);
		}
		if (ClientPrefs.data.language == 'Inglish') {
		warningText = new FlxText(0, FlxG.height - 50, 0, "DIFFICULT!!", 10);
		}
		if (ClientPrefs.data.language == 'Portuguese') {
		warningText = new FlxText(0, FlxG.height - 50, 0, "DIFÍCIL!!", 10);
		}
		warningText.setFormat("vnd.ttf", 32, FlxColor.RED, CENTER, OUTLINE_FAST, FlxColor.BLACK);
		warningText.screenCenter(X);
		warningText.antialiasing = ClientPrefs.data.antialiasing;
		warningText.alpha = 0;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bgYellow = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgYellow.alpha = 0;
		bgSprite = new FlxSprite(0, 0);
		bgSprite.screenCenter();
		bgSprite.setGraphicSize(FlxG.width, FlxG.height);
		bgSprite.alpha = 1;

		/*BG = new FlxSprite(0, 0);
		BG.screenCenter();
		BG.setGraphicSize(FlxG.width, FlxG.height);*/


		grpWeekText = new FlxTypedGroup<MenuItem>();
		//grpWeekText.alpha = 0;
		add(bGame);
		add(grpWeekText);
		//FlxTween.tween(grpWeekText, {alpha: 1}, 5);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, FlxG.height - 20, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.screenCenter(X);
				//weekThing.visible = false;
				//weekThing.y = FlxG.height;
				weekThing.targetY = num;
				weekThing.visible = false;
				grpWeekText.add(weekThing);

				//weekThing.screenCenter(X);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekType.width + 10 + weekType.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width - 15, 0).loadGraphic(Paths.image('icons/Menu/leftArrow'));
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.alpha = 0;
		//difficultySelectors.add(leftArrow);
		FlxTween.tween(leftArrow, {alpha: 1}, 5);

		arrowleftButton = new FlxButton(leftArrow.x, leftArrow.y, "");
		arrowleftButton.loadGraphicFromSprite(leftArrow);
		add(arrowleftButton);

		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		sprDifficulty.alpha = 0;
		difficultySelectors.add(sprDifficulty);
		FlxTween.tween(sprDifficulty, {alpha: 1}, 5);

		rightArrow = new FlxSprite(leftArrow.x + 320, leftArrow.y).loadGraphic(Paths.image('icons/Menu/rightArrow'));
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.alpha = 0;
		//difficultySelectors.add(rightArrow);
		FlxTween.tween(rightArrow, {alpha: 1}, 5);

		arrowrightButton = new FlxButton(rightArrow.x, rightArrow.y, "");
		arrowrightButton.loadGraphicFromSprite(rightArrow);
		add(arrowrightButton);

		add(txtWeekTitle);
		add(bgSprite);
		add(warningText);
		add(bg_Warning);

		changeWeek();
		changeDifficulty();

		gogo = new FlxTimer();
		gogo.start(0.8, onWarning, 0);

		MusicBeatState.updatestate('StoryMode');

		#if android
		addVirtualPad(LEFT_RIGHT, A_B);
		#end

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var leftP = controls.UI_LEFT_P;
			var rightP = controls.UI_RIGHT_P;
			if (leftP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			}

			if (rightP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
				//FlxG.sound.playMusic(Paths.inst(''), 0.7);
			}

			bGame.setGraphicSize(FlxG.width + 10, FlxG.height + 10);

			if(FlxG.mouse.wheel >= 1)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-1);
				changeDifficulty();
			}
			if (FlxG.mouse.wheel <= -1) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(1);
				changeDifficulty();
			}

			if (arrowrightButton.justPressed) {
				arrowrightButton.alpha = 1;
				changeDifficulty(1);
			}
			if (arrowrightButton.released) {
				arrowrightButton.alpha = 0.3;
			}

			if (arrowleftButton.justPressed) {
				arrowleftButton.alpha = 1;
				changeDifficulty(-1);
			} 
			if (arrowleftButton.released) {
				arrowleftButton.alpha = 0.3;
			}

			if (leftP || rightP) {
				changeDifficulty();
			}

			if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				FlxG.sound.music.fadeOut(0.7, 0);
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek || FlxG.mouse.justPressedRight && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.sound.music.fadeOut(2, 0);
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			lock.visible = (lock.y > FlxG.height / 2);
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
	
				var diffic = Difficulty.getFilePath(curDifficulty);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
	
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.sound.music.fadeOut(2, 0);

				//grpWeekText.members[curWeek].alpha = 0;

				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
				FreeplayState.destroyFreeplayVocals();
			});
			
			#if MODS_ALLOWED
			DiscordClient.loadModRPC();
			#end
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));
		if (diff == 'dementia') {
			DiffDement = true;
		}
		if (diff != 'dementia') {
			DiffDement = false;
		}

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 100;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		txtWeekTitle.y = FlxG.height - (txtWeekTitle.height + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (item in grpWeekText.members)
		{
			item.ID = bullShit - curWeek;
			if (item.ID == Std.int(0) && unlocked) {
				item.alpha = 1;
			} else
				item.alpha = 0;
			bullShit++;
		}

		bGame.loadGraphic(Paths.image('BG/' + leWeek.bG));
		bGame.alpha = 0.8;

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = true;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();
		difficultySelectors.visible = unlocked;

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		//txtTracklist.text = '';
		//for (i in 0...stringThing.length)
		//{
		//	txtTracklist.text += '>' + stringThing[i] + '\n';
		//}

		//txtTracklist.text = txtTracklist.text.toUpperCase();

		//txtTracklist.screenCenter(Y);
		//txtTracklist.x -= FlxG.width * 0.00;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
