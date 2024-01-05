package options;

import flixel.graphics.frames.FlxAtlasFrames;
import animateatlas.AtlasFrameMaker;
import flixel.graphics.frames.FlxFrame;
import openfl.sensors.Accelerometer;
import objects.Character;

class NewOptions extends BaseOptionsMenu
{
    public function new()
        {
            title = 'New Options !Only Inglish!';
            rpcTitle = 'In th options New !Only Inglish!'; //for Discord

            MusicBeatState.updatestate("New Options (!Only Inglish!)");

            //Here is for Options
            var option:Option = new Option('Recording Optimization',
            'Optimize all game fragments so that the recorder does not stop due to errors',
            'recordoptimization',
            'string',
            ['enabled', 'Disabled']);
            addOption(option);

            var option:Option = new Option('Overlays',
            "Nice effect but consumes resources. \nDisable it if it affects your performance",
            'overlays',
            'bool');
            addOption(option);

            var option:Option = new Option('concetration',
            'This will help you focus directly on the Game keys',
            'concetration',
            'bool');
             addOption(option);

        var option:Option = new Option('Dodge',
            'When you press the "SPACE" key while a Fire key is passing\nYou will not die in InstaKill but it will mark you as a Failed note\nThis Function is in Alpha',
            'dodge',
            'bool');
            addOption(option);

            var option:Option = new Option('sprites per second',
            "This is the sprites per second running on a model.\n'Recommended: 24'",
            'SpritesFPS',
            'Int');
            addOption(option);
            option.minValue = 1;
            option.maxValue = 60;
            option.changeValue = 1;
            option.displayFormat = '%v Frames';

            var option:Option = new Option('Notification Visibility',
            'Shows whether notifications are Visible or Invisible\nSelect the option if you want to see notifications',
            'notivisible',
            'bool');
            addOption(option);

            var option:Option = new Option('Transaction Time',
            'Determines the time it takes for Transaction animations',
            'timetrans',
            'int');
            option.minValue = 1;
            option.maxValue = 6;
            option.displayFormat = '%v s';
            //option.onChange = ;
            addOption(option);

            var option:Option = new Option('FullScreen:',
			'Change the game display to Full Screen.\n!Need Restart!',
			'fullyscreen',
			'bool');
		addOption(option);

        var option:Option = new Option('Language',
        'Game language type only in texts and some images.',
        'language',
        'string',
        ['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin' //El mandarin fue elimido en la version 1.0(Beta)*/]);
    addOption(option);

            super();
    }
}