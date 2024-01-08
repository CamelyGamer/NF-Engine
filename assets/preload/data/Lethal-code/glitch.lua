function onCreate()
    makeLuaSprite('shaders')
    initLuaShader('glitch')
    setSpriteShader('shaders', 'glitch')
    runHaxeCode([[
        shader0 = game.modchartSprites.get('shaders').shader;
        game.camGame.setFilters([new ShaderFilter(shader0)]);
        game.getLuaObject("shaders").shader = shader0;
        game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("shaders").shader)]);
        return;
    ]])
end

function onUpdate(elapsed)
    setShaderFloat("shaders", "iTime", os.clock())
 end
    
    local temp = onDestroy
    function onDestroy()
        runHaxeCode([[
            FlxG.signals.gameResized.remove(fixShaderCoordFix);
            return;
        ]])
        if (temp) then temp() 
     end
end