--[[
Project: Perspective
Author: CMP
Version: 1.0
 
A library for easy camera movement, layer support, etc...
 
--]]
 
--perspective.lua
 
local perspective={}
local currentZoom
 
local function createView()
        local view=display.newGroup()
        
        view.boundsX=0
        view.boundsX2=display.contentWidth
        view.boundsY=0
        view.boundsY2=display.contentHeight
        
        view.focus={x=view.x, y=view.y}
        
        view.offsetX=0
        view.offsetY=0
        
        view.scrollX=0
        view.scrollY=0
        
        view.damping=0
        view.prevX, view.prevY=0, 0
        view.x2, view.y2=0, 0
        
        local layer={}
 
        layer[8]=display.newGroup()
        layer[7]=display.newGroup()
        layer[6]=display.newGroup()
        layer[5]=display.newGroup()
        layer[4]=display.newGroup()
        layer[3]=display.newGroup()
        layer[2]=display.newGroup()
        layer[1]=display.newGroup()
 
        view:insert(layer[8])
        view:insert(layer[7])
        view:insert(layer[6])
        view:insert(layer[5])
        view:insert(layer[4])
        view:insert(layer[3])
        view:insert(layer[2])
        view:insert(layer[1])
        
        function view:add(obj, perspective, isFocus)
                local obj=obj
        
                local isFocus=isFocus or false
                local perspective=perspective or 4
                
                if perspective<=9 and perspective>=1 then
                        layer[perspective]:insert(obj)
                        obj.layer=perspective
                        if isFocus==true then
                                view.focus=obj
                        end
                
                        function obj:toLayer(newLayer)
                                if layer[newLayer] then
                                        layer[newLayer]:insert(obj)
                                        obj.layer=newLayer
                                else
                                        print("ERROR: Invalid layer #"..newLayer..".")
                                end
                        end
                        
                        function obj:backward()
                                if layer[obj.layer+1] then
                                        layer[obj.layer+1]:insert(obj)
                                        obj.layer=obj.layer+1
                                end
                        end
                        
                        function obj:forward()
                                if layer[obj.layer-1] then
                                        layer[obj.layer-1]:insert(obj)
                                        obj.layer=obj.layer-1
                                end
                        end
                        
                        function obj:before(obj2)
                                if obj2 and obj2.layer then
                                        layer[obj2.layer]:insert(obj)
                                        obj.layer=obj2.layer
                                end
                        end
                        
                        function obj:behind(obj2)
                                if obj2 and obj2.layer and layer[obj2.layer+1] then
                                        layer[obj2.layer+1]:insert(obj)
                                        obj.layer=obj2.layer
                                end
                        end
                        
                else
                        print("ERROR: Invalid layer #"..perspective..".")
                end
        end
        
        function view:track()
        
                local function moveX()
                        if view.focus then
                                if (view.focus.x > view.boundsX and view.focus.x < view.boundsX2) then
                                        view.x=-view.focus.x+display.contentWidth/2+view.offsetX
                                        view.scrollX=-view.focus.x+display.contentWidth/2+view.offsetX
                                end
                        end
                end
 
                local function moveY()
                        if view.focus then
                                if (view.focus.y>view.boundsY and view.focus.y<view.boundsY2) then
                                        view.y=-view.focus.y+display.contentHeight/2+view.offsetY
                                        view.scrollY=-view.focus.y+display.contentHeight/2+view.offsetY
                                end
                        end
                end
                
                local function move()
                        moveX()
                        moveY()
                end
                
                if not view.enterFrame then
                        view.enterFrame=move
                        Runtime:addEventListener("enterFrame", view)
                end
        end
        
        function view:cancel()
                if view.enterFrame then
                        Runtime:removeEventListener("enterFrame", view)
                        view.enterFrame=nil
                end
        end
        
        function view:remove(obj)
                layer[obj.layer]:remove(obj)
        end
        
        function view:setBounds(x, x2, y, y2)
                local x=x or 0
                local x2=x2 or display.contentWidth
                local y=y or 0
                local y2=y2 or display.contentHeight
                
                view.boundsX, view.boundsX2, view.boundsY, view.boundsY2=x, x2, y, y2
        end
        
        function view:toPoint(x, y, time, onComplete, t)
                local x=x or display.contentWidth/2
                local y=y or display.contentHeight/2
                local time=time or 1000
                local onComplete=onComplete or nil
                local t=t or nil
        
                view:cancel()
                return transition.to(view, {x=-x+display.contentWidth/2, y=-y+display.contentHeight/2, onComplete=onComplete, transition=t, time=time})                      
        end
        
		function view:pointAndZoom(x, y, zoom, time, onComplete, t)
                local x=x or display.contentWidth/2
                local y=y or display.contentHeight/2
				local zoom=zoom or 1
                local time=time or 1000
                local onComplete=onComplete or nil
                local t=t or nil
        
                view:cancel()
                return transition.to(view, {x=-x+display.contentWidth/2, y=-y+display.contentHeight/2, xScale = zoom, yScale = zoom, onComplete=onComplete, transition=t, time=time})                      
        end
		
        function view:setFocus(obj)
                view.focus=obj
        end
        
        function view:destroy()
                if view.enterFrame then
                        Runtime:removeEventListener("enterFrame", view)
                        view.enterFrame=nil
                end
                display.remove(view)
                view=nil
                return true
        end
        
        return view
end
 
perspective.createView=createView
return perspective