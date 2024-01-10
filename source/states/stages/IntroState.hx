package states.stages;

//import hxcodec.flixel.FlxVideo;

import flixel.FlxState;
import flixel.FlxSprite;
import openfl.media.Video;
import openfl.events.Event;
import sys.FileSystem;
#if VIDEOS_ALLOWED 
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

class IntroState extends FlxState{

//    var video:VideoHandler = new VideoHandler();
    var subtitles:FlxText;

   // var videos:FlxVideo;

    override public function create():Void {
        //Crea una nueva instancia de Video

        //video = new Video();
        //video.x = 0;
        //video.y = 0;

        //videos = new FlxVideo("assets/videos/Intro.mp4");

        subtitles = new FlxText(0, 0, FlxG.width, "Video is Running...\nPRESS Enter to Skip!!", 48);
		//if(FlxG.random.bool(0.1)) subtitles.text += '\nBITCH.'; //meanie
		subtitles.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		subtitles.scrollFactor.set();
		subtitles.borderSize = 2;
		add(subtitles);
		//subtitles.screenCenter();

        /*video.play('assets/videos/Intro.mp4', false);
        video.autoResize = true;
        //video.x = 0;
        //video.y = 0;
        //add(video);
        //video.screenCenter();
        video.onEndReached.add(function()
			{
				video.dispose();
				MusicBeatState.switchState(new states.TitleState());
				return;
			}, true);

        //Carga un archivo de video (remplaza "Video.mp4" con el video correspondiente)
        //video.load("assets/video/Intro.mp4");*/

        #if VIDEOS_ALLOWED
        //inCutscene = true;

        var filepath:String = Paths.video('');
        #if sys
        if(!FileSystem.exists(filepath))
        #else
        if(!OpenFlAssets.exists(filepath))
        #end
        {
            FlxG.log.warn('Couldnt find video file: ' + filepath);
            MusicBeatState.switchState(new states.TitleState());
            return;
        }

        var video:VideoHandler = new VideoHandler();
            #if (hxCodec >= "3.0.0")
            // Recent versions
            video.play('assets/videos/Intro.mp4');
            video.onEndReached.add(function()
            {
                video.dispose();
                MusicBeatState.switchState(new states.TitleState());
                return;
            }, true);
            #else
            // Older versions
            video.playVideo(filepath);
            video.finishCallback = function()
            {
                MusicBeatState.switchState(new states.TitleState());
                return;
            }
            #end
        #else
        FlxG.log.warn('Platform not supported!');
        MusicBeatState.switchState(new states.TitleState());
        return;
        #end
    }

    override function update(elapsed:Float) {

        var subtitle2:Float = 0;
        if(subtitles.visible)
            {
                subtitle2 += 180 * elapsed;
                subtitles.alpha = 1 - Math.sin((Math.PI * subtitle2) / 180);
            }

        if (FlxG.keys.justPressed.ENTER) {
         //   video.pause();
            FlxTween.tween(this, {alpha: 0}, 5, {
                onComplete: function (twn:FlxTween) {
            MusicBeatState.switchState(new states.TitleState());
        }
    });
        }
    }
}