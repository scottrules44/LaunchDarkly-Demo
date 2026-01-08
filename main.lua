local widget = require("widget")
local json = require("json")
local launchdarkly = require("plugin.launchDarkly")

-- Background
local background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
background:setFillColor(0.1, 0.2, 0.3)

-- Title
local title = display.newText({
    text = "LaunchDarkly Demo",
    x = display.contentCenterX,
    y = 40,
    font = native.systemFontBold,
    fontSize = 28
})
title:setFillColor(1, 1, 1)

-- Status text
local statusText = display.newText({
    text = "Initializing...",
    x = display.contentCenterX,
    y = 80,
    font = native.systemFont,
    fontSize = 14
})
statusText:setFillColor(0.7, 0.9, 0.7)

-- Initialize LaunchDarkly
local config = {
    offline = false,
    evaluationReasons = true
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

launchdarkly.init("YOUR_MOBILE_KEY", config, context, 5000)

-- Register listeners
launchdarkly.registerFeatureFlagListener("new-feature", function(event)
    print("✓ Flag 'new-feature' changed!")
    statusText.text = "Flag 'new-feature' changed!"
end)

launchdarkly.registerStatusListener(function(event)
    if event.type == "connectionChanged" then
        print("✓ Connection mode: " .. event.connectionInfo.connectionMode)
        statusText.text = "Connected: " .. event.connectionInfo.connectionMode
    elseif event.type == "internalFailure" then
        print("✗ Internal failure: " .. event.failure.message)
        statusText.text = "Error: " .. event.failure.message
    end
end)

-- Create scroll view
local scrollView = widget.newScrollView({
    top = 110,
    left = 0,
    width = display.contentWidth,
    height = display.contentHeight - 120,
    scrollWidth = display.contentWidth,
    scrollHeight = 1400,
    hideBackground = true,
    horizontalScrollDisabled = true
})

-- Button handler
local function onButtonPress(id)
    print("\n=== " .. id .. " ===")
    
    if id == "boolVariation" then
        local enabled = launchdarkly.boolVariation("new-feature", false)
        print("Feature enabled:", enabled)
        statusText.text = "Feature enabled: " .. tostring(enabled)
        
    elseif id == "stringVariation" then
        local theme = launchdarkly.stringVariation("app-theme", "default")
        print("Theme:", theme)
        statusText.text = "Theme: " .. theme
        
    elseif id == "intVariation" then
        local maxItems = launchdarkly.intVariation("max-items", 10)
        print("Max items:", maxItems)
        statusText.text = "Max items: " .. maxItems
        
    elseif id == "doubleVariation" then
        local price = launchdarkly.doubleVariation("price-multiplier", 1.0)
        print("Price multiplier:", price)
        statusText.text = "Price multiplier: " .. price
        
    elseif id == "jsonVariation" then
        local config = launchdarkly.jsonVariation("app-config", "{}")
        print("Config:", config)
        statusText.text = "Config received"
        
    elseif id == "boolVariationDetail" then
        local detail = launchdarkly.boolVariationDetail("new-feature", false)
        print("Value:", detail.value)
        print("Variation index:", detail.variationIndex)
        print("Reason:", detail.reason)
        statusText.text = "Variation: " .. tostring(detail.variationIndex)
        
    elseif id == "allFlags" then
        local flags = launchdarkly.allFlags()
        print("All flags:", json.encode(flags))
        local count = 0
        for _ in pairs(flags) do count = count + 1 end
        statusText.text = "Retrieved " .. count .. " flags"
        
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
        print("✓ Identified new user")
        statusText.text = "Identified: user-456"
        
    elseif id == "getContext" then
        local ctx = launchdarkly.getContext()
        if ctx then
            print("Current context:", ctx.key)
            print("Name:", ctx.name)
            statusText.text = "Context: " .. (ctx.key or "unknown")
        else
            statusText.text = "No context available"
        end
        
    elseif id == "track" then
        launchdarkly.track("button_clicked", {button = "demo"})
        print("✓ Event tracked: button_clicked")
        statusText.text = "Event tracked: button_clicked"
        
    elseif id == "trackMetric" then
        launchdarkly.track("purchase", {item = "widget"}, 29.99)
        print("✓ Metric tracked: purchase ($29.99)")
        statusText.text = "Tracked: purchase $29.99"
        
    elseif id == "setOffline" then
        launchdarkly.setOffline()
        print("✓ SDK offline mode enabled")
        statusText.text = "Mode: Offline"
        
    elseif id == "setOnline" then
        launchdarkly.setOnline()
        print("✓ SDK online mode enabled")
        statusText.text = "Mode: Online"
        
    elseif id == "flush" then
        launchdarkly.flush()
        print("✓ Events flushed")
        statusText.text = "Events flushed"
        
    elseif id == "isInitialized" then
        local initialized = launchdarkly.isInitialized()
        print("Initialized:", initialized)
        statusText.text = "Initialized: " .. tostring(initialized)
        
    elseif id == "isOffline" then
        local offline = launchdarkly.isOffline()
        print("Offline:", offline)
        statusText.text = "Offline: " .. tostring(offline)
        
    elseif id == "getVersion" then
        local version = launchdarkly.getVersion()
        print("SDK Version:", version)
        statusText.text = "Version: " .. version
    end
end

-- Create button function
local function createButton(params)
    local button = display.newRoundedRect(
        display.contentCenterX,
        params.y,
        display.contentWidth - 40,
        55,
        8
    )
    button:setFillColor(0.2, 0.6, 0.8)
    button.id = params.id
    
    local label = display.newText({
        text = params.label,
        x = display.contentCenterX,
        y = params.y,
        font = native.systemFont,
        fontSize = 18
    })
    label:setFillColor(1, 1, 1)
    
    button:addEventListener("touch", function(event)
        if event.phase == "ended" then
            -- Visual feedback
            button:setFillColor(0.3, 0.7, 0.9)
            timer.performWithDelay(100, function()
                button:setFillColor(0.2, 0.6, 0.8)
            end)
            
            onButtonPress(button.id)
        end
        return true
    end)
    
    scrollView:insert(button)
    scrollView:insert(label)
end

-- Button definitions
local buttons = {
    -- Flag Evaluation
    {label = "Bool Variation", id = "boolVariation", y = 20},
    {label = "String Variation", id = "stringVariation", y = 90},
    {label = "Int Variation", id = "intVariation", y = 160},
    {label = "Double Variation", id = "doubleVariation", y = 230},
    {label = "JSON Variation", id = "jsonVariation", y = 300},
    {label = "Bool Variation Detail", id = "boolVariationDetail", y = 370},
    {label = "Get All Flags", id = "allFlags", y = 440},
    
    -- Context Management
    {label = "Identify User", id = "identify", y = 530},
    {label = "Get Current Context", id = "getContext", y = 600},
    
    -- Event Tracking
    {label = "Track Event", id = "track", y = 690},
    {label = "Track Event with Metric", id = "trackMetric", y = 760},
    
    -- Connection Management
    {label = "Set Offline", id = "setOffline", y = 850},
    {label = "Set Online", id = "setOnline", y = 920},
    {label = "Flush Events", id = "flush", y = 990},
    
    -- Status
    {label = "Check Initialized", id = "isInitialized", y = 1080},
    {label = "Check Offline Status", id = "isOffline", y = 1150},
    {label = "Get SDK Version", id = "getVersion", y = 1220}
}

-- Create all buttons
for i = 1, #buttons do
    createButton(buttons[i])
end

-- Cleanup on exit
Runtime:addEventListener("system", function(event)
    if event.type == "applicationExit" then
        print("\n=== Closing LaunchDarkly SDK ===")
        launchdarkly.close()
    end
end)

-- Initial status check
timer.performWithDelay(1000, function()
    if launchdarkly.isInitialized() then
        statusText.text = "✓ SDK Initialized"
        statusText:setFillColor(0.7, 1, 0.7)
    else
        statusText.text = "⚠ SDK Not Initialized"
        statusText:setFillColor(1, 0.7, 0.7)
    end
end)
