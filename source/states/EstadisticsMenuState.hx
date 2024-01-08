package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
//

import states.PlayState;

class EstadisticsMenuState extends MusicBeatState {

    var BaseText:FlxText;
    var note:String = '\n\n\n\n\n\n\n\n\n\n\n\n\n\n';
    var Notetext:FlxText;

    override function create() {
        super.create();

        MusicBeatState.updatestate("Stadistics Menu");

        var bg:FlxSprite = new FlxSprite().makeGraphic(0, 0, FlxColor.BLACK);
        add(bg);

        if (ClientPrefs.data.language == 'Spanish') {
        BaseText = new FlxText(0, 0, FlxG.width,
           'Estadisticas: \n\nNotas Presionadas: ' + PlayState.hitnotesong + ' Notas\n\nNotas Falladas: ' + PlayState.missNotesong + ' Fallas\n\nMuertes: ' + PlayState.deaths + ' Muertes\n\nPuntaje Total: ' + PlayState.scoresTotal + ' Puntos\n\nPUNTOS: ' + PlayState.pointsWin + ' puntos',
            32);
        Notetext = new FlxText(0, 0, FlxG.width,
            note + '!!ESTAS ESTADISTICAS SON TEMPORABLES!!\nLAS ESTADISTICAS SE REINICIAN AL SALIR',
        32);
        }
        if (ClientPrefs.data.language == 'Inglish') {
            BaseText = new FlxText(0, 0, FlxG.width,
           'Statistics: \n\nPressed Notes: ' + PlayState.hitnotesong + ' Notes\n\nFailed Notes: ' + PlayState.missNotesong + ' Misses\n\nDeaths: ' + PlayState.deaths + ' deaths\n\nTotal score: ' + PlayState.scoresTotal + ' Points',
            32);
        }
        if (ClientPrefs.data.language == 'Portuguese') {
            BaseText = new FlxText(0, 0, FlxG.width,
           'Estatisticas: \n\nNotas pressionadas: ' + PlayState.hitnotesong + ' Notas\n\nNotas com falha: ' + PlayState.missNotesong + ' Falhas\n\nMortes: ' + PlayState.deaths + ' Mortes\n\nPontuação total: ' + PlayState.scoresTotal + ' Pontos',
            32);
        }
        BaseText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        BaseText.screenCenter();
        add(BaseText);

        Notetext.setFormat("nullFont.ttf", 32, FlxColor.RED, CENTER, OUTLINE_FAST, FlxColor.BLACK);
        Notetext.screenCenter();
        add(Notetext);
    }

    override function update(elapsed:Float) {
        var back:Bool = controls.BACK;

        if (back) {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }
         super.update(elapsed);
    }
}