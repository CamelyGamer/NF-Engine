package options;

import states.MainMenuState;
import backend.StageData;
import flixel.util.FlxTimer;
import flixel.ui.FlxButton;
//import objects.Notification;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		//'Note Colors',
		//'Controls',
		'Adjust',
		'Graphics',
		'Visuals UI',
		'Optimizations',
		'Gameplay',
		'All Options',
		#if DEMO_MODE
		'Debug Config'
		#end
	];
	
	private var grpOptions:FlxTypedGroup<FlxText>;
	private static var curSelected:Int = 0;
	public static var TipText:FlxText;
	public static var TipText2:FlxText;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	public var reloadIcon:FlxSprite;
	public var reloadButton:FlxButton;

	public var controlsIcon:FlxSprite;
	public var controlsButton:FlxButton;

	public function onSetting(Timer:FlxTimer) {
		FlxTween.angle(reloadButton, 0, 360, 4);
	}

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			/*case 'Controls':
				openSubState(new options.ControlsSubState());*/
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals UI':
				openSubState(new options.VisualsUISubState());
			case 'Optimizations':
				openSubState(new options.OptimizationsSubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Debug Config':
				openSubState(new options.InitialSettings());
			case 'Adjust':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'All Options':
				openSubState(new options.AllOptions());
			}
}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	var TimerEffect:FlxTimer;
	var TimerEffectvineta:FlxTimer;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(0, 0, FlxColor.WHITE);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0x7b7d0000;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);
		
		controlsIcon = new FlxSprite(0).loadGraphic(Paths.image('icons/Menu/controlsIcon'));
		controlsIcon.antialiasing = ClientPrefs.data.antialiasing;
		controlsIcon.updateHitbox();
		controlsIcon.alpha = 0;

		reloadIcon = new FlxSprite(0).loadGraphic(Paths.image('icons/Menu/reloadIcon'));
		reloadIcon.antialiasing = ClientPrefs.data.antialiasing;
		reloadIcon.updateHitbox();
		reloadIcon.alpha = 0;

		FlxTween.tween(reloadIcon, {alpha: 1}, 2);
		FlxTween.tween(controlsIcon, {alpha: 1}, 2);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:FlxText = new FlxText(50, 300, 0, options[i], 60);
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.screenCenter(X);
			optionText.ID = i;

			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<]', true);
		add(selectorRight);

		controlsButton = new FlxButton(FlxG.width - 100, FlxG.height - 100, "", onClickControls);
		controlsButton.loadGraphicFromSprite(controlsIcon);
		controlsButton.scrollFactor.set();

		reloadButton = new FlxButton(FlxG.width - 100, FlxG.height - 200, "", onClickReload);
		reloadButton.loadGraphicFromSprite(reloadIcon);
		reloadButton.scrollFactor.set();

		changeSelection();
		//ClientPrefs.saveSettings();

			add(controlsButton);
			add(reloadButton);

		FlxTween.angle(reloadButton, 0, 360, 3, {
			ease: FlxEase.circInOut,
			type: LOOPING
		});

		MusicBeatState.updatestate('Options Menu');

		FlxTween.angle(controlsButton, -30, 30, 2, {
			ease: FlxEase.expoInOut,
			type: PINGPONG
		});

		#if android
		addVirtualPad(UP_DOWN, B_A);
		#end

		super.create();
	}

	public function onClickControls() {
		MusicBeatState.switchState(new android.AndroidControlsMenu());
	}

	public function onClickReload() {
		ClientPrefs.loadPrefs();
		ClientPrefs.saveSettings();
		MusicBeatState.switchState(new options.OptionsState());

		FlxG.resizeWindow(ClientPrefs.data.width, ClientPrefs.data.height);
		FlxG.resizeGame(ClientPrefs.data.width, ClientPrefs.data.height);

		Lib.application.window.opacity = ClientPrefs.data.windowOpacity
;
		trace('Se Forzo la Carga de los ajustes!!');
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controlsButton.released) {
			controlsButton.alpha = 0.3;
		}
		if (controlsButton.justPressed) {
			controlsButton.alpha = 1;
		}

		if (reloadButton.released) {
			reloadButton.alpha = 0.3;
		}
		if (reloadButton.justPressed) {
			reloadButton.alpha = 1;
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.music.fadeOut(2, 0);
			//FlxTween.tween(grpOptions, {alpha: 0}, 5);
			//FlxTween.tween(option, {alpha: 0.5}, 5);
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}
		
		if (controls.ACCEPT){
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.ID = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.ID == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.saveSettings();
		super.destroy();
	}
}