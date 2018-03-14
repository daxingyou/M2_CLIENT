-- 游戏场景
local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)

GameScene._gameRoomLayer 	= nil -- 游戏背景层、牌面层、入座头像层、设置层、房间信息层
GameScene._gameUILayer 	= nil -- 游戏UI界面  由 gamePlayLayer 层触发显示层
GameScene._gameNoticeLayer = nil--提示层

function GameScene:ctor()
    self._gameRoomLayer = lt.GameRoomLayer.new()
    self:addChild(self._gameRoomLayer)

    self._gameUILayer = lt.WorldUILayer.new(self)
    self._gameUILayer:setVisible(false)
    self:addChild(self._gameUILayer)

    --self:loadingOn()
    self._gameNoticeLayer = lt.WorldNoticeLayer.new()
    self:addChild(self._gameNoticeLayer)

    lt.UILayerManager:setWorldMenuLayer(self._gameRoomLayer)
    lt.UILayerManager:setWorldUILayer(self._gameUILayer)
end

function GameScene:getGameRoomUILayer()
	return self._gameUILayer
end

function GameScene:getGameRoomUILayer()
	return self._gameUILayer
end

function GameScene:loadingOn()
	-- if not self._worldLoadingLayer then
	-- 	self._worldLoadingLayer = lt.WorldLoadingLayer.new()
	-- 	self:addChild(self._worldLoadingLayer, lt.Constants.ZORDER.LOADING)
	-- end
end

function GameScene:loadingOff()
	-- if self._worldLoadingLayer then
	-- 	self._worldLoadingLayer:removeSelf()
	-- 	self._worldLoadingLayer = nil
	-- end
end

return GameScene