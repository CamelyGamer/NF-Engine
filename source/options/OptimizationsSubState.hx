package options;

class OptimizationsSubState extends BaseOptionsMenu {
    public function new() {

        ClientPrefs.loadPrefs();
        MusicBeatState.updatestate("Optimizations Settings");
        if (ClientPrefs.data.language == 'Spanish') {
            title = 'Ajustes de Optimizacion';
            rpcTitle = 'Menu de Ajustes de optimizacion';

            var option:Option = new Option("Eliminar Animaciones",
            "Elimina las animaciones mas pesadas y que consuman muchos recursos",
            "noneAnimations",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Fondos Animados",
            "Elimina los Fondos Animados como el del 'Menu Principal'",
            "noneBGAnimated",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Acciones Continuas",
            "Elimina comprobaciones constantes como ubicaciones de Sprites\no Actualizacion constantes de Input",
            "noneFixeds",
            "bool");
            addOption(option);

            var option:Option = new Option("Movimiento de Almacen",
            "Mueve la carga de trabajo entre la memoria RAM y la CPU",
            "movedComponents",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar actualizacion de States",
            "Elimina la actualizacion del titulo del juego dependiendo de tus ajustes",
            "updateState",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Conexiones",
            "Elimina cualquier conexion de internet o alguna otra conexion\n!!Este Ajuste puede dar errores en algunos Luagares!!",
            "noneNet",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar PreCargas",
            "Elima cualquier PreCarga de Sprites o algun sonido\nEste puede tener un resultado diferente en otros Dispositivos",
            "nonePost",
            "bool");
            addOption(option);

            var option:Option = new Option("Elimina Deteccion de Mods",
            "Elimina cualquier comprobacion de archivos de Mods",
            "noneMods",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar plugins",
            "Esto elimina cualquier funcion de un Plugin anadido\n!!No cargara Ningun plugin!! Recuerda desactivarlo para poder cargar plugins",
            "nonePlugins",
            "bool");
            addOption(option);

            /*var option:Option = new Option("Ajustes Actualizandose",
            "Esto hace que todo se ajuste de forma automatica\n!!Esto puede dar error solo para PCs de pocos recursos!!\n[NO RECOMENDADO PARA PCs QUE CUMPLAN CON LOS REQUISITOS MINIMOS]",
            "updateSettings",
            "bool");
            addOption(option);*/
        }



        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





        if (ClientPrefs.data.language == 'Inglish') {
            title = 'Ajustes de Optimizacion';
            rpcTitle = 'Menu de Ajustes de optimizacion';

            var option:Option = new Option("Eliminar Animaciones",
            "Elimina las animaciones mas pesadas y que consuman muchos recursos",
            "noneAnimations",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Fondos Animados",
            "Elimina los Fondos Animados como el del 'Menu Principal'",
            "noneBGAnimated",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Acciones Continuas",
            "Elimina comprobaciones constantes como ubicaciones de Sprites\no Actualizacion constantes de Input",
            "noneFixeds",
            "bool");
            addOption(option);

            var option:Option = new Option("Movimiento de Almacen",
            "Mueve la carga de trabajo entre la memoria RAM y la CPU",
            "movedComponents",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar actualizacion de States",
            "Elimina la actualizacion del titulo del juego dependiendo de tus ajustes",
            "updateState",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Conexiones",
            "Elimina cualquier conexion de internet o alguna otra conexion\n!!Este Ajuste puede dar errores en algunos Luagares!!",
            "noneNet",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar PreCargas",
            "Elima cualquier PreCarga de Sprites o algun sonido\nEste puede tener un resultado diferente en otros Dispositivos",
            "nonePost",
            "bool");
            addOption(option);

            var option:Option = new Option("Elimina Deteccion de Mods",
            "Elimina cualquier comprobacion de archivos de Mods",
            "noneMods",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar plugins",
            "Esto elimina cualquier funcion de un Plugin anadido\n!!No cargara Ningun plugin!! Recuerda desactivarlo para poder cargar plugins",
            "nonePlugins",
            "bool");
            addOption(option);

            /*var option:Option = new Option("Ajustes Actualizandose",
            "Esto hace que todo se ajuste de forma automatica\n!!Esto puede dar error solo para PCs de pocos recursos!!\n[NO RECOMENDADO PARA PCs QUE CUMPLAN CON LOS REQUISITOS MINIMOS]",
            "updateSettings",
            "bool");
            addOption(option);*/
        }




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






        if (ClientPrefs.data.language == 'Portuguese') {
            title = 'Ajustes de Optimizacion';
            rpcTitle = 'Menu de Ajustes de optimizacion';

            var option:Option = new Option("Eliminar Animaciones",
            "Elimina las animaciones mas pesadas y que consuman muchos recursos",
            "noneAnimations",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Fondos Animados",
            "Elimina los Fondos Animados como el del 'Menu Principal'",
            "noneBGAnimated",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Acciones Continuas",
            "Elimina comprobaciones constantes como ubicaciones de Sprites\no Actualizacion constantes de Input",
            "noneFixeds",
            "bool");
            addOption(option);

            var option:Option = new Option("Movimiento de Almacen",
            "Mueve la carga de trabajo entre la memoria RAM y la CPU",
            "movedComponents",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar actualizacion de States",
            "Elimina la actualizacion del titulo del juego dependiendo de tus ajustes",
            "updateState",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar Conexiones",
            "Elimina cualquier conexion de internet o alguna otra conexion\n!!Este Ajuste puede dar errores en algunos Luagares!!",
            "noneNet",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar PreCargas",
            "Elima cualquier PreCarga de Sprites o algun sonido\nEste puede tener un resultado diferente en otros Dispositivos",
            "nonePost",
            "bool");
            addOption(option);

            var option:Option = new Option("Elimina Deteccion de Mods",
            "Elimina cualquier comprobacion de archivos de Mods",
            "noneMods",
            "bool");
            addOption(option);

            var option:Option = new Option("Eliminar plugins",
            "Esto elimina cualquier funcion de un Plugin anadido\n!!No cargara Ningun plugin!! Recuerda desactivarlo para poder cargar plugins",
            "nonePlugins",
            "bool");
            addOption(option);

            /*var option:Option = new Option("Ajustes Actualizandose",
            "Esto hace que todo se ajuste de forma automatica\n!!Esto puede dar error solo para PCs de pocos recursos!!\n[NO RECOMENDADO PARA PCs QUE CUMPLAN CON LOS REQUISITOS MINIMOS]",
            "updateSettings",
            "bool");
            addOption(option);*/
        }

        super();
    }
}