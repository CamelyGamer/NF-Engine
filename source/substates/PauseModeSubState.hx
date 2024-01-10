package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

//

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import flixel.FlxObject;
import options.OptionsState;

import objects.Notification;

class PauseModeSubState extends MusicBeatSubstate
{
    var grpMenuShit:FlxTypedGroup<FlxText>;
    var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
    var diffChoices = [];
    var curSelected:Int = 0;

    var ready:Bool = false;

    var missingText:FlxText;

    var overlay:FlxSprite;

    var missingTextBG:FlxSprite;

    var skipTimeText:FlxText;
    var skipTimeTracker:Alphabet;
    var curTime:Float = Math.max(0, Conductor.songPosition);

    var pauseMusic:FlxSound;

    var item:FlxText;

    var overlaySelected:FlxSprite;

    public static var songName:String = '';

    public function new(x:Float, y:Float)
    {
        super();
        
        for (i in 0...Difficulty.list.length) {
            var diff:String = Difficulty.getString(i);
            diffChoices.push(diff);
        }
            diffChoices.push('BACK');

            pauseMusic = new FlxSound();
            if (songName != null) {
                pauseMusic.loadEmbedded(Paths.music(songName), true, true);
            } else {
                pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
            }
            pauseMusic.volume = 0;
            pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

            FlxG.sound.list.add(pauseMusic);

            var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            bg.alpha = 0;
            bg.scrollFactor.set();
            add(bg);

            var box:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('pausemenu/BoxPause'));
            box.scrollFactor.set();
            box.antialiasing = ClientPrefs.data.antialiasing;
            box.width -= 30;
            box.height -= 30;
            box.alpha = 0;
            box.screenCenter();
            box.updateHitbox();
            add(box);

            overlaySelected = new FlxSprite(0, 0).loadGraphic(Paths.image('pausemenu/OverlayOption'));
            overlaySelected.antialiasing = ClientPrefs.data.antialiasing;
            overlaySelected.alpha = 0;
            add(overlaySelected);

            var levelInfo:FlxText = new FlxText(20,15, 0, 'Notas Presionas: ' + PlayState.hitnotesong + ' | ' + PlayState.SONG.song + ' | ' + Difficulty.getString().toUpperCase(), 32);
            levelInfo.scrollFactor.set();
            levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
            levelInfo.updateHitbox();
            add(levelInfo);

            levelInfo.alpha = 0;

            levelInfo.x = FlxG.width - (levelInfo.width + 20);

            FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
            FlxTween.tween(overlaySelected, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
            FlxTween.tween(box, {alpha: 1}, 0.4, {
                onComplete: function (twn:FlxTween) {
                    ready = true;
                }
            });

            FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

            grpMenuShit = new FlxTypedGroup<FlxText>();
            add(grpMenuShit);

            missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            missingTextBG.alpha = 0.6;
            missingTextBG.visible = false;
            add(missingTextBG);

            regenMenu();
            cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

            #if android
            addVirtualPad(MainMenuState, A_B);
            #end
        }

        var holdTime:Float = 0;
        var cantUnpause:Float = 0.1;
        override function update(elapsed:Float)
            {
                cantUnpause -= elapsed;
                if (pauseMusic.volume < 0.5)
                    pauseMusic.volume +=  0.01 * elapsed;

                super.update(elapsed);

                var upP = controls.UI_UP_P;
                var downP = controls.UI_DOWN_P;
                var accepted = controls.ACCEPT;

                if (upP)
                    {
                        changeSelection(-1);
                    }
                if (downP)
                    {
                        changeSelection(1);
                    }
                
                var daSelected:String = menuItems[curSelected];

                if (ready == true) {
                if (accepted && (cantUnpause <= 0 || !controls.controllerMode))
                {

                    if (menuItems == diffChoices)
                        {
                            try{
                                if(menuItems.length - 1 != curSelected && diffChoices.contains(daSelected)) {
            
                                    var name:String = PlayState.SONG.song;
                                    var poop = Highscore.formatSong(name, curSelected);
                                    PlayState.SONG = Song.loadFromJson(poop, name);
                                    PlayState.storyDifficulty = curSelected;
                                    MusicBeatState.resetState();
                                    FlxG.sound.music.volume = 0;
                                    PlayState.changedDifficulty = true;
                                    PlayState.chartingMode = false;
                                    return;
                                }					
                            }catch(e:Dynamic){
                                trace('ERROR! $e');
            
                                var errorStr:String = e.toString();
                                if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(27, errorStr.length-1); //Missing chart
                                missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
                                missingText.screenCenter(Y);
                                missingText.visible = true;
                                missingTextBG.visible = true;
                                FlxG.sound.play(Paths.sound('cancelMenu'));
            
                                super.update(elapsed);
                                return;
                            }
                            regenMenu();
                        }

                switch (daSelected)
                {
                    case "Resume":
                        close();
                    case 'Change Difficulty':
                        menuItems = diffChoices;
                        deleteSkipTimeText();
                        regenMenu();
                    case "Restart Song":
                        restartSong();
                    case 'Options':
                        PlayState.instance.paused = true; // For lua
                        PlayState.instance.vocals.volume = 0;
                        MusicBeatState.switchState(new options.OptionsState());
                        if(ClientPrefs.data.pauseMusic != 'None')
                        {
                            FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
                            FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
                            FlxG.sound.music.time = pauseMusic.time;
                        }
                        OptionsState.onPlayState = true;
                    case "Exit to menu":
                        #if desktop DiscordClient.resetClientID(); #end
                        PlayState.deathCounter = 0;
                        PlayState.seenCutscene = false;
                        PlayState.statusGame = false;
    
                        Mods.loadTopMod();
                        if(PlayState.isStoryMode) {
                            MusicBeatState.switchState(new StoryMenuState());
                        } else {
                            MusicBeatState.switchState(new FreeplayState());
                        }
                        PlayState.cancelMusicFadeTween();
                        PlayState.changedDifficulty = false;
                        PlayState.chartingMode = false;
                        FlxG.camera.followLerp = 0;
                }
            }
        }
        }

                function deleteSkipTimeText()
                    {
                        if(skipTimeText != null)
                        {
                            skipTimeText.kill();
                            remove(skipTimeText);
                            skipTimeText.destroy();
                        }
                        skipTimeText = null;
                        skipTimeTracker = null;
                    }

                    public static function restartSong(noTrans:Bool = false)
                        {
                            PlayState.instance.paused = true; // For lua
                            FlxG.sound.music.volume = 0;
                            PlayState.instance.vocals.volume = 0;
                            MusicBeatState.resetState();
                        }

                        override function destroy()
                            {
                                pauseMusic.destroy();

                                super.destroy();
                            }

                        function changeSelection(change:Int = 0):Void
                            {
                                curSelected += change;

                                FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
                        
                                if (curSelected < 0)
                                    curSelected = menuItems.length - 1;
                                if (curSelected >= menuItems.length)
                                    curSelected = 0;
                        
                                var bullShit:Int = 0;
                        
                                for (item in grpMenuShit.members)
                                {
                                    item.ID = bullShit - curSelected;
                                    bullShit++;
                        
                                    item.alpha = 0.4;
                        
                                    if (item.ID == 0)
                                    {
                                        item.alpha = 1;
                                        item.screenCenter(X);

                                        overlaySelected.setGraphicSize(item.width + 25, item.height + 25);
                                        overlaySelected.y = item.y + 3;
                                        overlaySelected.screenCenter(X);
                                    }
                        
                                }
                            }

            function regenMenu():Void {
                for (i in 0...grpMenuShit.members.length) {
                    var obj = grpMenuShit.members[0];
                    obj.kill();
                    grpMenuShit.remove(obj, true);
                    obj.destroy();
                }

                var offset:Float = 108 - (Math.max(menuItems.length, 4) - 4) * 80;
                for (i in 0...menuItems.length) {
                    item = new FlxText(220, i * 60 + 200, menuItems[i], true);
                    item.setFormat(Paths.font("vcr.ttf"), 44);
                    item.ID = i;
                    item.alpha = 0;
                    item.screenCenter(X);
                    grpMenuShit.add(item);
                }
                curSelected = 0;
                changeSelection();
            }
}