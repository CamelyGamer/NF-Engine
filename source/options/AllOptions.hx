package options;

class AllOptions extends BaseOptionsMenu {
    public function new() {
        if (ClientPrefs.data.language == 'Inglish') {
            title = 'All Options';
            rpcTitle = 'All Options Menu'; //for Discord

            MusicBeatState.updatestate("New Options");

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

            var option:Option = new Option('HUD effect',
			'If this option is unchecked,\nthe Alpha HUD effect will be eliminated.',
			'alphahud',
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
            'int');
            addOption(option);
            option.minValue = 1;
            option.maxValue = ClientPrefs.data.framerate;
            option.changeValue = 1;
            option.displayFormat = '%v Frames';

            var option:Option = new Option('Notification Visibility',
            'Shows whether notifications are Visible or Invisible\nSelect the option if you want to see notifications',
            'notivisible',
            'bool');
            addOption(option);

            var option:Option = new Option('FullScreen:',
			'Change the game display to Full Screen.\n!Need Restart!',
			'fullyscreen',
			'bool');
		    addOption(option);

            var option:Option = new Option('Width Windows',
            "Sets the Initial 'Width'\n!Needs Reset!",
            'width',
            'int');
            option.minValue = 1024;
            option.maxValue = 3840;
            option.scrollSpeed = 100;
            option.displayFormat = '%v px';
        addOption(option);
    
        var option:Option = new Option('Height Windows',
            "Sets the Initial 'Height'\n!Needs Reset!",
            'height',
            'int');
            option.minValue = 600;
            option.maxValue = 2160;
            option.scrollSpeed = 100;
            option.displayFormat = '%v px';
        addOption(option);

            var option:Option = new Option('Window Opacity:',
            'Change the opacity of the window to your liking. \nDoes not work with full screen',
            'windowOpacity',
            'float');
            option.maxValue = 1;
            option.minValue = 0.1;
            addOption(option);

            var option:Option = new Option('Language',
            'Game language type only in texts and some images.',
            'language',
            'string',
            ['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin' //El mandarin fue elimido en la version 1.0(Beta)*/]);
            addOption(option);

            var option:Option = new Option('Music:',
            'The music of the game',
            'music',
            'string',
            ['TerminalMusic', 'Hallucination', 'Disabled']);
            option.onChange = music;
            addOption(option);
        }



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



        if (ClientPrefs.data.language == 'Spanish') {

            title = 'Todas las opciones';
            rpcTitle = 'Menu de Todas las Opciones'; //for Discord

            var option:Option = new Option('Optimizacion de Grabacion',
            'Optimiza todos los fragmentos del juego para que no se pause o de error',
            'recordoptimization',
            'string',
            ['enabled', 'Disabled']);
            addOption(option);

            var option:Option = new Option('Effecto HUD',
            'Si esta opción no está marcada,\nse eliminará el efecto HUD alpha.',
            'alphahud',
            'bool');
        addOption(option);

        var option:Option = new Option('Concentracion',
            'Esto te sevira para concentrarte directamente en las teclas de Juego',
            'concetration',
            'bool');
        addOption(option);

        var option:Option = new Option('Esquivar',
            'Al presionar la tecla "ESPACIO" Mientras esta pasando una tecla de Disparo\nNo moriras en InstaKill pero si te marcara como nota Fallada\nEsta Funcion esta en Alpha',
            'dodge',
            'bool');
        addOption(option);

        var option:Option = new Option('Overlays',
        "Bonito efecto pero consume recursos. \nDesactivalo si afecta tu rendimiento",
        'overlays',
        'bool');
    addOption(option);

    var option:Option = new Option('sprites per second',
    "This is the sprites per second running on a model.\n'Recommended: 24'",
    'SpritesFPS',
    'int');
    addOption(option);
    option.minValue = 1;
    option.maxValue = ClientPrefs.data.framerate;
    option.changeValue = 1;
    option.displayFormat = '%v Frames';

    
		var option:Option = new Option('Visibilidad de notificación',
		'Muestra si las notificaciones son visibles o invisibles\nSeleccione la opción si desea ver las notificaciones',
		'notivisible',
		'bool');
		addOption(option);

        
		var option:Option = new Option('Width Windows',
        "Establece el 'Width' Inicial\n!¡Necesita Reinicio¡!",
        'width',
        'int');
        option.minValue = 1024;
        option.maxValue = 3840;
        option.scrollSpeed = 100;
        option.displayFormat = '%v px';
    addOption(option);

    var option:Option = new Option('Height Windows',
        "Establece el 'Height' Inicial\n!¡Necesita Reinicio¡!",
        'height',
        'int');
        option.minValue = 600;
        option.maxValue = 2160;
        option.scrollSpeed = 100;
        option.displayFormat = '%v px';
    addOption(option);

    var option:Option = new Option('Pantalla completa:',
        'Cambia la visualización del juego a Pantalla completa.\n!¡Necesita reiniciar!',
        'fullyscreen',
        'bool');
    addOption(option);

    var option:Option = new Option('Opacidad de Ventana:',
    'Cambia la opacidad de la ventana a tu gusto \nNo funciona en pantalla Completa',
    'windowOpacity',
    'float');
    option.maxValue = 1;
    option.minValue = 0.1;
    option.changeValue = 0.1;
    addOption(option);

    var option:Option = new Option('Idioma',
    'Tipo de idioma del juego solo en textos y algunas imágenes.',
    'language',
    'string',
    ['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin' //El mandarin fue elimido en la version 1.0(Beta)*/]);
addOption(option);

var option:Option = new Option('Music:',
'The music of the game',
'music',
'string',
['TerminalMusic', 'Hallucination', 'Disabled']);
option.onChange = music;
addOption(option);
        }



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



        if (ClientPrefs.data.language == 'Portuguese') {

            title = '?';
            rpcTitle = '?'; //for Discord

            var option:Option = new Option('Visibilidade de notificação',
            'Mostra se as notificações estão visíveis ou invisíveis\nSelecione a opção se quiser ver as notificações',
            'notivisible',
            'bool');
            addOption(option);

            var option:Option = new Option('Linguagem',
			'Tipo de linguagem do jogo apenas em textos e algumas imagens.',
			'language',
			'string',
			['Spanish', 'Inglish', 'Portuguese'/*, 'Mandarin' //El mandarin fue elimido en la version 1.0(Beta)*/]);
		addOption(option);

        var option:Option = new Option('Efeito HUD',
        'Se esta opção estiver desmarcada,\no efeito Alpha HUD será eliminado.',
        'alphahud',
        'bool');
    addOption(option);

    var option:Option = new Option('sprites per second',
    "This is the sprites per second running on a model.\n'Recommended: 24'",
    'SpritesFPS',
    'int');
   // option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
    addOption(option);
    //antialiasingOption = optionsArray.length-1;
    option.minValue = 1;
    option.maxValue = ClientPrefs.data.framerate;
    option.changeValue = 1;
    option.displayFormat = '%v Frames';


    var option:Option = new Option('Music:',
    'The music of the game',
    'music',
    'string',
    ['TerminalMusic', 'Hallucination', 'Disabled']);
    option.onChange = music;
    addOption(option);
        }

        super();
    }

    public function music() {
        var music = ClientPrefs.data.music;

        if (music != 'Disabled') FlxG.sound.playMusic(Paths.music(music));
        if (music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'));
    }
}