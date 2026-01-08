local widget = require("widget")
local json = require("json")
local launchdarkly = require("plugin.LaunchDarkly")
local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
background:setFillColor(0.1, 0.2, 0.3) -- Dark blue background

-- Title
local title = display.newText({
    text = "LaunchDarkly API Sample",
    x = display.contentCenterX,
    y = 50,
    font = native.systemFontBold,
    fontSize = 24
})
title:setFillColor(1, 1, 1) 

-- Initialize LaunchDarkly
local config = {
    offline = false,
    evaluationReasons = true,
    logLevel = "INFO"
}

local context = {
    key = "user-123",
    name = "Test User",
    email = "test@example.com",
    anonymous = false,
    custom = {
        plan = "premium",
        region = "us-east"
    }
}

launchdarkly.init("YOUR_MOBILE_KEY", config, context, 0)

-- Register listeners
launchdarkly.registerFeatureFlagListener("new-feature", function(event)
    print("Flag 'new-feature' changed!")
end)

launchdarkly.registerStatusListener(function(event)
    if event.type == "connectionChanged" then
        print("Connection mode: " .. event.connectionInfo.connectionMode)
    elseif event.type == "internalFailure" then
        print("Internal failure: " .. event.failure.message)
    end
end)

local function onButtonPress(event)
    local id = event.target.id
    print(id)
    
    if id == "boolFlag" then
        local enabled = launchdarkly.boolVariation("feature-flag-key", false)
        print("Feature enabled: ", enabled)
        
    elseif id == "stringFlag" then
        local theme = launchdarkly.stringVariation("theme", "default")
        print("Theme: ", theme)
        
    elseif id == "flagDetail" then
        local detail = launchdarkly.boolVariationDetail("feature-flag-key", false)
        print("Value: ", detail.value)
        print("Variation: ", detail.variationIndex)
        print("Reason: ", detail.reason)
        
    elseif id == "allFlags" then
        local flags = launchdarkly.allFlags()
        print("All flags: ", json.encode(flags))
        
    elseif id == "identify" then
        local newContext = {
            key = "user-456",
            name = "New User",
            email = "newuser@example.com",
            custom = {
                plan = "enterprise"
            }
        }
        launchdarkly.identify(newContext)
        print("Identified new user")
        
    elseif id == "track" then
        launchdarkly.track("button_clicked")
        print("Event tracked")
        
    elseif id == "trackMetric" then
        launchdarkly.trackMetric("purchase", {item = "widget"}, 29.99)
        print("Metric tracked")
        
    elseif id == "getContext" then
        local ctx = launchdarkly.getContext()
        if ctx then
            print("Current context key: ", ctx.key)
            print("Name: ", ctx.name)
        end
        
    elseif id == "offline" then
        launchdarkly.setOffline()
        print("SDK set to offline mode")
        
    elseif id == "online" then
        launchdarkly.setOnline()
        print("SDK set to online mode")
        
    elseif id == "flush" then
        launchdarkly.flush()
        print("Events flushed")
        
    elseif id == "isInitialized" then
        local initialized = launchdarkly.isInitialized()
        print("Initialized: ", initialized)
    end
end

-- Create buttons
local buttonParams = {
    {id = "boolFlag", label = "Bool Flag", x = display.contentCenterX - 120, y = 120},
    {id = "stringFlag", label = "String Flag", x = display.contentCenterX + 120, y = 120},
    {id = "flagDetail", label = "Flag Detail", x = display.contentCenterX - 120, y = 180},
    {id = "allFlags", label = "All Flags", x = display.contentCenterX + 120, y = 180},
    {id = "identify", label = "Identify User", x = display.contentCenterX - 120, y = 240},
    {id = "track", label = "Track Event", x = display.contentCenterX + 120, y = 240},
    {id = "trackMetric", label = "Track Metric", x = display.contentCenterX - 120, y = 300},
    {id = "getContext", label = "Get Context", x = display.contentCenterX + 120, y = 300},
    {id = "offline", label = "Go Offline", x = display.contentCenterX - 120, y = 360},
    {id = "online", label = "Go Online", x = display.contentCenterX + 120, y = 360},
    {id = "flush", label = "Flush Events", x = display.contentCenterX - 120, y = 420},
    {id = "isInitialized", label = "Check Init", x = display.contentCenterX + 120, y = 420}
}

local function createButton(params)
    local button = display.newRoundedRect(params.x, params.y, 200, 50, 8)
    button.id = params.id
    button:setFillColor(0.2, 0.6, 0.8)  -- Blue button color
    
    local label = display.newText({
        text = params.label,
        x = params.x,
        y = params.y,
        font = native.systemFont,
        fontSize = 16
    })
    label:setFillColor(1, 1, 1)
    
    -- Add functionality for buttons
    button:addEventListener("touch", function(event)
        if event.phase == "ended" then
            print(button.id .. " button tapped!")
            event.target = button
            onButtonPress(event)
        end
        return true
    end)
    
    return button
end

-- Create all buttons
for i = 1, #buttonParams do
    createButton(buttonParams[i])
end

-- Status text at bottom
local statusText = display.newText({
    text = "LaunchDarkly SDK Ready",
    x = display.contentCenterX,
    y = display.contentHeight - 30,
    font = native.systemFont,
    fontSize = 14
})
statusText:setFillColor(0.7, 0.7, 0.7)

-- Cleanup on exit
Runtime:addEventListener("system", function(event)
    if event.type == "applicationExit" then
        launchdarkly.close()
    end
end)