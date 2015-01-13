-- Thanks to Electic Eggplant for the outline of this algorithm
-- define a local table to store all references to functions/variables
local M = {}


local myData = require( "scripts.myData" )
local myEvents = require ( "scripts.myEvents" )
local storyboard = require( "storyboard" )
--local turnPageTimer
local audioFile
local blackText = {}
local redText = {}
local zoomOutTimer
local soundLength

------------------------------------------------------------------------------------------
-- Data is obtained by loading the full audio track into Audacity (freeware
-- sound editing program), selecting each word and creating a label. The word spoken
-- is the name for the label. Then Export Labels to create a text file with the data.
-- Times are in seconds, so multiply by 1000 to convert to milliseconds.
-- Add newline=true where you want a CRLF (so the following line starts on a new line)
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Using the voice table, display the text by creating an object for each word
------------------------------------------------------------------------------
local function displayText(params)
  local x,y,color,alpha,voice = params.x, params.y, params.color, params.alpha, params.voiceData
  local xOffset = 0
  local words={}
  local fontSize = myData.fontSize
  local lineHeight = fontSize*1.33
  local space = fontSize/5
  local currentScene = storyboard.getCurrentSceneName()

 
  for i = 1,#voice do
		words[i] = display.newText(voice[i].name, x+xOffset, y, native.systemFont, fontSize)
		words[i]:setTextColor( color[1],color[2],color[3])
		words[i].alpha = alpha
		-- convert to lower case and remove punctuation from name so we can use it 
		-- to grab the correct audio file later
		words[i].name = string.lower(string.gsub(voice[i].name, "['., ]", ""))
		words[i].id = i
		-- calculate the duration of each word
		words[i].dur = (voice[i].out - voice[i].start) * 1000
		if params.addListner then
		  words[i]:addEventListener( "tap", speakWord )
		end
		xOffset = xOffset + words[i].width + space
		if voice[i].newline then y = y + lineHeight; xOffset = 0 end
  end
  
  soundLength = voice[#voice].out*1000
  return words
end
M.displayText = displayText

----------------------------------------------------------------------------
-- Add a button to start the talking
----------------------------------------------------------------------------
local function displayButton(params)
  local x,y,w,h,color = params.x, params.y, params.w, params.h, params.color
  local rect = display.newRect(x, y, w, h)
  rect:setFillColor(color[1],color[2],color[3])
  return rect
end
M.displayButton = displayButton

-----------------------------------------------------------------------------
-- not currently being called
-----------------------------------------------------------------------------
local function stopNBC()
  media.stopSound("audio/pageA.wav")
end
M.stopNBC = stopNBC

--automatically zooms out after text reading completes
local function zoomOutListener( event )
	myEvents.zoomOut()
end

--automatically turns page if autoplay is selected
--local function AutoplayListener( event )
	--myEvents.nextPage()
--end


-------------------------------------------------------------------------------------------
-- The button was pressed, so start talking. Highlight each word as it's spoken.
-- trans1 is the delay in milliseconds for the fade to red as the word is spoken
-- trans2 is the delay in milliseconds for the fade back to black after the word is spoken
-- use a shorter trans1 value for snappier response. Longer trans2 to make the fade
-- back to black more fluid.
--------------------------------------------------------------------------------------------
local function saySentence(voice, blackText, redText)
	local delay1, delay2, trans1, trans2 = 0,0,50,400
	local playBlackText1 = {}
	local playRedText1 = {}
	local playBlackText2 = {}
	local playRedText2 = {}
	local zoomOut 
	  
	for i = 1,#voice do
		-- start transition early so it's full red by the time the word is spoken
		delay1 = voice[i].start*1000 - trans1
		if delay1 <0 then delay1 = 0 end
		-- add extra time at the end so we never finish before the fade is complete
		delay2 = voice[i].out*1000 + trans2
		playBlackText1[i] = transition.to( blackText[i], { alpha=0, time=trans1, delay=delay1} )
		playRedText1[i] = transition.to( redText[i], { alpha=1, time=trans1, delay=delay1} )
		playBlackText2[i] = transition.to( blackText[i], { alpha=1, time=trans2, delay=delay2} )
		playRedText2[i] = transition.to( redText[i], { alpha=0, time=trans2, delay=delay2} )
	end

	-----
	--if (myData.readMode=="autoplay" or myData.readMode=="readToMe")then
		--zoomOutTimer = timer.performWithDelay( delay2+2000, zoomOutListener )
	--end
	--transition.to(view, {x=-x+display.contentWidth/2, y=-y+display.contentHeight/2, xScale = zoom, yScale = zoom, onComplete=onComplete, transition=t, time=time})
	--if (myData.readMode=="autoplay")then
		--turnPageTimer = timer.performWithDelay( delay2+5000, AutoplayListener )
	--end
	return playBlackText1, playRedText1, playBlackText2, playRedText2
end
M.saySentence = saySentence

local function animateBtn(blackButton, redButton)
	local trans1, trans2 = 50,400
	local playBlackButton1
	local playRedButton1
	local playBlackButton2
	local playRedButton2 
	    
	-- switch to red button so it's not touchable
	playBlackButton1 = transition.to(blackButton, {time=trans1, alpha=0, delay=0})
	playBlackButton2 = transition.to(blackButton, {time=trans1, alpha=1, delay=soundLength+trans2})
	playRedButton1 = transition.to(redButton, {time=trans1, alpha=1, delay=0})
	playRedButton2 = transition.to(redButton, {time=trans1, alpha=0, delay=soundLength+trans2})

	return playBlackButton1, playRedButton1, playBlackButton2, playRedButton2
end
M.animateBtn = animateBtn

local function playAudio(audioFile)
	media.stopSound(audioFile)
	media.playSound(audioFile)
end
M.playAudio = playAudio

local function stopTimer()
	--cancel auto page turn
		--timer.cancel(turnPageTimer)
end
M.stopTimer = stopTimer

--------------------------------------------------------------------------------------------
-- called by event: play button pressed
--------------------------------------------------------------------------------------------
--local function pressPlay(event)
	--saySentence()
--end
--M.pressPlay = pressPlay

-------------------------------------------------------------------------------------------
-- A word was touched, so say it now. Disabled during speech.
-------------------------------------------------------------------------------------------
function speakWord( event )
	local word = event.target
	local id, name, dur = word.id, word.name, word.dur
	local trans = 200
	-- was the sentence button pushed or this word already active? If so, return now.
	if blackButton.alpha == 0 or word.alpha ~= 1 then return end
	-- make sure the duration is at least longer than 2 transition times
	dur = dur + 2*trans
	media.playEventSound("snippets/"..name..".wav")
	transition.dissolve(word,redText[id],trans,0)
	transition.dissolve(redText[id],word,trans,dur)
	return true
end
M.speakWord = speakWord

return M