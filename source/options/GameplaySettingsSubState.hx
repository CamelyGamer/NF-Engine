package options;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		MusicBeatState.updatestate("Gameplay Sttings");

		if (ClientPrefs.data.language == 'Inglish') {
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool'); //Variable type
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool');
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool');
		addOption(option);
		
		var option:Option = new Option('Auto Pause',
			"If checked, the game automatically pauses if the screen isn't on focus.",
			'autoPause',
			'bool');
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool');
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			'percent');
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int');
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			'float');
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
		}
		if (ClientPrefs.data.language == 'Spanish') {
			title = 'Ajustes de Gameplay';
			rpcTitle = 'Menu de Ajustes de Gameplay'; //for Discord Rich Presence
	
			//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
			var option:Option = new Option('ScrollBajo', //Name
				'Si está marcado, las notas bajan en lugar de subir, lo cual es bastante simple.', //Description
				'downScroll', //Save data variable name
				'bool'); //Variable type
			addOption(option);
	
			var option:Option = new Option('centrarscroll',
				'Si está marcado, sus notas se centran.',
				'middleScroll',
				'bool');
			addOption(option);
	
			var option:Option = new Option('Toque fantasma',
				"Si está marcado, no fallarás al presionar teclas\nmientras no haya notas que se puedan tocar.",
				'ghostTapping',
				'bool');
			addOption(option);
			
			var option:Option = new Option('Pausa Automatica',
				"Si está marcado, el juego se detiene automáticamente si la pantalla no está enfocada.",
				'autoPause',
				'bool');
			addOption(option);
			option.onChange = onChangeAutoPause;
	
			var option:Option = new Option('Boton de reinicio Eliminado',
				"Si está marcado, presionar Restablecer no hará nada.",
				'noReset',
				'bool');
			addOption(option);
	
			var option:Option = new Option('Volumen de sonido "HIT"',
				'Las notas divertidas hacen \"Tick! \" Cuando las golpeas."',
				'hitsoundVolume',
				'percent');
			addOption(option);
			option.scrollSpeed = 1.6;
			option.minValue = 0.0;
			option.maxValue = 1;
			option.changeValue = 0.1;
			option.decimals = 1;
			option.onChange = onChangeHitsoundVolume;
	
			var option:Option = new Option('Compensación de calificación',
				'Cambia el tiempo que tiene que golpea\nIgualmente en algun momento vas a tener que golpear',
				'ratingOffset',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 20;
			option.minValue = -30;
			option.maxValue = 30;
			addOption(option);
	
			var option:Option = new Option('¡SICK! Pulsar ventana',
				'Cambia la cantidad de tiempo que tienes\npara presionar "¡SICK!" en milisegundos.',
				'sickWindow',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 15;
			option.minValue = 15;
			option.maxValue = 45;
			addOption(option);
	
			var option:Option = new Option('Ventana de golpe "Bueno"',
				'Cambia la cantidad de tiempo que tienes\npara presionar "Bueno" en milisegundos.',
				'goodWindow',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 30;
			option.minValue = 15;
			option.maxValue = 90;
			addOption(option);
	
			var option:Option = new Option('Ventana de golpe "malo"',
				'Cambia la cantidad de tiempo que tienes\npara presionar "Malo" en milisegundos.',
				'badWindow',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 60;
			option.minValue = 15;
			option.maxValue = 135;
			addOption(option);
	
			var option:Option = new Option('Marcos seguros',
				'Cambia el número de fotogramas que tienes para tocar una nota antes o después.',
				'safeFrames',
				'float');
			option.scrollSpeed = 5;
			option.minValue = 2;
			option.maxValue = 10;
			option.changeValue = 0.1;
			addOption(option);
	
			super();
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			trace('Error No e terminado esto!!');
		}
		if (ClientPrefs.data.language == 'Mandarin') {
			title = 'Gameplay Settings';
			rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence
	
			//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
			var option:Option = new Option('Downscroll', //Name
				'If checked, notes go Down instead of Up, simple enough.', //Description
				'downScroll', //Save data variable name
				'bool'); //Variable type
			addOption(option);
	
			var option:Option = new Option('Middlescroll',
				'If checked, your notes get centered.',
				'middleScroll',
				'bool');
			addOption(option);
	
			var option:Option = new Option('Ghost Tapping',
				"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
				'ghostTapping',
				'bool');
			addOption(option);
			
			var option:Option = new Option('Auto Pause',
				"If checked, the game automatically pauses if the screen isn't on focus.",
				'autoPause',
				'bool');
			addOption(option);
			option.onChange = onChangeAutoPause;
	
			var option:Option = new Option('Disable Reset Button',
				"If checked, pressing Reset won't do anything.",
				'noReset',
				'bool');
			addOption(option);
	
			var option:Option = new Option('Hitsound Volume',
				'Funny notes does \"Tick!\" when you hit them."',
				'hitsoundVolume',
				'percent');
			addOption(option);
			option.scrollSpeed = 1.6;
			option.minValue = 0.0;
			option.maxValue = 1;
			option.changeValue = 0.1;
			option.decimals = 1;
			option.onChange = onChangeHitsoundVolume;
	
			var option:Option = new Option('Rating Offset',
				'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
				'ratingOffset',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 20;
			option.minValue = -30;
			option.maxValue = 30;
			addOption(option);
	
			var option:Option = new Option('Sick! Hit Window',
				'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
				'sickWindow',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 15;
			option.minValue = 15;
			option.maxValue = 45;
			addOption(option);
	
			var option:Option = new Option('Good Hit Window',
				'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
				'goodWindow',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 30;
			option.minValue = 15;
			option.maxValue = 90;
			addOption(option);
	
			var option:Option = new Option('Bad Hit Window',
				'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
				'badWindow',
				'int');
			option.displayFormat = '%vms';
			option.scrollSpeed = 60;
			option.minValue = 15;
			option.maxValue = 135;
			addOption(option);
	
			var option:Option = new Option('Safe Frames',
				'Changes how many frames you have for\nhitting a note earlier or late.',
				'safeFrames',
				'float');
			option.scrollSpeed = 5;
			option.minValue = 2;
			option.maxValue = 10;
			option.changeValue = 0.1;
			addOption(option);
	
			super();
		}
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
	}

	function onChangeAutoPause()
	{
		FlxG.autoPause = ClientPrefs.data.autoPause;
	}
}