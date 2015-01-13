-- eventListenerCallsModule
module(..., package.seeall)

local storyboard = require( "storyboard" )
local myData = require( "scripts.myData" )
local perspective=require("scripts.perspective")
local goToPage	
local myTransition	




----------------------------------------------------------------------------------------
-- Screen Touch Event -- Swipe to Turn Page
----------------------------------------------------------------------------------------
function onScreenTouch( event )

	if event.phase == "ended" or event.phase == "cancelled" then
		-- Detect swipe direction and change scene
		if event.xStart < event.x and (event.x - event.xStart) >= 30 then
            previousPage()
            return true
		elseif event.xStart > event.x and (event.xStart - event.x) >= 30 then 
            nextPage()
            return true
		end 
		myData.playText = 0
    end
	
    return true    -- IMPORTANT, return true to keep touches from going through to object beneath
end

----------------------------------------------------------------------------------------
-- turns the page
----------------------------------------------------------------------------------------
function previousPage()  
	goToPage = myData.currentPage - 1
	if goToPage < myData.firstPage then goToPage = myData.firstPage end
	storyboard.gotoScene( ("scripts.page" .. goToPage), "slideRight", 800  )
	
end

function zoomOut()
	print("zoom out")
	--perspective:pointAndZoom(w/2, h/2, 1, 1000, function() print("Point and Zoom") end, nil)
end

function nextPage()
	goToPage = myData.currentPage + 1
	if goToPage > myData.lastPage then goToPage = myData.firstPage end
	storyboard.gotoScene( ("scripts.page" .. goToPage), "slideLeft", 800 )
end