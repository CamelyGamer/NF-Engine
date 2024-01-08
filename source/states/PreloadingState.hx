package states;

import states.stages.IntroState;
import flixel.FlxSubState;

import options.OptionsState;

class PreloadingState extends MusicBeatState
{
    public static var WarnText2:FlxText;
    public var bg:FlxSprite;
    public static var WarnTextBack:FlxText;
    public var client:Bool = ClientPrefs.data.downloadMode;
    var Press:Bool = false;

    override function create() {
        super.create();

        ClientPrefs.loadPrefs();

        if (ClientPrefs.data.Welcome == true) {
            MusicBeatState.switchState(new TitleState());
        }

        bg = new FlxSprite().loadGraphic(Paths.image('BGMenu/TitleMenu'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.alpha = 0;
        add(bg);
        FlxTween.tween(bg, {alpha: 1}, 6);

        WarnText2 = new FlxText(0, 0, FlxG.width,
            "Welcome to Ending Corruption\n\nBefore we start we need you to configure some things.\n\nPress 'Y' to set or 'N' to Skip",32);
        WarnText2.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
        WarnText2.screenCenter();
        WarnText2.alpha = 0;
        add(WarnText2);
        FlxTween.tween(WarnText2, {alpha: 1}, 4);

        WarnTextBack = new FlxText(0, 0, FlxG.width,"Press [N] to Start Game!\n\nPreferences are loaded at startup",32);
        WarnTextBack.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
        WarnTextBack.screenCenter();
        WarnTextBack.alpha = 0;
    }

    public function dowloadState() {
        if (client == true) {
            MusicBeatState.switchState(new TitleState());
        }
        if (client == false) {
            MusicBeatState.switchState(new states.editors.UpdatingState());
            client = true;
        }
    }

    override function update(elapsed:Float)
    {
            if (FlxG.keys.justPressed.Y) {
                ClientPrefs.data.Welcome = true;
                  ClientPrefs.saveSettings();
                  ClientPrefs.loadPrefs();
                  Press = true;
                  FlxG.sound.play(Paths.sound('confirmMenu'));
                        FlxTween.tween(WarnText2, {alpha: 0}, 4, {
                            onComplete: function (twn:FlxTween) {
                                openSubState(new options.InitialSettings());
                                add(WarnTextBack);
                                FlxTween.tween(WarnTextBack, {alpha: 1}, 6);
                            }
                        });

        }
        
            if (FlxG.keys.justPressed.N) {
            ClientPrefs.data.Welcome = true;
            ClientPrefs.saveSettings();
            ClientPrefs.loadPrefs();
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxTween.tween(WarnTextBack, {alpha: 0}, 5);

            if (WarnText2.alpha == 1) {
            FlxTween.tween(WarnText2, {alpha: 0}, 5, {
                onComplete: function (twn:FlxTween) {
                    dowloadState();
                }
            });
        }

            FlxTween.tween(bg, {alpha: 0}, 5, {
                onComplete: function (twn:FlxTween) {
                    ClientPrefs.loadPrefs();
                    dowloadState();
                }
            });
        }
        super.update(elapsed);
    }
}