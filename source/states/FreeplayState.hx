package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

import objects.HealthIcon;
import states.editors.ChartingState;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

#if MODS_ALLOWED
import sys.FileSystem;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var weekName:String = '';

	var bgSprite:FlxSprite;

	var status:Bool = false;

	var spriteName:String;

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	public static var leText:String;

	public static var sizeJust:Int;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var schoolBG:BGSprite;

	public var SONG:SwagSong = null;

	var black:FlxSprite;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var MISS:Array<String>;

	override function create()
	{

		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		if (ClientPrefs.data.music == 'Hallucination') FlxG.sound.playMusic(Paths.music('Hall'), 0);

		if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('SelectedMusic'));

		FlxG.sound.music.fadeIn(2, 0, 0.9);

		MusicBeatState.updatestate('FreePlay');
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			var leNameWeek:Array<String> = [];

			weekName = leWeek.weekName;

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		bgSprite = new FlxSprite(0, 0);
		bgSprite.screenCenter();
		add(bgSprite);

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:FlxText = new FlxText(90, FlxG.height - 120, songs[i].songName, 60);
			songText.ID = i;
			//FlxTween.tween(songText, {x: 90}, 3);
			grpSongs.add(songText);

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			//add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(0, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.screenCenter(X);

		scoreBG = new FlxSprite(0, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.screenCenter(X);
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.screenCenter(X);
		add(diffText);

		add(scoreText);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);

		black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.screenCenter();
		black.alpha = 1;
		black.scrollFactor.set();
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		changeSelection();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		if (ClientPrefs.data.language == 'Inglish') {
		#if PRELOAD_ALL
		leText = "Press C to listen to the Song";
		sizeJust = 16;
		#else
		leText = "Press CTRL to open the Gameplay Changers Menu";
		size = 18;
		#end
		}
		if (ClientPrefs.data.language == 'Spanish') {
			#if PRELOAD_ALL
			leText = "Presione C para escuchar la canción";
			sizeJust = 16;
			#else
			leText = "Presione CTRL para abrir el menú de cambios de juego";
			size = 18;
			#end
		}
		if (ClientPrefs.data.language == 'Mandarin') {
			#if PRELOAD_ALL
			leText = "按 C 聆听歌曲/按 RESET 重置您的分数和准确性。";
			sizeJust = 16;
			#else
			leText = "按 CTRL 键打开游戏更改​​菜单/按 RESET 重置您的分数和准确度。";
			size = 18;
			#end
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			#if PRELOAD_ALL
			leText = "Pressione C para ouvir a música";
			sizeJust = 16;
			#else
			leText = "Pressione CTRL para abrir o menu Gameplay Changers";
			size = 18;
			#end
		}

		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, sizeJust);
		text.setFormat(Paths.font("vcr.ttf"), sizeJust, FlxColor.WHITE, CENTER);
		text.screenCenter(X);
		text.scrollFactor.set();
		add(text);

		leftArrow = new FlxSprite(0).loadGraphic(Paths.image('icons/Menu/leftArrow'));
		leftArrow.screenCenter(Y);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		add(leftArrow);

		rightArrow = new FlxSprite().loadGraphic(Paths.image('icons/Menu/rightArrow'));
		rightArrow.screenCenter(Y);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.x = FlxG.width - rightArrow.width - 5;
		add(rightArrow);
		
		updateTexts();
		add(black);
		FlxTween.tween(black, {alpha: 0}, 1);

		#if android
		addVirtualPad(FULL, A_B_C);
		#end

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{

		bgSprite.loadGraphic(Paths.image('BGFreeplay/' + songs[curSelected].songName));
		bgSprite.visible = true;
		bgSprite.setGraphicSize(FlxG.width + 5, FlxG.height + 5);
		bgSprite.screenCenter();

		if (controls.UI_RIGHT_P) {
			FlxTween.tween(rightArrow, {alpha: 1}, 0.2, {
				ease: FlxEase.circInOut,
				type: BACKWARD
			});
			FlxTween.tween(rightArrow, {x: FlxG.width - rightArrow.width - 5 + 10}, 0.3, {
				ease: FlxEase.circInOut,
				type: BACKWARD
			});
		}
		if (controls.UI_LEFT_P) {
			FlxTween.tween(leftArrow, {alpha: 1}, 0.2, {
				ease: FlxEase.circInOut,
				type: BACKWARD
			});
			FlxTween.tween(leftArrow, {x: 0 + 10}, 0.3, {
				ease: FlxEase.circInOut,
				type: BACKWARD
			});
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		if (ClientPrefs.data.language == 'Inglish') {
		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		}
		if (ClientPrefs.data.language == 'Spanish') {
			scoreText.text = 'MEJOR MARCA PERSONAL: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			scoreText.text = 'MELHOR PESSOAL: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		}
		if (ClientPrefs.data.language == 'Mandarin') {
			scoreText.text = '个人最佳得分： ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		}
		positionHighscore();

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if(FlxG.keys.justPressed.HOME)
			{
				curSelected = 0;
				changeSelection();
				holdTime = 0;	
			}
			else if(FlxG.keys.justPressed.END)
			{
				curSelected = songs.length - 1;
				changeSelection();
				holdTime = 0;	
			}
			if (controls.UI_UP_P)
			{
				changeDiff(-1);
				_updateSongLastDifficulty();
			}
			if (controls.UI_DOWN_P)
			{
				changeDiff(1);
				_updateSongLastDifficulty();
			}

			if(controls.UI_LEFT || controls.UI_RIGHT)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_RIGHT ? -shiftMult : shiftMult));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
			}
		}

		if (controls.UI_LEFT_P)
		{
			changeSelection(-shiftMult);
			holdTime = 0;
		}
		else if (controls.UI_RIGHT_P)
		{

			changeSelection(shiftMult);
			holdTime = 0;
		}

		if (controls.BACK || FlxG.mouse.justPressedRight)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'), 0);

			if (ClientPrefs.data.music == 'Hallucination') FlxG.sound.playMusic(Paths.music('Hallucination'), 0);

			if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'), 0);
			FlxG.sound.music.fadeOut(2, 0);
			MusicBeatState.switchState(new MainMenuState());
		}
		else if(FlxG.keys.justPressed.SPACE || MusicBeatState._virtualpad.buttonC.justPressed)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				//FlxG.sound.playMusic(Paths.music('StateHorror2'), 0); //Error de confucion de Sonidos
				FlxG.sound.music.fadeOut(2, 0);
				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (controls.ACCEPT || MusicBeatState._virtualpad.buttonA.justPressed)
		{
			persistentUpdate = false;
			FlxG.sound.music.fadeOut(2, 0);
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(27, errorStr.length-1); //Missing chart
				if (ClientPrefs.data.language == 'Inglish') {
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				}
				if (ClientPrefs.data.language == 'Spanish') {
					missingText.text = 'ERROR AL CARGAR EL CHART:\n$errorStr';
				}
				if (ClientPrefs.data.language == 'Portuguese') {
					missingText.text = 'ERRO AO CARREGAR TABELA:\n$errorStr';
				}
				if (ClientPrefs.data.language == 'Mandarin') {
					missingText.text = '加载图表时出错：\n$errorStr';
				}
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			FlxTween.tween(black, {alpha: 1}, 1, {
				onComplete: function (twn:FlxTween) {

					if (songs[curSelected].songName != "Forgetful formatting" || songs[curSelected].songName != "Corrupted past" || songs[curSelected].songName != "Lethal code" || songs[curSelected].songName != "Misguided concern")  {
						LoadingState.loadAndSwitchState(new PlayState());
					}
					if (songs[curSelected].songName == "Forgetful formatting" || songs[curSelected].songName == "Corrupted past" || songs[curSelected].songName == "Lethal code" || songs[curSelected].songName == "Misguided concern") {
						LoadingState.pixel = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			});

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
			#if MODS_ALLOWED
			DiscordClient.loadModRPC();
			#end
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var bgText:String = '';

		var newColor:Int = songs[curSelected].color;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			bullShit++;
			if (item.ID != curSelected) {
				item.alpha = 0;
			}
			if (item.ID == curSelected) {
				item.alpha = 1;
				item.screenCenter(X);
			}
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore() {
		scoreText.screenCenter(X);
		scoreBG.screenCenter(X);
		scoreBG.screenCenter(X);
		diffText.screenCenter(X);
		diffText.screenCenter(X);

		if (songs[curSelected].songName != "Forgetful formatting" || songs[curSelected].songName != "Corrupted past" || songs[curSelected].songName != "Lethal code" || songs[curSelected].songName != "Misguided concern")  {
			scoreText.font = "vcr.ttf"; //size 32
			diffText.font = "vcr.ttf"; //Size 24 

			scoreText.size = 32;
			diffText.size = 24;

			scoreText.color = FlxColor.WHITE;
			diffText.color = FlxColor.WHITE;

			for (item in grpSongs.members)
				{
					if (item.ID == curSelected) {
						item.color = FlxColor.WHITE;
					}
				}
		}
		if (songs[curSelected].songName == "Forgetful formatting" || songs[curSelected].songName == "Corrupted past" || songs[curSelected].songName == "Lethal code" || songs[curSelected].songName == "Misguided concern") {
			scoreText.font = "pixel.otf";
			diffText.font = "pixel.otf";

			scoreText.size = 26;
			diffText.size = 18;

			if (songs[curSelected].songName == "Forgetful formatting") {
			scoreText.color = FlxColor.BLACK;
			diffText.color = FlxColor.BLACK;
			
			for (item in grpSongs.members)
				{
					if (item.ID == curSelected) {
						item.color = FlxColor.BLACK;
					}
				}
			}
		}
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(lerpSelected, curSelected, FlxMath.bound(elapsed * 9.6, 0, 1));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:FlxText = grpSongs.members[i];
			item.visible = item.active = true;
			if (item.ID == curSelected) {
			item.screenCenter(X);
			}

			var icon:HealthIcon = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}