package states.editors;

import openfl.utils.Promise;
import openfl.utils.Timer;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

import sys.io.File;

import sys.net.Host;

class UpdatingState extends MusicBeatState
{

    private var remoteImage:flixel.FlxSprite;

    var porcent:Int = 0;
    var porcentText:FlxText;
    var exitText:FlxText;

    var status:Bool = false;
    var net:Bool = true;

    var loadTimer:FlxTimer;
    var loadConexion:FlxTimer;
    var bg:FlxSprite;

    var pathVersionOnline:String;
    var baseMbs:String;

    var pathtext:String = '';

    public function onCarga(Timer:FlxTimer) {

        if (net == true) {
            status = true;
        porcentText.text = "Iniciando Instalacion...\n\nIniciando TitleMenu...".toLowerCase();

        FlxTween.tween(bg, {alpha: 0}, FlxG.random.int(5, 8), {
            onComplete: function(twn:FlxTween) {

                porcentText.text = "Instalacion Completa Path Actualizado a la Version [" + pathVersionOnline + "]\n\nExito...".toLowerCase();
                MusicBeatState.switchState(new TitleState());
                ClientPrefs.data.pathVersion = pathVersionOnline;
                ClientPrefs.saveSettings();
                ClientPrefs.loadPrefs();

                File.saveContent("assets/system/path_" + FlxG.random.int(0, 99) + FlxG.random.int(0, 99) + ".txt", pathtext);

                trace('ClientPrefs.data.pathVersion == ' + ClientPrefs.data.pathVersion);

                
            }
        });
    }
    if (net == false) {
        porcentText.text = "Reintentando Descarga...".toLowerCase();
    }
    }

    public function checkNet(Timer:FlxTimer) {
        checkInternetConnection();
    }

    private function checkPath() {
        var hpss = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/pathVersion.txt");

        hpss.onData = function (data:String)
            {
                pathVersionOnline = data.split("*")[0].trim();
                trace('Path: [' + pathVersionOnline + "]");
            }

            hpss.onError = function (error) {
                trace('error: $error');
                trace('Paths Version Error. No cargara el parche');
            }

            hpss.request();

            var htpp = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/File_MBs");

            htpp.onData = function (data:String)
                {
                    baseMbs = data.split(" ")[0].trim();
                }

                htpp.onError = function (error) {
                    baseMbs = "?";
                }

            htpp.request();
    }
    private function checkPathText() {
        var htpss = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/PathSystem");

        htpss.onData = function (data:String)
            {
                pathtext = data.split("]")[0].trim();
            }

            htpss.onError = function (error) {
                trace('error: $error');
            }

            htpss.request();
    }

    override function create() {

    checkPath();
    checkPathText();

    FlxG.sound.music.fadeOut(4, 0.3);
    loadTimer = new FlxTimer();
    loadConexion = new FlxTimer();

    bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x000000);
    add(bg);

    porcentText = new FlxText(0, 0, FlxG.width, "", 32);
    porcentText.setFormat("vcr.ttf", 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
    porcentText.screenCenter();
    porcentText.antialiasing = ClientPrefs.data.antialiasing;
    porcentText.scrollFactor.set();
    add(porcentText);

    exitText = new FlxText(0, FlxG.height - 40, FlxG.width, "", 32);
    exitText.setFormat("vcr.ttf", 32, FlxColor.BLACK, CENTER, OUTLINE, FlxColor.RED);
    exitText.antialiasing = ClientPrefs.data.antialiasing;
    exitText.screenCenter(X);
    exitText.scrollFactor.set();
    add(exitText);

    porcent = FlxG.random.int(0, 5);

    if (porcent == 0) porcentText.text = "Se estan Descargando " + baseMbs +"MBs. Se instalaran en Segundo Plano...".toLowerCase();

    if (porcent == 1) porcentText.text = "La Descarga a Iniciado no cierre el Juego Porfavor".toLowerCase();

    if (porcent == 2) porcentText.text = "La descarga terminara en un instante estamos descargando todo lo necesario...".toLowerCase();

    if (porcent == 3) porcentText.text = "Tu version " + ClientPrefs.data.endingCorruprion + " Esta Recibiendo un parche de Seguridad de " + baseMbs + "MBs".toLowerCase();
    
    if (porcent == 4) porcentText.text = "El tiempo de Descarga depende de tu conexion a internet";

    if (porcent == 5) porcentText.text = "Los archivos descargados no son imagenes ni sonidos. son " + baseMbs +"MBs de archivos internos".toLowerCase();

    loadTimer.start(FlxG.random.int(10, 40), onCarga, 0);
    loadConexion.start(FlxG.random.float(0.1, 1.5), checkNet, 0);

    exitText.text = "Presiona Esc para Salir".toLowerCase();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE && net == false) {
            MusicBeatState.switchState(new TitleState());
        }

    }

    private function checkInternetConnection():Void
        {
            // Intenta cargar la imagen remota
            var htps = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/GitVersion.txt");

			htps.onData = function (data:String)
			{
                if (porcent == 0 && status == false) porcentText.text = "Se estan Descargando los archivos necesarios. Se instalaran en Segundo Plano...".toLowerCase();

                if (porcent == 1 && status == false) porcentText.text = "La Descarga a Iniciado no cierre el Juego Porfavor".toLowerCase();
            
                if (porcent == 2 && status == false) porcentText.text = "La descarga terminara en un instante estamos descargando todo lo necesario...".toLowerCase();
            
                if (porcent == 3 && status == false) porcentText.text = "Tu version " + ClientPrefs.data.endingCorruprion + " Esta Recibiendo un parche de Seguridad".toLowerCase();
                
                if (porcent == 4 && status == false) porcentText.text = "El tiempo de Descarga depende de tu conexion a internet".toLowerCase();
            
                if (porcent == 5 && status == false) porcentText.text = "Los archivos descargados no son imagenes ni sonidos. son archivos de sistema".toLowerCase();

                net = true;
                exitText.visible = false;
			}

			htps.onError = function (error) {
                if (porcent == 0 && status == false) porcentText.text = "Se estan Descargando los archivos necesarios. Se instalaran en Segundo Plano...\n\nLa Conexion a Internet se Perdion".toLowerCase();

                if (porcent == 1 && status == false) porcentText.text = "La Descarga a Iniciado no cierre el Juego Porfavor\n\nLa Descarga se Pauso ya que no se pudo continuar con la descarga".toLowerCase();
            
                if (porcent == 2 && status == false) porcentText.text = "La descarga terminara en un instante estamos descargando todo lo necesario...\n\nNo hemos podido utilizar la conexion a internet".toLowerCase();
            
                if (porcent == 3 && status == false) porcentText.text = "Tu version " + ClientPrefs.data.endingCorruprion + " Esta Recibiendo un parche de Seguridad\n\nIntentamos Reanudar la conexion...".toLowerCase();
                
                if (porcent == 4 && status == false) porcentText.text = "El tiempo de Descarga depende de tu conexion a internet\n\nVuelve a conectarte a Internet Porfavor".toLowerCase();
            
                if (porcent == 5 && status == false) porcentText.text = "Los archivos descargados no son imagenes ni sonidos. son archivos de sistema\n\nEl sistema no puede encontrar archivos. Esto puede ser por tu internet".toLowerCase();

                net = false;
                exitText.visible = true;
			}

			htps.request();
        }
}