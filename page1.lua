--requires
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local sync = require ("scripts.soundTextSync")
local perspective=require("scripts.perspective")
local camera=perspective.createView()
local myData = require( "scripts.myData" )
local myEvents = require( "scripts.myEvents" )

----------------------------------------------------------------------------------
-- 
--      NOTE:
--      
--      Code outside of listener functions (below) will only be executed once,
--      unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

-- local forward references should go here --
local pageNumber = 1
local audioFile = "audio/pageA.wav"
local backgroundFile = "images/A.jpg"
local voice = {
  {start=0.174150, out=0.702404, name="Two", newline=false},
  {start=0.737234, out=1.387392, name="little", newline=false},
  {start=1.480272, out=1.880816, name="kittens,", newline=true},
  {start=1.956281, out=2.159456, name="one", newline=false},
  {start=2.159456, out=2.763175, name="stormy", newline=false},
  {start=2.763175, out=3.159456, name="night,", newline=true},
}

local w = display.contentWidth
local h = display.contentHeight
local imgScale = 1
local blackText = {}
local redText = {}
local textX = 50
local textY = 50
local buttonX = textX - 30
local buttonY = textY + 8
local background
local playBlackText1 = {}
local playRedText1 = {}
local playBlackText2 = {}
local playRedText2 = {}
local playBlackButton1
local playRedButton1
local playBlackButton2
local playRedButton2
local blackButton
local redButton
 
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	-----------------------------------------------------------------------------
	--      CREATE display objects and add them to 'group' here.
	--      Example use-case: Restore 'group' from previously saved state.
	-----------------------------------------------------------------------------
	local screenGroup = self.view
	
	
	--background
	background = display.newRect( 0, 0, w, h )
	background:setFillColor( 255, 255, 255 )
	screenGroup:insert(background)
	
	--images
	local myImg = display.newImage(backgroundFile)
	myImg:setReferencePoint(display.TopRightReferencePoint)
	myImg:setReferencePoint(display.TopRightReferencePoint)
	myImg:scale(imgScale, imgScale)
	myImg.x = w*0.95
	myImg.y = h*0.08
	
	--buttons
	redButton = sync.displayButton{x=buttonX, y=buttonY, w=20, h=20,color={255,0,0}}
	blackButton = sync.displayButton{x=buttonX, y=buttonY, w=20,h=20,color={0,0,0}}

	--text
	blackText = sync.displayText{x= textX,y=textY,color={0,0,0},alpha=1,addListner=true, voiceData=voice}
	redText = sync.displayText{x= textX,y=textY,color={255,0,0},alpha=0, voiceData=voice}
	
	-- add display objects to camera display group
	camera:add(myImg, 2, false)
	camera:add(redButton, 2, false)
	camera:add(blackButton, 2, false)
	
	for i = 1, #blackText do
		  camera:add(blackText[i], 2, false)
	end
	
	for i = 1, #redText do
		  camera:add(redText[i], 2, false)
	end
	
	-- add camera display group to screenGroup 
	screenGroup:insert(camera)
	
	
	 
end
local function AutoplayListener( event )
	myEvents.nextPage()
end

local function zoomOutListener( event )
	camera:pointAndZoom(w/2, h/2, 1, 2000, function() print("Point and Zoom") end, nil)
end

function pressPlay ()
	playBlackText1, playRedText1, playBlackText2, playRedText2 = sync.saySentence(voice, blackText, redText)
	playBlackButton1, playRedButton1, playBlackButton2, playRedButton2 = sync.animateBtn(blackButton, redButton)
	sync.playAudio(audioFile)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
	local group = self.view
	-----------------------------------------------------------------------------
	--      This event requires build 2012.782 or later.
	-----------------------------------------------------------------------------
	myData.currentPage = pageNumber
	-- begin listening for screen touches
	Runtime:addEventListener( "touch", myEvents.onScreenTouch )
	blackButton:addEventListener( "tap", pressPlay )

	-- point camera
	-- point to top left
	camera:pointAndZoom(w*0.5, h*0.65, 2, 0, nil, nil)
	-- point to bottom left
	-- camera:pointAndZoom(w*0.5, h*1.4, 2, 0, nil, nil)
	
	
	if  myData.readMode == "readMyself" then
		--zoomOut
	end
	
	if  myData.readMode == "readToMe" then
		pressPlay()
		--zoomOut
		zoomOutTimer = timer.performWithDelay( 5000, zoomOutListener )
	end

	if myData.readMode == "autoplay"  then
		pressPlay()
		--start turnPageTimer
		turnPageTimer = timer.performWithDelay( 10000, AutoplayListener )
		--zoomOut
		zoomOutTimer = timer.performWithDelay( 5000, zoomOutListener )
	end

end




-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	--      INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	-----------------------------------------------------------------------------
	
	
	

	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	-----------------------------------------------------------------------------
	--      INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	-----------------------------------------------------------------------------
	blackButton:removeEventListener( "tap", pressPlay )
	Runtime:removeEventListener( "touch", myEvents.onScreenTouch )
	sync.stopNBC()
	for i = 1,#playBlackText1 do
		transition.cancel(playBlackText1[i])
		transition.cancel(playRedText1[i])
		transition.cancel(playBlackText2[i])
		transition.cancel(playRedText2[i])
		blackText[i].alpha = 1
		redText[i].alpha = 0
		
		--Rectangles[i].x = 0+25
	end
	transition.cancel(playBlackButton1)
	transition.cancel(playRedButton1)
	transition.cancel(playBlackButton2)
	transition.cancel(playRedButton2)
	blackButton.alpha = 1
	redButton.alpha = 0
	
	if (myData.readMode=="autoplay")then
		sync.stopTimer()
	end

end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
	local group = self.view

	-----------------------------------------------------------------------------

	--      This event requires build 2012.782 or later.

	-----------------------------------------------------------------------------

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view

	-----------------------------------------------------------------------------

	--      INSERT code here (e.g. remove listeners, widgets, save state, etc.)

	-----------------------------------------------------------------------------

end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
	local group = self.view
	local overlay_name = event.sceneName  -- name of the overlay scene

	-----------------------------------------------------------------------------

	--      This event requires build 2012.797 or later.

	-----------------------------------------------------------------------------

end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
	local group = self.view
	local overlay_name = event.sceneName  -- name of the overlay scene

	-----------------------------------------------------------------------------

	--      This event requires build 2012.797 or later.

	-----------------------------------------------------------------------------

end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene