local MjEngine = {}
MjEngine.CARD_TYPE = {
	HAND = 1, 
	CPG = 2,
	OUT = 3,
}

function MjEngine:create(deleget)
	self._deleget = deleget

    local gameInfo = lt.DataManager:getGameRoomInfo()
    self._playerNum = 2
    if gameInfo and gameInfo.room_setting and gameInfo.room_setting.seat_num then
        self._playerNum = gameInfo.room_setting.seat_num
    end

	self._allPlayerHandCardsNode = {}
	self._allPlayerCpgCardsNode = {}
	self._allPlayerOutCardsNode = {}

	self._allPlayerHandCardsValue = {}
	self._allPlayerCpgCardsValue = {}
	self._allPlayerOutCardsValue = {}

	self._allPlayerCpgCardsPanel = {}
	self._allPlayerHandCardsPanel = {}
	self._allPlayerOutCardsPanel = {}


	self._allLieFaceCardNode = {}

	self._showCardsLayer = display.newLayer() --cc.Layer:create()
	--self._showCardsLayer:setSwallowTouches(false)

	self._outCardsNode = cc.Node:create():setPosition(667, 400)--出牌的父node
	self._showCardsLayer:addChild(self._outCardsNode)

	self._allCpgHandPanelPos = {--吃椪杠的父节点的位置
	ccp(205, 410),
	ccp(667, 78),
	ccp(1129, 410),
	ccp(667, 697),
	}

	self._allCpgNodePos = {--吃椪杠左边的起点位置 
	ccp(-30, 172),
	ccp(-632, -60),
	ccp(-33, -290),
	ccp(314, -39),
	}

	self._allHandNodePos = {--手牌左边的起点位置 
	ccp(-16, 151),
	ccp(-632, -60),
	ccp(-15, -210),
	ccp(300, -37),
	}

	self._allOutCardsPanelPos = {--不同玩家人数 不同方位
		[2] = {
			[4] = ccp(0, 153),
			[2] = ccp(0, -140),
		} ,

		[3] = {
			[1] = ccp(-262, 148),
			[2] = ccp(16, -140),
			[3] = ccp(267, 81),
		} ,
		[4] = {
			[1] = ccp(-253, -66),
			[2] = ccp(113, 140),
			[3] = ccp(267, 80),
			[4] = ccp(-54, 173),
		} ,
	}

	self._allOutCardsNodePos = {}--所有方位出的牌的位置 按照ccb资源上的位置
	self:configOutCardsNodePos()

	self._currentGameDirections = nil

	if self._playerNum == 2 then--二人麻将
		self._currentGameDirections = {2, 4}
	elseif self._playerNum == 3 then
		self._currentGameDirections = {1, 2, 3}
	elseif self._playerNum == 4 then
		self._currentGameDirections = {1, 2, 3, 4}
	end

	for i,direction in ipairs(self._currentGameDirections) do
		self._allPlayerCpgCardsPanel[direction] = cc.Node:create():setPosition(self._allCpgHandPanelPos[direction])
		self._allPlayerHandCardsPanel[direction] = cc.Node:create():setPosition(self._allCpgHandPanelPos[direction])

		self._allPlayerOutCardsPanel[direction] = cc.Node:create():setPosition(self._allOutCardsPanelPos[self._playerNum][direction])
	
		self._showCardsLayer:addChild(self._allPlayerCpgCardsPanel[direction])
		self._outCardsNode:addChild(self._allPlayerOutCardsPanel[direction])
		self._showCardsLayer:addChild(self._allPlayerHandCardsPanel[direction])
	end
	
	return self
end

function MjEngine:configOutCardsNodePos()
	local rootNode = nil
	if self._playerNum == 2 then
		rootNode = cc.CSLoader:createNode("game/mjcomm/csb/mjui/2p/MjCardsPanel2p.csb")

	elseif self._playerNum == 3 then
		rootNode = cc.CSLoader:createNode("game/mjcomm/csb/mjui/3p/MjCardsPanel3p.csb")

	elseif self._playerNum == 4 then
		rootNode = cc.CSLoader:createNode("game/mjcomm/csb/mjui/green/MjCardsPanel.csb")
	end

	if not rootNode then
		return
	end

	for i=1,self._playerNum do
		local cardsNode = lt.CommonUtil:getChildByNames(rootNode, "Panel_OutCard", "Node_OutCards_"..i)
		local posArray = {}
		for index=1, 60 do
			local cardNode = lt.CommonUtil:getChildByNames(cardsNode, "MJ_Out_"..index)
			if not cardNode then
				break
			end

			local x, y = cardNode:getPosition()

			table.insert(posArray, ccp(x, y))
		end
		local direction = 1
		if self._playerNum == 2 then
			if i == 1 then
				direction = lt.Constants.DIRECTION.BEI
			else
				direction = lt.Constants.DIRECTION.NAN
			end
		else
			direction = i
		end
		self._allOutCardsNodePos[direction] = posArray
	end
end

function MjEngine:clearData()

	-- self._allPlayerOutCardsNode = {}
	-- self._allPlayerHandCardsNode = {}
	-- self._allPlayerCpgCardsNode = {}


	self._allPlayerHandCardsValue = {}
	self._allPlayerCpgCardsValue = {}
	self._allPlayerOutCardsValue = {}

	for k,v in pairs(self._allLieFaceCardNode) do
		v:removeFromParent()
	end

	self._allLieFaceCardNode = {}
end

function MjEngine:getShowCardsLayer()
	return self._showCardsLayer
end

function MjEngine:clearDesktop()--清理桌面
	self:clearData()
	self._showCardsLayer:removeAllChild()
end

function MjEngine:angainConfigUi()--继续游戏
	self:clearData()
	self._showCardsLayer:setVisible(false)
end

function MjEngine:sendCards(cards)--发牌 13张
	self._showCardsLayer:setVisible(true)
	cards = cards or {}
	self._allPlayerHandCardsValue[lt.Constants.DIRECTION.NAN] = self._allPlayerHandCardsValue[lt.Constants.DIRECTION.NAN] or {}
	for i,card in ipairs(cards) do
		table.insert(self._allPlayerHandCardsValue[lt.Constants.DIRECTION.NAN], card)

	end
	local sortFun = function(a, b)
		return a < b
	end

	table.sort(self._allPlayerHandCardsValue[lt.Constants.DIRECTION.NAN], sortFun)

	self:sendCardsEffect()
end

function MjEngine:sendCardsEffect()
	local sendDealFinish = false

	for i,direction in ipairs(self._currentGameDirections) do
		self._allPlayerHandCardsValue[direction] = self._allPlayerHandCardsValue[direction] or {}
		for i=1, 13 do
			if direction ~= lt.Constants.DIRECTION.NAN then
				self._allPlayerHandCardsValue[direction][i] = 99
			end
		end
		self:configAllPlayerCards(direction, true, true, true)
	end

	for k,cards in pairs(self._allPlayerHandCardsNode) do
		for i,v in ipairs(cards) do
			v:setVisible(false)
		end
	end

	for direction,cards in pairs(self._allPlayerHandCardsNode) do--发牌发13张
		local time = 0.1
		for i=1,13 do
			time = time + 0.1
			if cards[i] then
				local func = function( )
					cards[i]:setVisible(true)

					if i == 13 and not sendDealFinish then
						-- self._nodeCardNum:setVisible(true)
						-- self._nodeOtherNum:setVisible(true)

						sendDealFinish = true
						local arg = {command = "DEAL_FINISH"}
						lt.NetWork:sendTo(lt.GameEventManager.EVENT.GAME_CMD, arg)
					end
				end
				local delay = cc.DelayTime:create(time)

				local func1 = cc.CallFunc:create(func)
				local sequence = cc.Sequence:create(delay, func1)
				cards[i]:runAction(sequence)
			end
		end
	end	

end

function MjEngine:configAllPlayerCards(direction, refreshCpg, refreshHand, refreshOut)--吃椪杠 手牌 出的牌  用于刷牌
	
	-- if refreshCpg and refreshHand and refreshOut then
	-- 	self:clearDesktop()
	-- elseif then

	-- end
	
	local cpgOffX = 0
	local cpgOffY = 0
	if direction == lt.Constants.DIRECTION.XI then
		cpgOffY = -114
	elseif direction == lt.Constants.DIRECTION.NAN then
		cpgOffX = 160
	elseif direction == lt.Constants.DIRECTION.DONG then
		cpgOffY = 114
	elseif direction == lt.Constants.DIRECTION.BEI then
		cpgOffX = -135
	end

	local handOffX = 0
	local handOffY = 0
	if direction == lt.Constants.DIRECTION.XI then
		handOffY = -27
	elseif direction == lt.Constants.DIRECTION.NAN then
		handOffX = 88
	elseif direction == lt.Constants.DIRECTION.DONG then
		handOffY = 27
	elseif direction == lt.Constants.DIRECTION.BEI then
		handOffX = -46
	end

	self._allPlayerCpgCardsValue[direction] = self._allPlayerCpgCardsValue[direction] or {}
	self._allPlayerHandCardsValue[direction] = self._allPlayerHandCardsValue[direction] or {}

	local cpgNumber = #self._allPlayerCpgCardsValue[direction]
	local handNumber = #self._allPlayerHandCardsValue[direction]

	--吃椪杠
	if refreshCpg then
	 	if not self._allPlayerCpgCardsNode[direction] then
			self._allPlayerCpgCardsNode[direction] = {}
		end

		for i,v in ipairs(self._allPlayerCpgCardsNode[direction]) do
			v:setVisible(false)
		end

		for i,info in ipairs(self._allPlayerCpgCardsValue[direction]) do
			
			local node = self._allPlayerCpgCardsNode[direction][i]
			if node then
				self:updateCardsNode(node, self.CARD_TYPE.CPG, direction, info)
			else
				node = self:createCardsNode(self.CARD_TYPE.CPG, direction, info)
				table.insert(self._allPlayerCpgCardsNode[direction], node)
				self._allPlayerCpgCardsPanel[direction]:addChild(node:getRootNode())
			end

			local x = self._allCpgNodePos[direction].x
			local y = self._allCpgNodePos[direction].y
			node:setPosition(x + (i - 1)*cpgOffX, y + (i - 1)*cpgOffY)

			node:setVisible(true)
		end
	end

	--手牌
	if refreshHand then
		if not self._allPlayerHandCardsNode[direction] then
			self._allPlayerHandCardsNode[direction] = {}
		end

		for i,v in ipairs(self._allPlayerHandCardsNode[direction]) do
			v:setVisible(false)
		end
		local isSpaceLastCard = false
		if handNumber % 3 == 2 then-- == 2时 该出牌了 最后一张牌要间隔
			isSpaceLastCard = true
		end

		for i,info in ipairs(self._allPlayerHandCardsValue[direction]) do
			local node = self._allPlayerHandCardsNode[direction][i]
			if node then
				self:updateCardsNode(node, self.CARD_TYPE.HAND, direction, info)
			else
				node = self:createCardsNode(self.CARD_TYPE.HAND, direction, info)
				table.insert(self._allPlayerHandCardsNode[direction], node)
				self._allPlayerHandCardsPanel[direction]:addChild(node:getRootNode())
			end

			local x = self._allCpgNodePos[direction].x
			local y = self._allCpgNodePos[direction].y

			if cpgNumber and cpgNumber > 0 then--有吃椪杠存在

				if direction == lt.Constants.DIRECTION.NAN then--锚点和初始化方向导致不同情况
					node:setPosition(x + cpgNumber*cpgOffX + (i-1)*handOffX, y + cpgNumber*cpgOffY+(i-1)*handOffY)
				else
					node:setPosition(x + (cpgNumber - 1)*cpgOffX + i*handOffX, y + (cpgNumber - 1)*cpgOffY + i*handOffY)
				end
			else
				x = self._allHandNodePos[direction].x
				y = self._allHandNodePos[direction].y

				node:setPosition(x + (i-1)*handOffX, y + (i-1)*handOffY)
			end
			if isSpaceLastCard and i == handNumber then
				local x, y = node:getPosition()
				if direction == lt.Constants.DIRECTION.XI then
					node:setPosition(x, y - 10)
				elseif direction == lt.Constants.DIRECTION.NAN then
					node:setPosition(x + 20, y)
				elseif direction == lt.Constants.DIRECTION.DONG then
					node:setPosition(x, y + 10)

				elseif direction == lt.Constants.DIRECTION.BEI then
					node:setPosition(x - 15, y)					
				end
			end
			node:setVisible(true)
		end
	end

	--出牌

	if refreshOut then
		if not self._allPlayerOutCardsNode[direction] then
			self._allPlayerOutCardsNode[direction] = {}
		end

		for i,v in ipairs(self._allPlayerOutCardsNode[direction]) do
			v:setVisible(false)
		end

		self._allPlayerOutCardsValue[direction] = self._allPlayerOutCardsValue[direction] or {}
		for i,info in ipairs(self._allPlayerOutCardsValue[direction]) do
			local node = self._allPlayerOutCardsNode[direction][i]
			if node then
				self:updateCardsNode(node, self.CARD_TYPE.OUT, direction, info)
			else
				node = self:createCardsNode(self.CARD_TYPE.OUT, direction, info)
				table.insert(self._allPlayerOutCardsNode[direction], node)
				self._allPlayerOutCardsPanel[direction]:addChild(node:getRootNode())
			end
			node:setPosition(self._allOutCardsNodePos[direction][i])
			node:setVisible(true)
		end
	end

end

--所有牌的变化
function MjEngine:updateNanHandCardValue(direction, handList)--通知自己出牌的时候会把手牌和吃椪杠的牌发过来
	self._allPlayerHandCardsValue[direction] = handList
end

function MjEngine:updateNanCpgCardValue(direction, cpgList)
	self._allPlayerCpgCardsValue[direction] = cpgList
end

--单张牌的变化
function MjEngine:goOutOneHandCardAtDirection(direction, value)--出了一张牌
	 
	 if direction == lt.Constants.DIRECTION.NAN then
		self._allPlayerHandCardsValue[direction] = self._allPlayerHandCardsValue[direction] or {}

		for index,card in pairs(self._allPlayerHandCardsValue[direction]) do
			if card == value then
				table.remove(self._allPlayerHandCardsValue[direction], index)
				break
			end
		end

	 else
	 	table.remove(self._allPlayerHandCardsValue[direction], 1)
	 end

	self._allPlayerOutCardsValue[direction] = self._allPlayerOutCardsValue[direction] or {}
	table.insert(self._allPlayerOutCardsValue[direction], value)
end

function MjEngine:getOneHandCardAtDirection(direction)--起了一张牌
	table.insert(self._allPlayerHandCardsValue[direction], 99)
end

function MjEngine:getOneCpgAtDirection(direction, info)
	 table.insert(self._allPlayerCpgCardsValue[direction], info)
end

--创建牌node
function MjEngine:createCardsNode(cardType, direction, info)
	--direction 上北下南左西右东  type==1 手牌 2 吃椪杠的牌 3 出的牌
	
	if not cardType or not direction then
		return
	end
	local node = nil 
	if cardType == self.CARD_TYPE.HAND then
		node = lt.MjStandFaceItem.new(direction)
		if self._clickCardCallback then
			node:addNodeClickEvent(self._clickCardCallback)
		end
	elseif cardType == self.CARD_TYPE.CPG then
		node = lt.MjLieCpgItem.new(direction)

	elseif cardType == self.CARD_TYPE.OUT then
		node = lt.MjLieOutFaceItem.new(direction)
	end

	if node then
		self:updateCardsNode(node, cardType, direction, info)
	end

	return node
end

function MjEngine:updateCardsNode(node, cardType, direction, info)
	if cardType == self.CARD_TYPE.HAND and direction == lt.Constants.DIRECTION.NAN then
		local value = info--手牌值
		node:setCardValue(value)
		node:setTag(value)
	elseif cardType == self.CARD_TYPE.CPG then
		node:updateInfo(info)
		node:setCpgInfo(info)

	elseif cardType == self.CARD_TYPE.OUT then 
		node:setCardValue(info)
		node:setValue(value)
	end	

end

function MjEngine:createLieFaceItemByDirection(direction, info)

	local path = nil
	local lieFaceNode = nil
	if direction == lt.Constants.DIRECTION.BEI then
		path = "game/mjcomm/csb/mjui/green/MjLieUpFaceItem.csb"
	elseif direction == lt.Constants.DIRECTION.XI then
		path = "game/mjcomm/csb/mjui/green/MjLieLeftFaceItem.csb"
	elseif direction == lt.Constants.DIRECTION.DONG then
		path = "game/mjcomm/csb/mjui/green/MjLieRightFaceItem.csb"
	end
	if path then
		lieFaceNode = cc.CSLoader:createNode(path)
	end

	if lieFaceNode then
		local face = lieFaceNode:getChildByName("Sprite_Face")
		local Sprite_Back = lieFaceNode:getChildByName("Sprite_Back")
		Sprite_Back:setVisible(false)
		value = info
		local cardType = math.floor(value / 10) + 1
		local cardValue = value % 10
		face:setSpriteFrame("game/mjcomm/cards/card_"..cardType.."_"..cardValue..".png")
	end

    return lieFaceNode
end

function MjEngine:checkMyHandStatu() --检测吃椪杠
    local tObjCpghObj = {
        tObjChi = nil,
        tObjPeng = nil,
        tObjGang = nil,
        tObjHu = nil--抢杠胡  自摸
    }
    --检测杠
	local tempHandCards = {}

	for k,v in pairs(self._allPlayerHandCardsValue[lt.Constants.DIRECTION.NAN]) do
		table.insert(tempHandCards, v)
	end

	local anGangCards = lt.CommonUtil:getCanAnGangCards(tempHandCards) 
	dump(anGangCards)

	local pengGang = lt.CommonUtil:getCanPengGangCards(self._allPlayerCpgCardsValue[lt.Constants.DIRECTION.NAN], tempHandCards)
	dump(pengGang)

	if #anGangCards > 0 or #pengGang > 0 then
		tObjCpghObj.tObjGang = {}
	end

	for i,v in ipairs(anGangCards) do
		table.insert(tObjCpghObj.tObjGang, v)
	end

	for i,v in ipairs(pengGang) do
		table.insert(tObjCpghObj.tObjGang, v)
	end

	--检测胡
	print("______fsdfsdf胡牌——————————————————————————", tostring(tempHandCards))
	if lt.CommonUtil:checkIsHu(tempHandCards, true) then
		print("自摸了###########################################")
		tObjCpghObj.tObjHu = {}
	else
		print("没有自摸###########################################")
	end

 --    --显示吃碰杠胡控件
 --    self:resetActionButtonsData(tObjCpghObj)--将牌的数据绑定到按钮上
	-- self:viewActionButtons(tObjCpghObj, false)

	return tObjCpghObj
end

function MjEngine:setClickCardCallBack(callBack)
	self._clickCardCallback = callBack
end

function MjEngine:gameOverShow()--游戏结束 推到牌
	for dire,CPGNodes in pairs(self._allPlayerCpgCardsNode) do
		for index,node in ipairs(CPGNodes) do
			local info = node:getCpgInfo()

			-- local value = info.value
			-- --local gang_type = info.gang_type--1 暗杠 2 明杠 3 碰杠
			-- local from = info.from
			-- local type = info.type--<1 吃 2 碰 3 碰杠 4明杠 5 暗杠 6 胡>
			if info and info.type == 5 then
				node:allCardVisible()
			end
		end
	end

	local gameOverInfo = lt.DataManager:getGameOverInfo()

	local winner_pos = gameOverInfo.winner_pos
	local winner_type = gameOverInfo.winner_type or 1 --自摸 1 抢杠 2
	local last_round = gameOverInfo.last_round

	if gameOverInfo.players then
		for k,v in ipairs(gameOverInfo.players) do
			local direction = lt.DataManager:getPlayerDirectionByPos(v.user_pos)

			--推到手牌
			if direction ~= lt.Constants.DIRECTION.NAN and self._allPlayerHandCardsNode[direction] then--手牌
				local index = 1
				for i,node in ipairs(self._allPlayerHandCardsNode[direction]) do
					if node:isVisible() then

						local value = nil
						if v.card_list[index] then
							local lieFaceNode = self:createLieFaceItemByDirection(direction, v.card_list[index])
							lieFaceNode:setPosition(node:getPosition())
							--local root = node:getParent()
							self._allPlayerHandCardsPanel[direction]:addChild(lieFaceNode)
							table.insert(self._allLieFaceCardNode, lieFaceNode)
							index = index + 1
						end
						node:setVisible(false)

						--
					end
				end
			end
		end
	end		

end

function MjEngine:noticeSpecialEvent(msg)-- 有人吃椪杠胡
	local direction = lt.DataManager:getPlayerDirectionByPos(msg.user_pos)
	if not direction then
		return
	end

	local info = nil
	if msg.item then
		info = {}
		info["value"] = msg.item["value"]
		info["from"] = msg.item["from"]
		info["type"] = msg.item["type"]--<1 吃 2 碰 3 碰杠 4明杠 5 暗杠 6 胡>

	end

	if not msg.item["type"] then
		return
	end

	local offNum = 0--吃椪杠少牌处理
	if direction ~= lt.Constants.DIRECTION.NAN then
		if msg.item["type"] == 1 then
			offNum = 2
		elseif msg.item["type"] == 2 then
			offNum = 2
		elseif msg.item["type"] == 3 then	
			offNum = 1
		elseif msg.item["type"] == 4 then
			offNum = 3
		elseif msg.item["type"] == 5 then
			offNum = 4
		end

		for i=1,offNum do
			if #self._allPlayerHandCardsValue[direction] > 0 then
				table.remove(self._allPlayerHandCardsValue[direction], 1)
			end
		end
	end

	if msg.item["type"] ~= 6 then
		if not self._allPlayerCpgCardsValue[direction] then
			self._allPlayerCpgCardsValue[direction] = {}
		end

		if info then
			if msg.item["type"] == 3 then
				local change = false
				for k,v in ipairs(self._allPlayerCpgCardsValue[direction]) do
					if v.value == info.value then--之前是碰  变成了回头杠
						change = true
						self._allPlayerCpgCardsValue[direction][k] = info
						break
					end
				end
			else
				table.insert(self._allPlayerCpgCardsValue[direction], info)
			end
		end
	end	
	self:configAllPlayerCards(direction, true, true, false)
end

function MjEngine:onClientConnectAgain()--  断线重连
	local allRoomInfo = lt.DataManager:getPushAllRoomInfo()

	--handle_nums
	--自己的手牌

	if allRoomInfo.card_list then
		self._allPlayerHandCardsValue[self.POSITION_TYPE.NAN] = {}
		for i,card in ipairs(allRoomInfo.card_list) do
			table.insert(self._allPlayerHandCardsValue[self.POSITION_TYPE.NAN], card)

		end
		local sortFun = function(a, b)
			return a < b
		end

		table.sort(self._allPlayerHandCardsValue[self.POSITION_TYPE.NAN], sortFun)
	end

	if allRoomInfo.handle_nums then--handle_num

		for i,info in ipairs(allRoomInfo.handle_nums) do

			local direction = lt.DataManager:getPlayerDirectionByPos(info.user_pos)
			if direction ~= self.POSITION_TYPE.NAN then--不是自己
				self._allPlayerHandCardsValue[direction] = {}
				for i=1,info.handle_num do
					table.insert(self._allPlayerHandCardsValue[direction], 99)
				end
			end
		end
	end

	--所有玩家吃椪杠的牌  
	if allRoomInfo.refresh_room_info and allRoomInfo.refresh_room_info.players then
		local players = allRoomInfo.refresh_room_info.players
		for i,playerInfo in ipairs(players) do
			local direction = lt.DataManager:getPlayerDirectionByPos(playerInfo.user_pos) 

			self._allPlayerCpgCardsValue[direction] = {}
			if playerInfo.card_stack then

				for i,stack in ipairs(playerInfo.card_stack) do
					local info = {}
					info["value"] = stack["value"]
					info["from"] = stack["from"]
					info["type"] = stack["type"]--<1 吃 2 碰 3 碰杠 4明杠 5 暗杠 6 胡>
					table.insert(self._allPlayerCpgCardsValue[direction], info)
				end
			end
		end
	end

	--所有出的牌  
	if allRoomInfo.put_cards then
		for i,info in ipairs(allRoomInfo.put_cards) do
			if info.user_pos then
				local direction = lt.DataManager:getPlayerDirectionByPos(info.user_pos)
				self._allPlayerOutCardsValue[direction]	= {}

				for k,value in ipairs(info.cards) do
					table.insert(self._allPlayerOutCardsValue[direction], value)
				end

			end		
		end
	end

    --当前事件  
	if allRoomInfo.operator then
		local operatorList = {}
		if allRoomInfo.operator == "WAIT_DEAL_FINISH" then
			local arg = {command = "DEAL_FINISH"}
			lt.NetWork:sendTo(lt.GameEventManager.EVENT.GAME_CMD, arg)
		elseif allRoomInfo.operator == "WAIT_PLAY_CARD" then	
		elseif allRoomInfo.operator == "WAIT_PENG" then
			operatorList = {"PENG"}	
		elseif allRoomInfo.operator == "WAIT_GANG_WAIT_PENG" then
			operatorList = {"PENG", "GANG"}				
		elseif allRoomInfo.operator == "WAIT_GANG" then
			operatorList = {"GANG"}		
		elseif allRoomInfo.operator == "WAIT_HU" then
			operatorList = {"HU"}	
		elseif allRoomInfo.operator == "WAIT_PLAY_CARD_FROM_PENG" then

		end

		--我的吃碰杠通知
        local tObjCpghObj = {
            tObjChi = nil,
            tObjPeng = nil,
            tObjGang = nil,
            tObjHu = nil--抢杠胡
        }

        for k,state in pairs(operatorList) do

        	if state == "PENG" then
        		tObjCpghObj.tObjPeng = {}

        		--table.insert(tObjCpghObj.tObjPeng, msg.card)
        	elseif state == "GANG" then
        		if allRoomInfo.put_card then
        			tObjCpghObj.tObjGang = {}
        			table.insert(tObjCpghObj.tObjGang, allRoomInfo.put_card)
        		end
        	elseif state == "HU" then--抢杠胡
        		tObjCpghObj.tObjHu = {}

        	end
        end

	    --当前事件  
	    local putOutType = 0 --  1摸牌出牌  2 碰牌出牌 

		if allRoomInfo.cur_play_operator then
			if allRoomInfo.cur_play_operator == "WAIT_PLAY_CARD" then	
				putOutType = 1
			elseif allRoomInfo.cur_play_operator == "WAIT_PLAY_CARD_FROM_PENG" then
				putOutType = 2
			end
		end	
		if putOutType == 1 then
		    --检测杠
			local tempHandCards = {}

			for k,v in pairs(self._allPlayerHandCardsValue[self.POSITION_TYPE.NAN]) do
				table.insert(tempHandCards, v)
			end

			local anGangCards = lt.CommonUtil:getCanAnGangCards(tempHandCards) 

			local pengGang = lt.CommonUtil:getCanPengGangCards(self._allPlayerCpgCardsValue[self.POSITION_TYPE.NAN], tempHandCards)

			if #anGangCards > 0 or #pengGang > 0 then
				tObjCpghObj.tObjGang = {}
			end

			for i,v in ipairs(anGangCards) do
				table.insert(tObjCpghObj.tObjGang, v)
			end

			for i,v in ipairs(pengGang) do
				table.insert(tObjCpghObj.tObjGang, v)
			end

			--检测胡
			if lt.CommonUtil:checkIsHu(tempHandCards, true) then
				tObjCpghObj.tObjHu = {}
			else
				print("没有自摸###########################################")
			end			
		end

        --显示吃碰杠胡控件
        self._deleget:viewHideActPanelAndMenu()
        self._deleget:resetActionButtonsData(tObjCpghObj)--将牌的数据绑定到按钮上
        self._deleget:viewActionButtons(tObjCpghObj, true)
	end

	for i,direction in ipairs(self._currentGameDirections) do
		self:configAllPlayerCards(direction, true, true, true)
	end

	lt.DataManager:clearPushAllRoomInfo()
end

return MjEngine