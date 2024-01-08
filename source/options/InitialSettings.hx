package options;

import backend.ClientPrefs;

class InitialSettings extends BaseOptionsMenu
{
    var antialiasingOption:Int;
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