--用于弹出层的zorder管理
local UILayerManager = {}

UILayerManager._worldMenuLayer = nil
UILayerManager._worldUILayer   = nil -- 用于添加界面的UILayer

UILayerManager.ZORDER = 1

-- 最上级弹窗 独立管理
UILayerManager._topLayerStack = {}

UILayerManager._popLayersStack = {}
UILayerManager._uiLayersStack = {}
UILayerManager._hideLayerStack = {}

function UILayerManager:setWorldMenuLayer(worldMenuLayer)
	self._worldMenuLayer = worldMenuLayer
end
function UILayerManager:clearWorldUILayer()
	self._worldMenuLayer = nil
end

function UILayerManager:setWorldUILayer(worldUILayer)
	self._worldUILayer = worldUILayer
end
function UILayerManager:clearWorldUILayer()
	self._worldUILayer = nil
end

function UILayerManager:addLayer(uilayer, coexist, params)
	if not self._worldUILayer then
		lt.CommonUtil.print("has not worldUILayer !!!!")
		return
	end

	if coexist then
		-- 共存 (当前页面为 次级页面)
		table.insert(self._uiLayersStack, uilayer)

		self._worldUILayer:setVisible(true)
		if params then
			uilayer._noTop = params.noTop
			if uilayer._noTop then
				self._worldUILayer:topHide()
			else
				local zorder = #self._uiLayersStack + #self._popLayersStack
				self._worldUILayer:topShow(zorder)
			end
		end
	else
		local hideLayers = {}
		for _,layer in ipairs(self._uiLayersStack) do
			if layer:isVisible() then
				table.insert(hideLayers, layer)
				layer:setVisible(false)
			end
		end
		table.insert(self._hideLayerStack,hideLayers)

		for _,layer in ipairs(self._popLayersStack) do
			layer:setVisible(false)
		end

		params = params or {}

		-- 不共存 (同为1级界面)
		table.insert(self._popLayersStack, uilayer)

		-- 为1级界面
		self._worldUILayer:setVisible(true)
		uilayer._noTop = params.noTop
		if uilayer._noTop then
			self._worldUILayer:topHide()
		else
			local zorder = #self._uiLayersStack + #self._popLayersStack
			self._worldUILayer:topShow(zorder)
		end
		self._worldMenuLayer:setVisible(false)
	end

	local zorder = #self._uiLayersStack + #self._popLayersStack
	self._worldUILayer:addChild(uilayer, zorder, zorder)
end

function UILayerManager:removeLayer(uilayer)
	-- 判断是否为 当前正在运行的界面
	local findShow = false
	for idx,showLayer in ipairs(self._popLayersStack) do
		if showLayer == uilayer then
			findShow = true
			table.remove(self._popLayersStack, idx)
			break
		end
	end

	for idx,showLayer in ipairs(self._uiLayersStack) do
		if showLayer == uilayer then
			findShow = true
			table.remove(self._uiLayersStack, idx)
			break
		end
	end

	local breakFlag = false
	for idx1,hideLayers in ipairs(self._hideLayerStack) do
		for idx2,layer in ipairs(hideLayers) do
			if layer == uilayer then
				table.remove(hideLayers, idx2)

				breakFlag = true
				break
			end
		end

		if #hideLayers == 0 then
			table.remove(self._hideLayerStack, idx1)
		end

		if breakFlag then
			break
		end
	end

	if #self._popLayersStack > 0 then
		local currentIdx = #self._popLayersStack
		local showLayer = self._popLayersStack[currentIdx]
		showLayer:setVisible(true)

		if showLayer._noTop then
			self._worldUILayer:topHide()
		else
			local zorder = #self._uiLayersStack + #self._popLayersStack
			self._worldUILayer:topShow(zorder)
		end
	end

	local hideIndex = #self._hideLayerStack
	local hideLayers = self._hideLayerStack[hideIndex]
	if hideLayers then
		for idx,layer in ipairs(hideLayers) do
			layer:setVisible(true)
		end

		table.remove(self._hideLayerStack, hideIndex)
	end

	uilayer:removeFromParent()

	if #self._popLayersStack <= 0 then
		-- 所有UILayer 已经关闭
		self._worldUILayer:topHide()
		self._worldMenuLayer:setVisible(true)
	end
end

function UILayerManager:addTopLayer(layer, extraZorder)
	table.insert(self._topLayerStack, layer)

	extraZorder = extraZorder or 0
	local zorder = 1000000 + #self._topLayerStack + extraZorder
	self._worldUILayer:setVisible(true)
	self._worldUILayer:addChild(layer, zorder, zorder)
end

function UILayerManager:removeTopLayer(layer)
	for idx,showLayer in ipairs(self._topLayerStack) do
		if showLayer == layer then
			table.remove(self._topLayerStack, idx)
			break
		end
	end

	layer:removeFromParent()
end

function UILayerManager:getCurrentZorder()
	return #self._uiLayersStack + #self._popLayersStack
end

function UILayerManager:clearAllLayers()
	self._worldUILayer:clearAllLayers()
	self._worldMenuLayer:setVisible(true)
	self._worldMenuLayer:resetAllLayer()

	self.ZORDER = 1

	self._topLayerStack = {}

	self._popLayersStack = {}
	self._uiLayersStack = {}
	self._hideLayerStack = {}
end

return UILayerManager