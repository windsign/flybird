require "Cocos2d"
require "Cocos2dConstants"

gGameOver = false

local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

function GameScene.create()
    local scene = GameScene.new()
    --scene:addChild(scene:createLayerFarm())
    scene:addChild(scene:createSky())
    scene:addChild(scene:createLayerMenu())
    return scene
end

function GameScene:createBird()
    local frameWidth = 64;
    local frameHeight = 64;
    
    local bird = cc.Sprite:create("bird.png");
    bird:setPosition(self.origin.x + self.visibleSize.width*0.75, 400)
    bird.isPaused = false
    bird.velocityY = 0
    local function fly()
        if bird.isPaused then return end
        if gGameOver then return end
        local x, y = bird:getPosition()
        if x < self.origin.x then
            x = self.origin.x + self.visibleSize.width*0.75
        else if y < self.origin.y or y > self.visibleSize.height then
                --self:GameOver()
                gGameOver = true
             else
                x = x - 2
                bird.velocityY = bird.velocityY - 0.2
                y = y + bird.velocityY
             end        
        end
        bird:setPosition(x,y)
    end
    
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(fly, 0, false)
    return bird
end


function GameScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    local x = self.visibleSize.height
    local y = self.visibleSize.width
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
end

function GameScene:playBgMusic()
--[[
    local bgMusicPath = cc.FileUtils:getInstance():fullPathForFilename("background.mp3") 
    cc.SimpleAudioEngine:getInstance():playMusic(bgMusicPath, true)
    local effectPath = cc.FileUtils:getInstance():fullPathForFilename("effect1.wav")
    cc.SimpleAudioEngine:getInstance():preloadEffect(effectPath)
    ]]
end

function GameScene:GameOver()
    gGameOver = true
    local gameover = cc.Label:create()
    gameover:setString("GameOver")
    gameover:setPosition(self.visibleSize.width/2,self.visibleSize.height/2)
    gameover:setScale(4)
    --layerSky:addChild(gameover)
    return gameover
end

function GameScene:createSky()
    local layerSky = cc.Layer:create()
    
    local sky = cc.Sprite:create("sky.png")
    --sky:setPosition(self.origin.x + self.visibleSize.height/2, self.origin.y+self.visibleSize.width/2)
    sky:setPosition(self.visibleSize.width/2,self.visibleSize.height/2)
    layerSky:addChild(sky)
    
    local bird = self:createBird()
    layerSky:addChild(bird)
    
    local pile = cc.Sprite:create("pile.png")
    pile:setPosition(self.visibleSize.width/2,self.visibleSize.height-50)
    layerSky:addChild(pile)
    
    
    local touchBeginPoint = nil
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        return true
    end

    local function onTouchMoved(touch, event)

    end

    local function onTouchEnded(touch, event)
        bird.velocityY = 5
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layerSky:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerSky)

    local function onNodeEvent(event)
        if "exit" == event then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        end
    end
    layerSky:registerScriptHandler(onNodeEvent)
    
    local function update()
       --cc.Director:replaceScene(scene)
       --sky:getBoundingBox()
       if gGameOver then return end
       local isIntersect = cc.rectIntersectsRect(pile:getBoundingBox(),bird:getBoundingBox())
       
       if isIntersect or gGameOver then
            local d = self:GameOver()
            layerSky:addChild(d)
       end
    end
    self.schedulerID2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
    return layerSky
end


-- create menu
function GameScene:createLayerMenu()

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
    -- add a popup menu
    local menuPopupItem = cc.MenuItemImage:create("menu2.png", "menu2.png")
    menuPopupItem:setPosition(0, 0)
    menuPopupItem:registerScriptTapHandler(menuCallbackClosePopup)
    menuPopup = cc.Menu:create(menuPopupItem)
    menuPopup:setPosition(self.origin.x + self.visibleSize.width / 2, self.origin.y + self.visibleSize.height / 2)
    menuPopup:setVisible(false)
    layerMenu:addChild(menuPopup)

    -- add the left-bottom "tools" menu to invoke menuPopup
    local menuToolsItem = cc.MenuItemImage:create("menu1.png", "menu1.png")
    menuToolsItem:setPosition(0, 0)
    --menuToolsItem:registerScriptTapHandler(menuCallbackOpenPopup)
    menuToolsItem:registerScriptTapHandler(closeApp)
    menuTools = cc.Menu:create(menuToolsItem)
    local itemWidth = menuToolsItem:getContentSize().width
    local itemHeight = menuToolsItem:getContentSize().height
    menuTools:setPosition(self.origin.x + itemWidth/2, self.origin.y + itemHeight/2)
    layerMenu:addChild(menuTools)

    return layerMenu
end

return GameScene
