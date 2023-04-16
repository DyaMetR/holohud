# H0L-D4: Holographic Heads Up Display

![](https://img.shields.io/github/v/release/DyaMetR/holohud)
![](https://img.shields.io/steam/views/1705992410)
![](https://img.shields.io/steam/downloads/1705992410)
![](https://img.shields.io/steam/favorites/1705992410)
![](https://img.shields.io/github/issues/DyaMetR/holohud)
![](https://img.shields.io/github/license/DyaMetR/holohud)

Customizable holographic themed heads up display (HUD) for Garry's Mod.

## Features

+ HUD swaying with camera movement
+ Chromatic aberration
+ Health indicator
+ Armour indicator
+ Ammunition indicator
+ Weapon selector
+ Ping meter
+ Player counter
+ Prop counter
+ Killfeed
+ Speed-o-meter
+ Environmental hazards indicator
+ Clock
+ Compass
+ Damage indicator
+ Pickup history
+ Entity information
+ Target ID
+ Welcome screen

## Customization includes

+ Each elements has their own array of options
+ Font family and offsets customization
+ Blur intensity and opacity
+ Background opacity
+ Swaying

## Credits

+ *DyaMetR*
   + Design
   + Code
   + Sprites
+ *Matsilagi*
   + Testing
   + Occasional development support
+ *code_gs*
   + [Weapon selector skeleton](https://github.com/Kefta/Weapon-Switcher-Skeleton)

## Adding custom content

### Setup your configuration folder

To ensure that your configuration _loads correctly_, you'll have to make a **folder** inside your **addons** folder with a specific structure: `%YOUR_CONFIG_ADDON_FOLDER%/lua/autorun/holohud/add-ons`.

Once you created your folder you'll be able to add as many `.lua` files as you wish and the HUD will load them all. Try to use **unique file names** in order to avoid conflicts with other addons.

### Before you start writing code

All of the custom files are loaded **shared**wise, meaning that it will work in both clientside and serverside, so I'd like to remind using `if CLIENT` and `if SERVER` respectively.

### Utilizing the API

H0L-D4 offers an ample API, but I will only list the most important functions, which are those in charge of adding elements and forcing settings.

#### Add element override

`HOLOHUD.GAMEMODE:AddElementOverride( gamemode, elements )`
> **CLIENT**

> Makes an element or group of elements only work for a certain gamemode or group of gamemodes

> **@param** {string|table} gamemode or gamemodes

> **@param** {string|table} element or elements

Examples:

```lua
--[[
  Make that the hypothetical elements 'money', 'job' and 'lockdown'
  only are available when the server is running DarkRP
]]
HOLOHUD.GAMEMODE:AddElementOverride( 'darkrp', { 'money', 'job', 'lockdown' } )

--[[
  Make that the hypothetical elements 'ttt_role' and 'ttt_clock'
  only are available when the server is running Trouble in Terrorist Town
]]
HOLOHUD.GAMEMODE:AddElementOverride( 'terrortown', { 'ttt_role', 'ttt_clock' } )

--[[
  Make that the element 'prop_count' only works on Sandbox and DarkRP
]]
HOLOHUD.GAMEMODE:AddElementOverride( { 'sandbox', 'darkrp' }, 'prop_count' )

```

#### Set element override

`HOLOHUD.GAMEMODE:SetElementOverride( gamemode, elements, whitelist )`
> **CLIENT**

> Blacklists elements on certain gamemodes. The 'whitelist' parameter, if true, will make the provided element/s from the 'elements' parameter the only ones that will be shown when playing on the provided gamemode/s via the 'gamemode' parameter.

> **@param** {string|table} gamemode or gamemodes

> **@param** {string|table} element or elements

Examples:

```lua
--[[
  Disable the 'target_id' element when playing DarkRP
]]
HOLOHUD.GAMEMODE:SetElementOverride( 'darkrp', 'target_id' )

--[[
  Only the elements 'health', 'ammunition', 'ttt_role' and 'ttt_clock'
  will be the ones enabled when playing Trouble in Terrorist Town, any
  other elements will be unavailable
]]
HOLOHUD.GAMEMODE:SetElementOverride( 'terrortown', { 'health', 'ammunition', 'ttt_role', 'ttt_clock' }, true )

--[[
  Disable the 'killfeed' element from DarkRP and Trouble in Terrorist Town
]]
HOLOHUD.GAMEMODE:SetElementOverride( { 'darkrp', 'terrortown' }, 'target_id' )
```

### Add element configuration override

`HOLOHUD.GAMEMODE:AddConfigOverride( gamemode, element, config, force_default )`
> **CLIENT**

> Forces configuration parameters' values on a certain element for a certain gamemode

> **@param** {string} gamemode

> **@param** {string} element

> **@param** {table} a list with the overrided parameters and their new values

> **@param** {boolean} if true, it will force the default configuration on those parameters that were not included on the 'config' table. otherwise, it will load the user configuration.

Examples:

```lua
--[[
  Force heartrate monitor with kevlar icon and minimalistic ammunition
  indicator on DarkRP
]]
HOLOHUD.GAMEMODE:AddConfigOverride( 'darkrp', 'health', { mode = 3 } )
HOLOHUD.GAMEMODE:AddConfigOverride( 'darkrp', 'ammunition', { mode = 2 } )

--[[
  Force compact mode and always display while ignoring user configuration
  on the ammunition indicator when playing Trouble in Terrorist Town
]]
HOLOHUD.GAMEMODE:AddConfigOverride( 'terrortown', 'ammunition', { mode = 3 }, true )

```

#### Cheat sheet for element's modes

##### Health

```
1 = Default
2 = Heartbeat with armour bar
3 = Heartbeat with kevlar icon
4 = Classic
```

##### Ammunition

```
1 = Default
2 = Minimalist
3 = Compact
```

##### Clock

```
1 = Simple
2 = Digital
3 = Simple with date
```

##### Speed-o-meter (units for both in foot and in vehicle)

```
1 = km/h
2 = mph
3 = ups
```

##### Auxiliary power (for both the aux. power and the ep2 flashlight)

```
1 = Default
2 = Icon with background
3 = Icon only
```

### Setup panel

"Panels" are the rectangles used as background to draw stuff. They can be opened or closed, which will play an animation in the process.

They're independent of 'HUD elements' but are usually declared and used alongside them.

`HOLOHUD:AddFlashPanel( panel )`

> **CLIENT**

> Adds a panel to the display list

> **@param** {string} flash panel name

Example:
```lua
--[[
  Add a panel named 'out_of_ammo'
]]
HOLOHUD:AddFlashPanel( 'out_of_ammo' )
```

### Open/close a panel

`HOLOHUD:SetPanelActive( panel, active, force )`

> **CLIENT**

> Sets whether a panel should be displayed (triggers the animations)

> **@param** {string} panel name

> **@param** {boolean} whether the panel should be displayed or not

> **@param** {boolean|nil} whether it should override user configuration (should HUD hide on death and should HUD draw without the Suit)

Example:
```lua
--[[
  Trigger the panel 'out_of_ammo' when you're out of ammo
]]
local function TriggerOutOfAmmoPanel()

  local weapon = LocalPlayer():GetActiveWeapon()

  if not IsValid( weapon ) or ( weapon:GetPrimaryAmmoType() <= 0 and weapon:GetSecondaryAmmoType() <= 0 ) then return end

  local clip, reserve, alt = weapon:Clip1(), LocalPlayer():GetAmmoCount( weapon:GetPrimaryAmmoType() ), LocalPlayer():GetAmmoCount( weapon:GetSecondaryAmmoType() )

  HOLOHUD:SetPanelActive( 'out_of_ammo', clip <= 0 and reserve <= 0 and alt <= 0 )

end
```

### Draw panel with contents

`HOLOHUD:DrawFragmentAlignSimple( x, y, w, h, func, flash, align, ... )`
> **CLIENT**

> Draws an animated panel, with contents, that can be toggled

> **@param** {number} x position

> **@param** {number} y position

> **@param** {number} width

> **@param** {number} height

> **@param** {function} contents draw function

Uses the arguments: `x`, `y`, `width`, `height`

> **@param** {string} panel ID

> **@param** {TEXT_ALIGN_} flash effect alignment

> **@param** {varargs} additional parameters sent to the contents drawing function

Example:
```lua
local WIDTH, HEIGHT = 200, 50
local PANEL = 'out_of_ammo'
local LOCALE = 'OUT OF AMMO'
local FONT, COLOUR = 'holohud_med_sm', Color( 255, 0, 0 )

--[[
  Draw contents
]]
local function DrawPanel( y )

  HOLOHUD:DrawFragmentAlignSimple( ( ScrW() * .5 ) - ( WIDTH * .5 ), ScrH() * y, WIDTH, HEIGHT, function( x, y, w, h )

    HOLOHUD:DrawText( x + ( w * .5), y + ( h * .5 ), LOCALE, FONT, COLOUR, HOLOHUD:GetHighlight(PANEL), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

  end, PANEL, TEXT_ALIGN_TOP )

end
```

### Draw panel with contents (with additional parameters)

`HOLOHUD:DrawFragmentAlign( x, y, w, h, func, flash, align, colour, alpha, blurQuality, ... )`
> **CLIENT**

> Draws an animated panel, with contents, that can be toggled, with additional parameters

> **@param** {number} x position

> **@param** {number} y position

> **@param** {number} width

> **@param** {number} height

> **@param** {function} contents draw function

Uses the arguments: `x`, `y`, `width`, `height`

> **@param** {string} panel ID

> **@param** {TEXT_ALIGN_} flash effect alignment

> **@param** {Color} background colour

> **@param** {number} opacity

> **@param** {number} blur effect quality

> **@param** {varargs} additional parameters sent to the contents drawing function

Example:
```lua
local WIDTH, HEIGHT = 200, 50
local PANEL = 'out_of_ammo'
local LOCALE = 'Out of ammo'
local FONT, COLOUR = 'holohud_med_sm', Color( 255, 0, 0 )
local ALPHA = 0.5

--[[
  Draw the same as before, but with the panel being red and slightly
  transparent
]]
local function DrawPanel( y )

  HOLOHUD:DrawFragmentAlignSimple( ( ScrW() * .5 ) - ( WIDTH * .5 ), ScrH() * y, WIDTH, HEIGHT, function( x, y, w, h )

    HOLOHUD:DrawText( x + ( w * .5), y + ( h * .5 ), LOCALE, FONT, COLOUR, HOLOHUD:GetHighlight(PANEL), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

  end, PANEL, TEXT_ALIGN_TOP, COLOUR, ALPHA )

end
```

### Add a number/text/texture highlighting

"Highlighting" refers to when a number/text/texture brights for a while and then goes back to normal.

`HOLOHUD:AddHighlight( id )`
> **CLIENT**

> Adds a highlight

> **@param** {string} identifier

Example:
```lua
HOLOHUD:AddHighlight( 'out_of_ammo' )
```

### Trigger a number/text/texture highlighting

`HOLOHUD:TriggerHighlight( id )`
> **CLIENT**

> Triggers a highlight effect

> **@param** {string} identifier

Example:
```lua
local NAME = 'out_of_ammo'
local TICK_RATE = 1
local tick = 0

--[[
  Make the highlight blink every second
]]
local function AnimateHighlight()

  if tick < CurTime() then

    HOLOHUD:TriggerHighlight( NAME )
    tick = CurTime() + TICK_RATE

  end

end
```

### Get a highlight value

`HOLOHUD:GetHighlight( id )`
> **CLIENT**

> Gets the current opacity of a highlight

> **@param** {string} identifier

> **@return** {number} opacity

Example:
```lua
print( HOLOHUD:GetHighlight( 'out_of_ammo' ) )
```

Result: `0`

### Draw a number

`HOLOHUD:DrawNumber( x, y, number, colour, zeros, bright, font, off, align, vertical_align )`
> **CLIENT**

> Draws a number that can be highlighted with a background

> **@param** {number} x position

> **@param** {number} y position

> **@param** {number} number to display

> **@param** {Color|nil} colour

> **@param** {string|nil} zeroes

> **@param** {number|nil} how opaque is the highlighting

> **@param** {string|nil} font to use

> **@param** {boolean|nil} whether the foreground shouldn't be drawn

> **@param** {TEXT_ALIGN_|nil} horizontal alignment

> **@param** {TEXT_ALIGN_|nil} vertical alignment

Example:
```lua
-- draws a red number with the health at the middle left of the screen
-- it will blink when the player is hurt, as it uses the 'health' highlight, added by default
-- this is an example using ALL parameters, which is not always needed
HOLOHUD:DrawNumber( ScrW() * .25, ScrH() * .5, LocalPlayer():Health(), Color( 255, 100, 100 ), '0000', HOLOHUD:GetHighlight('health'), 'holohud_main', false, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
```

### Draw text

`HOLOHUD:DrawText(x, y, text, font, colour, bright, align, vertical_align, off, alpha)`
> **CLIENT**

> Draws a text

> **@param** {number} x position

> **@param** {number} y position

> **@param** {string} text to draw

> **@param** {string|nil} font to use

> **@param** {Color|nil} colour

> **@param** {number|nil} how opaque is the highlighting

> **@param** {TEXT_ALIGN_|nil} horizontal alignment

> **@param** {TEXT_ALIGN_|nil} vertical alignment

> **@param** {boolean|nil} should effects like chromatic aberration and highlighting NOT draw

> **@param** {number|nil} opacity

Example:
```lua
-- draws a green text with the player's name on the top center of the screen
-- it will blink when the player is hurt, as it uses the 'health' highlight, added by default
-- this is an example using ALL parameters, which is not always needed
HOLOHUD:DrawText( ScrW() * .5, ScrH() * .25, LocalPlayer():Name(), 'holohud_small', Color( 100, 255, 100 ), HOLOHUD:GetHighlight('health'), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, false, 150 )
```

### Add an element

`HOLOHUD.ELEMENTS:AddElement( id, title, subtitle, hide_elements, default_config, draw_function, enabled )`
> **CLIENT**

> Adds an element to the HUD, both to the customization menu and the drawing loop

> **@param** {string} unique ID

> **@param** {string} name of the element

> **@param** {string} subtitle or description

> **@param** {table|nil} which HL2 HUD elements should be hidden when this one is enabled

> **@param** {table} configuration parameters and their default values

Structure: `name`, `desc` (optional), `value`, `options` (numeric value only), `minValue` (numeric value only), `maxValue` (numeric value only)

> **@param** {function|nil} drawing function

Accepts one parameter which is a function used to access configuration.

> **@param** {boolean|nil} whether it should be enabled by default

Example:

```lua
--[[
  Add a new element that says 'Out of ammo' when out of ammo
  This example uses functions previously declared on the other examples
]]
HOLOHUD.ELEMENTS:AddElement('out_of_ammo',
  "Out of ammo",
  "Displays a label when you're out of ammunition",
  nil, -- don't override any CHud element
  {
    y = { name = 'Vertical position', value = 0.8, minValue = 0, maxValue = 1 }
  },
  function( config )

    TriggerOutOfAmmoPanel()
    AnimateHighlight()
    DrawPanel( config('y') )

  end
)
```

### 'Out of ammo' element full example
```lua
if CLIENT then

  local PANEL = 'out_of_ammo'
  local WIDTH, HEIGHT = 220, 50
  local LOCALE = 'OUT OF AMMO'
  local FONT, COLOUR = 'holohud_med_sm', Color( 255, 0, 0 )
  local TICK_RATE = 1

  local tick = 0

  HOLOHUD:AddFlashPanel( PANEL )
  HOLOHUD:AddHighlight( PANEL )

  --[[
    Make the highlight blink every second
  ]]
  local function AnimateHighlight()

    if tick < CurTime() then

      HOLOHUD:TriggerHighlight( PANEL )
      tick = CurTime() + TICK_RATE

    end

  end

  --[[
    Trigger the panel 'out_of_ammo' when you're out of ammo
  ]]
  local function TriggerOutOfAmmoPanel()

    local weapon = LocalPlayer():GetActiveWeapon()

    if not IsValid( weapon ) or ( weapon:GetPrimaryAmmoType() <= 0 and weapon:GetSecondaryAmmoType() <= 0 ) then return end

    local clip, reserve, alt = weapon:Clip1(), LocalPlayer():GetAmmoCount( weapon:GetPrimaryAmmoType() ), LocalPlayer():GetAmmoCount( weapon:GetSecondaryAmmoType() )

    HOLOHUD:SetPanelActive( PANEL, clip <= 0 and reserve <= 0 and alt <= 0 )

  end

  --[[
    Draw contents
  ]]
  local function DrawPanel( y )

    HOLOHUD:DrawFragmentAlignSimple( ( ScrW() * .5 ) - ( WIDTH * .5 ), ScrH() * y, WIDTH, HEIGHT, function( x, y, w, h )

      HOLOHUD:DrawText( x + ( w * .5), y + ( h * .5 ), LOCALE, FONT, COLOUR, HOLOHUD:GetHighlight(PANEL), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    end, PANEL, TEXT_ALIGN_TOP )

  end


  --[[
    Add a new element that says 'Out of ammo' when out of ammo
    This example uses functions previously declared on the other examples
  ]]
  HOLOHUD.ELEMENTS:AddElement('out_of_ammo',
    "Out of ammo",
    "Displays a label when you're out of ammunition",
    nil, -- don't override any CHud element
    {
      y = { name = 'Vertical position', value = 0.8, minValue = 0, maxValue = 1 }
    },
    function( config )

      TriggerOutOfAmmoPanel()
      AnimateHighlight()
      DrawPanel( config('y') )

    end
  )

end
```
