package states;

import flixel.FlxState;
import flixel.math.FlxPoint;
import openfl.events.MouseEvent;
import flixel.input.mouse.FlxMouseButton;
import openfl.ui.MouseCursor;
import flixel.ui.FlxSpriteButton;
import options.Option;
import flixel.tweens.misc.AngleTween;
import flixel.ui.FlxButton;
import backend.WeekData;
import backend.Achievements;
import openfl.utils.Timer;
import flixel.util.FlxTimer;

import haxe.Http;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

import openfl.filters.GlowFilter;

import substates.Prompt;
import flixel.FlxState;
import objects.Notification;

import flixel.input.FlxPointer;
//import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.input.mouse.FlxMouseEvent;

import flixel.FlxObject;
////
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import flash.text.TextField;

import objects.AchievementPopup;
import objects.Notification;
import states.editors.MasterEditorMenu;
import options.OptionsState;
//import openfl.display.Internet;

class MainMenuState extends MusicBeatState
{
	//public static var psychEngineVersion:String = '0.7.1h'; //This is also used for Discord RPC
	public static var endingcorruptionVersion:String; //Update!! to Release
	public static var engineVersion:String; //update to Release
	public static var pathVersion:String;
	public static var endingFloat:Float = 2.0;
	public static var engineFloat:Float = 2.3;

	public static var bpm:Float = 0;

	public static var Mainbpm:Float = 0;

	var tipkey:FlxText;
	var tipvideo:FlxText;
	public static var curSelected:Int = 0;

	//public var camHUD:FlxCamera;
	//var controllerPointer:FlxSprite;

	public static var bg:FlxSprite;
	public var bgCG:FlxSprite;
	public var TimerEffect:FlxTimer;
	public var TimeAngle:FlxTimer;
	public var alphaeffect:FlxTimer;
	public var versionEngine:FlxText;
	public var versionShit:FlxText;

	public var angleTween:FlxTween;

	public static var outdate:Bool;

	public var settingIcon:FlxSprite;

	var Nit:Bool;

	var TextMove:FlxTimer;

	var pressedGame:Bool = false;

	//var ajustes_Button:FlxButton;

	//var optionpos:FlxPoint;

	//var mousepos:FlxPoint = new FlxPoint();
	//var _lastControllerMode:Bool = false;

	var settingsSprite:FlxSprite;
	var videoIcon:FlxSprite;

	var internet:String = '';
	static var settingButton:FlxButton;
	var videoButton:FlxButton;

	public var username:TextField;

	var languageTitle:String = '';

	var settingIcon_off:FlxSprite;

	var textShow:String = "ENGINE V";

	var indexCurret:Int = 0;

	public var ignoreWarnings = false;

	public static var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	public static var selectedSomethin:Bool;

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'statistics',
		'links'
	];

	var magenta:FlxSprite;
	var mouseOption:FlxButton;
	var bg_vineta:FlxSprite;

	public static var optionTween:FlxTween;

	public static var statusOptions:Bool = false;

	public function onEffect(Timer:FlxTimer):Void {
		if (selectedSomethin != true && !ClientPrefs.data.noneAnimations) changeItem();
		if (ClientPrefs.data.noneAnimations) OptiChangeItem();
		FlxTween.tween(bgCG, {alpha: 0}, ClientPrefs.data.timetrans, {
			onComplete: function (twn:FlxTween) {
				if (selectedSomethin != true && !ClientPrefs.data.noneAnimations) changeItem();
				if (ClientPrefs.data.noneAnimations) OptiChangeItem();
				FlxTween.tween(bgCG, {alpha: 1}, ClientPrefs.data.timetrans, {
					onComplete: function (twn:FlxTween) {
						if (selectedSomethin != true && !ClientPrefs.data.noneAnimations) changeItem();
						if (ClientPrefs.data.noneAnimations) OptiChangeItem();
					}
				});
			}
		});
	}

	public function onSetting(Timer:FlxTimer):Void {
		if (!ClientPrefs.data.noneAnimations) angleTween = FlxTween.angle(settingButton, 0, 360, 4);
		if (selectedSomethin != true && !ClientPrefs.data.noneAnimations) {
			changeItem();
		}
		if (ClientPrefs.data.noneAnimations) OptiChangeItem();
	}

	public static function changeItem(huh:Int = 0)
		{
			curSelected += huh;
	
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;

			menuItems.forEach(function(spr:FlxSprite)
				{
					spr.updateHitbox();

					if (spr.ID != curSelected && selectedSomethin == false) {
						spr.x = -240;
						if (!ClientPrefs.data.noneAnimations) {
						optionTween = FlxTween.tween(spr, {alpha: 0.08}, 0.1);
						if (spr.alpha != 0.08) spr.alpha = 0.08;
						} else {
						spr.alpha = 0.08;
						}
					}
		
					if (spr.ID == curSelected)
					{
						if (selectedSomethin == false) {					
							if (!ClientPrefs.data.noneAnimations) {	
						FlxTween.tween(spr, {x: 0}, 0.2);
						FlxTween.tween(spr, {alpha: 1}, 0.2, {
							onComplete: function(twn:FlxTween) {
								if (spr.alpha != 1) {
									spr.alpha = 1;
								}
							}
						});
					}
					if (ClientPrefs.data.noneAnimations) {
						spr.x = 0;
						spr.alpha = 1;
					}
						var add:Float = 0;
						if(menuItems.length > 4) {
							add = menuItems.length * 8;
						}
						spr.centerOffsets();
					}

					}
				});
		}

	public static function OptiChangeItem(huh:Int = 0) {
		changeItem(huh);
	}

	override function create()
	{
		textShow += ClientPrefs.data.endingEngine;

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		MusicBeatState.updatestate('MainMenu');

		FlxG.sound.music.fadeIn(3, 0.1, 0.8);

		ClientPrefs.saveSettings();

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		bgCG = new FlxSprite(-80).loadGraphic(Paths.image('OMMenu'));
		bgCG.antialiasing = ClientPrefs.data.antialiasing;
		bgCG.scrollFactor.set(0, yScroll);
		bgCG.setGraphicSize(Std.int(bgCG.width * 1.175));
		bgCG.updateHitbox();
		bgCG.screenCenter();
		bgCG.alpha = 0;
		add(bgCG);
		FlxTween.tween(bgCG, {alpha: 1}, ClientPrefs.data.timetrans);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		videoIcon = new FlxSprite(0).loadGraphic(Paths.image('icons/Menu/videoIcon'));
		videoIcon.antialiasing = ClientPrefs.data.antialiasing;
		videoIcon.scrollFactor.set(0, yScroll);
		videoIcon.updateHitbox();
		videoIcon.updateHitbox();
		videoIcon.alpha = 1;

		settingIcon = new FlxSprite(0).loadGraphic(Paths.image('icons/Menu/settingIcon'));
		settingIcon.antialiasing = ClientPrefs.data.antialiasing;
		settingIcon.scrollFactor.set(0, yScroll);
		settingIcon.updateHitbox();
		settingIcon.updateHitbox();
		settingIcon.alpha = 1;
		//add(settingIcon);

		settingButton = new FlxButton(FlxG.width - 100, 0, "", onClickSetting);
		settingButton.loadGraphicFromSprite(settingIcon);
		settingButton.scrollFactor.set();
		settingButton.screenCenter(Y);

		videoButton = new FlxButton(FlxG.width - 105, FlxG.height - 250, "", onClickVideo);
		videoButton.loadGraphicFromSprite(videoIcon);
		videoButton.scrollFactor.set();
		videoButton.visible = false;

		var scale:Float = 1;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-500, (i * 115) + offset).loadGraphic(Paths.image('mainmenu/menu_' + optionShit[i]));
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItem.alpha = 0;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (!ClientPrefs.data.noneAnimations) FlxTween.tween(menuItem, {x: -240}, ClientPrefs.data.timetrans);
			if (ClientPrefs.data.noneAnimations) FlxTween.tween(menuItem, {x: -240}, 0.001);
			FlxTween.tween(menuItem, {alpha: 0.5}, 0.2);
		}

	if (ClientPrefs.data.language == 'Spanish') add(new Notification('ID', "Tu Nombre de Usuario es: \n" + ClientPrefs.data.username, 1, camAchievement, 1));

	if (ClientPrefs.data.language == 'Inglish') add(new Notification('ID', 'Your Username is: \n' + ClientPrefs.data.username, 1, camAchievement, 1.5));

	if (ClientPrefs.data.language == 'Portuguese') add(new Notification('ID', 'Seu nome de usuário é: \n' + ClientPrefs.data.username, 1, camAchievement, 1.5));

		versionEngine = new FlxText(-100, FlxG.height - 24, 0, "");
		versionEngine.scrollFactor.set();
		versionEngine.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionEngine.alpha = 0;
		add(versionEngine);

		versionShit = new FlxText(-100, FlxG.height - 44, 0);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		versionShit.alpha = 0;
		add(versionShit);

		add(settingButton);
		add(videoButton);

		FlxTween.tween(versionEngine, {alpha: 1}, 0.5);
		FlxTween.tween(versionShit, {alpha: 1}, 0.5);
		if (!ClientPrefs.data.noneAnimations) {
			FlxTween.tween(versionShit, {x: 12}, 0.6);
		FlxTween.tween(versionEngine, {x: 12}, 0.6, {
			onComplete: function (twn:FlxTween) {
				Nit = true;
			}
		});
	}
	if (ClientPrefs.data.noneAnimations) {
		FlxTween.tween(versionEngine, {x: 12}, 0.001, {
			startDelay: 0.6,
			onComplete: function (twn:FlxTween) {
				versionShit.x = 12;
				Nit = true;
			}
		});
	}

		var AngleHome:FlxTimer = new FlxTimer();
		AngleHome.start(0.000001, onSetting, 1);

		if (!ClientPrefs.data.noneBGAnimated) {
	TimerEffect = new FlxTimer();
	TimerEffect.start(ClientPrefs.data.timetrans + ClientPrefs.data.timetrans, onEffect, 0);
		}
		if (ClientPrefs.data.noneBGAnimated) {
			bgCG.alpha = 1;
		}

	if (!ClientPrefs.data.noneAnimations) {
	TimeAngle = new FlxTimer();
	TimeAngle.start(4, onSetting, 0);
	}

	TextMove = new FlxTimer();
	TextMove.start(0.3, onGenerate, 0);

			
	#if !android
	FlxG.mouse.visible = true;
	#end
	
	#if android
	addVirtualPad(MainMenuState, A_B);
	#end

		super.create();
	}

	public function onClickSetting() {
		if (Nit == true) {
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.sound.music.fadeOut(3, 0);
			FlxTween.tween(bgCG, {alpha: 0}, ClientPrefs.data.timetrans);
			FlxTween.tween(versionEngine, {x: -500}, 1);
			FlxTween.tween(versionShit, {x: -500}, 1);
			FlxTween.tween(settingButton, {x: FlxG.width + 40}, 1);
			FlxTween.tween(videoButton, {x: FlxG.width + 40}, 1);
			menuItems.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {x: -500}, 0.5, {
						onComplete: function(twn:FlxTween) {
							MusicBeatState.switchState(new options.OptionsState());
						}
					});
					Nit = false;

				});
		}
	}

	public function onClickVideo() {
		FlxG.sound.play(Paths.sound('confirmMenu'));
		CoolUtil.browserLoad('');
	}

	function onGenerate(Timer:FlxTimer):Void {
        if (indexCurret < textShow.length) {
            versionEngine.text += textShow.charAt(indexCurret);
            indexCurret++;
        }
    }

	override function update(elapsed:Float)
	{

		if (FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle) {
			pressedGame = true;
		}

		FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);

		if (settingButton.released && !ClientPrefs.data.noneFixeds) settingButton.alpha = 0.5;

		if (settingButton.justPressed && !ClientPrefs.data.noneFixeds) settingButton.alpha = 1;

		if (videoButton.released && !ClientPrefs.data.noneFixeds) videoButton.alpha = 0.5;

		if (videoButton.justPressed && !ClientPrefs.data.noneFixeds) videoButton.alpha = 1;

		if (!ClientPrefs.data.noneFixeds) {
			changeItem();
		}
		if (ClientPrefs.data.noneAnimations) OptiChangeItem();

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (!ClientPrefs.data.noneAnimations) changeItem(-1);
				if (ClientPrefs.data.noneAnimations) OptiChangeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (!ClientPrefs.data.noneAnimations) changeItem(1);
				if (ClientPrefs.data.noneAnimations) OptiChangeItem(1);
			}

			if (FlxG.mouse.wheel >= 1) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (!ClientPrefs.data.noneAnimations) changeItem(-1);
				if (ClientPrefs.data.noneAnimations) OptiChangeItem(-1);
			}

			if (FlxG.mouse.wheel <= -1) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (!ClientPrefs.data.noneAnimations) changeItem(1);
				if (ClientPrefs.data.noneAnimations) OptiChangeItem(1);
			}

			if(FlxG.mouse.justPressedRight) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0x4CFF0000, 1);
				if (ClientPrefs.data.language == 'Spanish') {
					add(new Notification('Accion no Permitida', "No te podemos dejar Regresar por el Bien de la optimizacion del Juego. Gracias", 1, camAchievement, 1));
					//FlxG.sound.play(Paths.sound('MenuSounds/notification-1'));
				}
				if (ClientPrefs.data.language == 'Inglish') {
					//add(new Notification(camAchievement, "Action Not Allowed..", "We cannot let you return for the sake of game optimization. Thank you", 1));
					add(new Notification('Action Not Allowed..', "We cannot let you return for the sake of game optimization. Thank you", 1, camAchievement, 1));
					FlxG.sound.play(Paths.sound('notificacion-1'));
				}
				if (ClientPrefs.data.language == 'Portuguese') {
					add(new Notification('Atualmente não disponível!', "Não podemos permitir que você retorne para otimizar o jogo. Obrigado", 1, camAchievement, 1));
					FlxG.sound.play(Paths.sound('notificacion-1'));
				}
			}

			if (controls.BACK || FlxG.android.justPressed.BACK == true)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0x4CFF0000, 1);
				if (ClientPrefs.data.language == 'Spanish') {
					add(new Notification('Accion no Permitida', "No te podemos dejar Regresar por el Bien de la optimizacion del Juego. Gracias", 1, camAchievement, 1));
					//FlxG.sound.play(Paths.sound('MenuSounds/notification-1'));
				}
				if (ClientPrefs.data.language == 'Inglish') {
					//add(new Notification(camAchievement, "Action Not Allowed..", "We cannot let you return for the sake of game optimization. Thank you", 1));
					add(new Notification('Action Not Allowed..', "We cannot let you return for the sake of game optimization. Thank you", 1, camAchievement, 1));
					FlxG.sound.play(Paths.sound('notificacion-1'));
				}
				if (ClientPrefs.data.language == 'Portuguese') {
					add(new Notification('Atualmente não disponível!', "Não podemos permitir que você retorne para otimizar o jogo. Obrigado", 1, camAchievement, 1));
					FlxG.sound.play(Paths.sound('notificacion-1'));
				}
			}

		if (Nit == true) {
			if (controls.ACCEPT || MusicBeatState._virtualpad.buttonA == true)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://gamebanana.com/wips/79622');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.sound.music.fadeOut(3, 0.3);
					//FlxTween.tween(menuItems, {alpha: 0}, 1);
					if (!ClientPrefs.data.noneAnimations) {
					FlxTween.tween(bgCG, {alpha: 0}, 0.5);
					FlxTween.tween(versionEngine, {alpha: 0}, 0.5);
					FlxTween.tween(versionShit, {alpha: 0}, 0.5);
					FlxTween.tween(settingButton, {x: FlxG.width + 40}, 0.5);
					FlxTween.tween(videoButton, {x: FlxG.width + 40}, 0.5);
}

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							if (!ClientPrefs.data.noneAnimations) {
							FlxTween.tween(spr, {x: -500}, 0.5);
							FlxTween.tween(spr, {x: -500}, 0.5, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(spr, {x: -500}, 0.5);
									Nit = false;
								}
							});
						}
						if (ClientPrefs.data.noneAnimations) {
							FlxTween.tween(spr, {x: -500}, 0.001);
							FlxTween.tween(spr, {x: -500}, 0.001, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									FlxTween.tween(spr, {x: -500}, 0.001);
									Nit = false;
								}
							});
						}
						}
						else
						{
							if (!ClientPrefs.data.noneAnimations) {
							new FlxTimer().start(2, function(tmr:FlxTimer) {
								FlxTween.tween(spr, {x: -500}, 0.7,{
									onComplete: function(twn:FlxTween)
									{
										var daChoice:String = optionShit[curSelected];
		
										switch (daChoice)
										{
											case 'story_mode':
												MusicBeatState.switchState(new StoryMenuState());
											case 'freeplay':
												MusicBeatState.switchState(new FreeplayState());
											case 'statistics':
												MusicBeatState.switchState(new EstadisticsMenuState());
											case 'links':
												MusicBeatState.switchState(new LinksState());
										}
									}});
							});
						}
						if (ClientPrefs.data.noneAnimations) {
							new FlxTimer().start(0.8, function(tmr:FlxTimer) {
								FlxTween.tween(spr, {x: -500}, 0.001,{
									onComplete: function(twn:FlxTween)
									{
										var daChoice:String = optionShit[curSelected];
		
										switch (daChoice)
										{
											case 'story_mode':
												MusicBeatState.switchState(new StoryMenuState());
											case 'freeplay':
												MusicBeatState.switchState(new FreeplayState());
											case 'statistics':
												MusicBeatState.switchState(new EstadisticsMenuState());
											case 'links':
												MusicBeatState.switchState(new LinksState());
										}
									}});
							});
						}
						}
					});
				}
			}
		}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				if (TitleState.editorresult == true) {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					MusicBeatState.switchState(new MasterEditorMenu());
				}
				if (TitleState.editorresult == false) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0x4CFF0000, 1);
				if (ClientPrefs.data.language == 'Spanish') {
					openSubState(new Prompt('Esta acción no esta permitida actualmente por el Admin.\n\nPide Permisos', 0, function() {
					},
					null, ignoreWarnings));
			}
			if (ClientPrefs.data.language == 'Inglish') {
				openSubState(new Prompt('This action is not currently allowed by the Admin.\n\nRequest Permissions', 0, function() {
				},
				null, ignoreWarnings));
			}
			if (ClientPrefs.data.language == 'Portuguese') {
				openSubState(new Prompt('Esta ação não é permitida atualmente pelo administrador.\n\nSolicitar permissões', 0, function() {
				},
				null, ignoreWarnings));
			}
			}
		}
			#end
		}
		super.update(elapsed);
	}
}