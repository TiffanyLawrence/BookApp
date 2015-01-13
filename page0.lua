-----------------------------------------------------------------------------------------
--
-- page0.lua
-- displays menu
--
-----------------------------------------------------------------------------------------
local myData = require( "scripts.myData" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
--------------------------------------------

-- forward declaration
local background
local txtAutoplay 
local txtReadToMe
local txtReadMyself
local txtOptions
local txtQuit
local w = display.contentWidth
local h = display.contentHeight
local txtX = w*.1

local function onAutoplayTouch( event )
	myData.readMode = "autoplay"
	if event.phase == "ended" or event.phase == "cancelled" then
		-- go to page1.lua 
		storyboard.gotoScene( "scripts.page1", "slideLeft", 800 )
		
		return true	-- indicates successful touch
	end
end

local function onReadToMeTouch( event )
	myData.readMode = "readToMe"
	if event.phase == "ended" or event.phase == "cancelled" then
		-- go to page1.lua scene
		storyboard.gotoScene( "scripts.page1", "slideLeft", 800 )
		
		return true	-- indicates successful touch
	end
end

local function onReadMyselfTouch( event )
	myData.readMode = "readMyself"
	if event.phase == "ended" or event.phase == "cancelled" then
		-- go to page1.lua scene
		storyboard.gotoScene( "scripts.page1", "slideLeft", 800 )
		
		return true	-- indicates successful touch
	end
end


-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- display a background image
	background = display.newRect( 0, 0, w, h )
	background:setFillColor( 255, 255, 255 )

	-- Add Autoplay
	txtAutoplay = display.newText("Autoplay", txtX, 50, native.systemFont, 32)
	txtAutoplay:setTextColor(0, 0, 0)	
	
	-- Read to Me
	txtReadToMe = display.newText("Read to Me", txtX, 100, native.systemFont, 32)
	txtReadToMe:setTextColor(0, 0, 0)
	
	-- Read By Myself
	txtReadMyself = display.newText("Read Myself", txtX, 150, native.systemFont, 32)
	txtReadMyself:setTextColor(0, 0, 0)
	
	-- Options
	txtOptions = display.newText("Options", txtX, 200, native.systemFont, 32)
	txtOptions:setTextColor( 0, 0, 0 )
	
	-- Quit
	txtQuit = display.newText ("Quit", txtX, 250, native.systemFont, 32)
	txtQuit:setTextColor( 0, 0, 0 )
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( txtAutoplay )
	group:insert( txtReadToMe )
	group:insert( txtReadMyself )
	group:insert( txtOptions )
	group:insert( txtQuit )

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	myData.currentPage = 0
	
	-- add event listeners
	txtAutoplay.touch = onAutoplayTouch
	txtAutoplay:addEventListener( "touch", onAutoplayTouch )
	
	txtReadToMe.touch = onReadToMeTouch
	txtReadToMe:addEventListener( "touch", onReadToMeTouch )
	
	txtReadMyself.touch = onReadMyselfTouch
	txtReadMyself:addEventListener( "touch", onReadMyselfTouch )
	
	txtOptions.touch = onOptionsTouch
	txtOptions:addEventListener( "touch", onOptionsTouch)
	
	
end

-- Called when scene is about to move offscreen
function scene:exitScene( event )
	local group = self.view
	
	-- remove event listeners
	txtAutoplay:removeEventListener( "touch", onAutoplayTouch )
	txtReadToMe:removeEventListener( "touch", onReadToMeTouch )
	txtReadMyself:removeEventListener( "touch", onReadMyselfTouch )
	txtOptions:removeEventListener( "touch", onOptionsTouch )
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)
	
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene