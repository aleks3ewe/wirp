SearchPlayerUI = ISPanel:derive("SearchPlayerUI");

function SearchPlayerUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = 25
    local btnHgt2 = 18
    local padBottom = 10
    local listWidh = (self.width) - 10;
    local listHeight = 250;

    self.infoBtn = ISButton:new(10, 10, 70, 25, getText("UI_InfoBtn"), self, SearchPlayerUI.onClick);
    self.infoBtn.internal = "INFO";
    self.infoBtn:initialise();
    self.infoBtn:instantiate();
    self.infoBtn.borderColor = { r = 1, g = 1, b = 1, a = 0.4 };
    self:addChild(self.infoBtn);

    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, SearchPlayerUI.onClick);
    self.no.internal = "CANCEL";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=1, b=1, a=0.4};
    self:addChild(self.no);

    self.foundItems = ISScrollingListBox:new(20, 70, listWidh - 30, listHeight);
    self.foundItems:initialise();
    self.foundItems:instantiate();
    self.foundItems.itemheight = 22;
    self.foundItems.selected = 0;
    self.foundItems.joypadParent = self;
    self.foundItems.font = UIFont.NewSmall;
    self.foundItems.doDrawItem = self.drawOffer;
    self.foundItems.drawBorder = true;
    self.foundItems:setVisible(false);
    self:addChild(self.foundItems);

    print(self.otherPlayer);

    sendClientCommand("SearchPlayer", "requestServerItems", { self.otherPlayer:getOnlineID() })
end

function SearchPlayerUI:onClick(button)
    if button.internal == "INFO" then
        if not self.infoRichText then
            self.infoRichText = ISModalRichText:new(getCore():getScreenWidth()/2-400,getCore():getScreenHeight()/2-300,600,600,getText("UI_SearchingUIHelp"), false);
            self.infoRichText.destroyOnClick = false;
            self.infoRichText:initialise();
            self.infoRichText:addToUIManager();
            self.infoRichText.chatText:paginate();
            self.infoRichText.backgroundColor = {r=0, g=0, b=0, a=1};
            self.infoRichText:setHeight(self.infoRichText.chatText:getHeight() + 40);
            self.infoRichText:setY(getCore():getScreenHeight()/2-(self.infoRichText:getHeight()/2));
            self.infoRichText:setVisible(true);
        else
            self.infoRichText:setVisible(not self.infoRichText:getIsVisible());
            self.infoRichText:bringToTop();
        end
    end
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

function SearchPlayerUI:updateTooltip()
    local x = self:getMouseX();
    local y = self:getMouseY();
    local item = nil;
    if x >= self.foundItems:getX() and x <= self.foundItems:getX() + self.foundItems:getWidth() and y >= self.foundItems:getY() and y <= self.foundItems:getY() + self.foundItems:getHeight() then
        y = self.foundItems:rowAt(self.foundItems:getMouseX(), self.foundItems:getMouseY())
        if self.foundItems.items[y] then
            item = self.foundItems.items[y];
        end
    end

    if item then
        if self.toolRender then
            self.toolRender:setItem(item.item);
            if not self:getIsVisible() then
                self.toolRender:setVisible(false);
            else
                self.toolRender:setVisible(true);
                self.toolRender:addToUIManager();
                self.toolRender:bringToTop();
            end
        else
            self.toolRender = ISToolTipInv:new(item.item);
            self.toolRender:initialise();
            self.toolRender:addToUIManager();
            if not self:getIsVisible() then
                self.toolRender:setVisible(true);
            end
            self.toolRender:setOwner(self);
            self.toolRender:setCharacter(self.player);
            self.toolRender:setX(self:getMouseX());
            self.toolRender:setY(self:getMouseY());
            self.toolRender.followMouse = true;
        end
    else
        if self.toolRender then
            self.toolRender:setVisible(false)
        end
    end
end

function SearchPlayerUI:drawOffer(y, item, alt)
    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    self:drawTextureScaledAspect(item.item:getTex(), 5, y + 2, 18, 18, 1, item.item:getR(), item.item:getG(), item.item:getB());
    self:drawText(item.text, 25, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function SearchPlayerUI:prerender()
    local z = 15;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawText(getText("UI_Searching"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("UI_Searching")) / 2), z, 1,1,1,1, UIFont.Medium);
    if self.foundAnything then
        self:drawText(getText("UI_SearchingItemsFound"), self.foundItems.x, self.foundItems.y - 32, 1,1,1,1, UIFont.Small);
    else
        self:drawText(getText("UI_SearchingNoItems"), self.foundItems.x, self.foundItems.y, 1,1,1,1, UIFont.Small);
    end
    -- self:drawText(getText("IGUI_TradingUI_HisOffer", self.otherPlayer:getDisplayName()), self.hisOfferDatas.x, self.hisOfferDatas.y - 32, 1,1,1,1, UIFont.Small);
end

function SearchPlayerUI:render()
    self:updateTooltip();

    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
end

function SearchPlayerUI:new(x, y, width, height, player, otherPlayer)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    width = 350;
    height = 450;
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    player:StopAllActionQueue();
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.listHeaderColor = {r=0.4, g=0.4, b=0.4, a=0.3};
    o.width = width;
    o.height = height;
    o.player = player;
    o.otherPlayer = otherPlayer;
    o.moveWithMouse = true;
    o.foundAnything = false;
    SearchPlayerUI.instance = o;
    return o;
end

SearchPlayerUI.ReceiveItem = function (player, item)
    --print("Searched " .. player:getDisplayName() .. " and found a " .. item:getName());
    if SearchPlayerUI.instance and SearchPlayerUI.instance:isVisible() then
        SearchPlayerUI.instance.foundItems:addItem(item:getName(), item);
        SearchPlayerUI.instance.foundItems:setVisible(true);
        SearchPlayerUI.instance.foundAnything = true;
    end
end

Events.TradingUIAddItem.Add(SearchPlayerUI.ReceiveItem)