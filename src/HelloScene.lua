require "Cocos2d"
require "Cocos2dConstants"

local HelloScene = class("HelloScene",function()
    return cc.Scene:create()
end)

function HelloScene.create()
    local scene = HelloScene.new()
    --scene:addChild(scene:createLayerFarm())
    scene:addChild(scene:createMenu())
    return scene
end

function HelloScene:createMenu()
    local layerMenu = cc.Layer:create()
    local menuPopup, menuTools, effectID

    local function menuCallbackClosePopup()
        -- stop test sound effect
        cc.SimpleAudioEngine:getInstance():stopEffect(effectID)
        menuPopup:setVisible(false)
    end

    local function menuCallbackOpenPopup()
        -- loop test sound effect
        local effectPath = cc.FileUtils:getInstance():fullPathForFilename("effect1.wav")
        effectID = cc.SimpleAudioEngine:getInstance():playEffect(effectPath)
        menuPopup:setVisible(true)
    end

    local function closeApp()
        cc.Director:endToLua()
    end
    
    local function startGame()
        local scene = require("GameScene")
        local gameScene = scene.create()
        gameScene:playBgMusic()

        if cc.Director:getInstance():getRunningScene() then
            cc.Director:getInstance():replaceScene(gameScene)
        else
            cc.Director:getInstance():runWithScene(gameScene)
        end
    end

    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    
    
    local menuToolsItem = cc.MenuItemImage:create("start.png", "start2.png")
    local size = menuToolsItem:getContentSize()
    menuToolsItem:setPosition(self.visibleSize.width/2-0.5*size.width, self.visibleSize.height/2-0.5*size.height)
    menuToolsItem:registerScriptTapHandler(startGame)
    
    menuTools = cc.Menu:create(menuToolsItem)
    local itemWidth = menuToolsItem:getContentSize().width
    local itemHeight = menuToolsItem:getContentSize().height
    menuTools:setPosition(itemWidth/2, itemHeight/2)
    layerMenu:addChild(menuTools)

    return layerMenu
end

return HelloScene