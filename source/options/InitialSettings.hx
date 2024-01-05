package options;

import flixel.graphics.frames.FlxAtlasFrames;
import animateatlas.AtlasFrameMaker;
import flixel.graphics.frames.FlxFrame;
import openfl.sensors.Accelerometer;
import objects.Character;
import backend.ClientPrefs;

class InitialSettings extends BaseOptionsMenu
{
    var antialiasingOption:Int;
	var boyfriend:Character = null;
    public function new()
        {
            ClientPrefs.loadPrefs();
            title = 'Initial Settings';
            rpcTitle = 'Initial Settings Menu'; //for Discord Rich Presence

            MusicBeatState.updatestate("Initial Settings");
    
            //I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
            var option:Option = new Option('Language', //Name
                'Change all type of language in the game.', //Description
                'language', //Save data variable name
                'string',
                ['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin'*/]); //Variable type
            addOption(option);
            ClientPrefs.loadPrefs();
    
            var option:Option = new Option('Fullscreen',
                'Disable this if recording as this interrupts.',
                'fullyscreen',
                'bool');
            addOption(option);
            ClientPrefs.loadPrefs();

            var option:Option = new Option('Window Opacity:',
            'Change the opacity of the window to your liking. \nDoes not work with full screen',
            'windowOpacity',
            'float');
            option.maxValue = 1;
            option.minValue = 0.1;
            addOption(option);


            var option:Option = new Option('sprites per second',
            "This is the sprites per second running on a model.\n'Recommended: 24'",
            'SpritesFPS',
            'int');
            addOption(option);
            antialiasingOption = optionsArray.length-1;
            option.minValue = 1;
            option.maxValue = ClientPrefs.data.framerate;
            option.changeValue = 1;
            option.displayFormat = '%v Frames';
            
            #if !DEMO_MODE
            var option:Option = new Option('Update Support',
                "Add a support to the game so that it updates itself.\nThis function is disabled in your version",
                'Update_Support',
                'bool');
            addOption(option);
            ClientPrefs.loadPrefs();
    
            var option:Option = new Option('Internet Data',
                'Using the Internet\nthis is used to download and install update files or profiles.\n!This function is disabled in your version!',
                'Internet',
                'string',
                [/*'Always','Only in Menus','Only in Matches',*/'Disabled']);
            addOption(option);
            #end
            ClientPrefs.loadPrefs();

            var option:Option = new Option('Recording Optimization',
            'Optimize all game fragments so that the recorder does not stop due to errors',
            'recordoptimization',
            'string',
            ['enabled', 'Disabled']);
            addOption(option);

            var option:Option = new Option('Notification Visibility',
            'Shows whether notifications are Visible or Invisible\nSelect the option if you want to see notifications',
            'notivisible',
            'bool');
            addOption(option);
    
            super();
        }
}