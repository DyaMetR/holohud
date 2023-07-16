--[[------------------------------------------------------------------
  ENTITY INFORMATION
  Information about the entity you're looking at
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local PANEL_NAME = "entity_info";
  local PROP_PHYSICS = "prop_physics";
  local BLACKLIST = {
    ["worldspawn"] = true,
    ["prop_detail"] = true,
    ["prop_static"] = true,
    ["prop_dynamic"] = true,
    ["func_wall"] = true,
    ["class C_BaseEntity"] = true,
    ["func_lod"] = true,
    ["func_ladder"] = true,
    ["func_brush"] = true
  };
  local BAR_W, BAR_H, BAR_V = 64, 16, 49;
  local HEALTH_COLOUR = Color(255, 100, 100, 200);
  local PHYSGUN = "weapon_physgun";

  -- Variables
  local lerp = 0;
  local time = 0;

  -- Panel
  HOLOHUD:AddFlashPanel(PANEL_NAME);

  --[[
    Gets the model name, removes underscores, extensions and adds upper case letters
    @param {string} str
    @return {string} sanitized string
  ]]
  local function SanitizeString(str)
    -- Remove path
    local pos = -1;
    while (string.find(str, "/") ~= nil) do
      pos = string.find(str, "/") + 1;
      str = string.sub(str, pos);
    end

    -- Remove extension
    str = string.StripExtension(str);

    -- Remove underscores
    str = string.Replace(str, "_", " ");

    -- Upper case
    str = string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2);

    return str;
  end

  --[[
    Draws the model inspector
    @param {number} health
    @param {number} maximum health
    @param {string} model
    @param {number} mass
    @param {Color} text colour
    @param {Color} health bar colour
    @void
  ]]
  local function DrawProp(x, y, w, h, health, maxHealth, model, colour, hColour)
    local offset = 0;

    -- Draw health bar
    if (health > 0 and health <= maxHealth) then
      lerp = Lerp(FrameTime() * 4, lerp, health/maxHealth);
      HOLOHUD:DrawHorizontalBar(x + 3, y + 3, hColour, lerp);
      offset = BAR_H - 1;
    end

    -- Draw model name
    HOLOHUD:DrawText(x + 6, y + offset + 1, model, "holohud_entity", colour);
  end

  --[[
    Draws a weapon's details
    @param {number} x
    @param {number} y
    @param {string} name
    @param {string} author
    @param {string} category
    @param {Color} text colour
    @void
  ]]
  local function DrawWeapon(x, y, w, h, name, author, category, colour)
    local offset = 0;

    if (category ~= nil) then
      HOLOHUD:DrawText(x + 5, y, category, "holohud_pickup", Color(255, 255, 255, 24));
      offset = 15;
    end
    HOLOHUD:DrawText(x + 5, y + offset, name, "holohud_entity", colour);

    if (author ~= nil) then
      HOLOHUD:DrawText(x + 5, y + 19 + offset, author, "holohud_pickup", colour);
    end
  end

  --[[
    Draws an entity's details
    @param {number} x
    @param {number} y
    @param {string} name
    @param {number} health
    @param {number} maximum health
    @param {string} author
    @param {Color} text colour
    @param {Color} health bar colour
    @void
  ]]
  local function DrawEntity(x, y, w, h, name, health, maxHealth, author, colour, hColour)
    if (name == nil) then return; end
    local offset = 0;

    -- Draw health bar
    if (health > 0 and health <= maxHealth) then
      lerp = Lerp(FrameTime() * 4, lerp, health/maxHealth);
      HOLOHUD:DrawHorizontalBar(x + 3, y + 3, hColour, lerp);
      offset = BAR_H - 2;
    end

    HOLOHUD:DrawText(x + 6, y + 2 + offset, name, "holohud_entity", colour);

    if (author ~= nil) then
      HOLOHUD:DrawText(x + 6, y + 21 + offset, author, "holohud_pickup", colour);
    end
  end

  --[[
    Draws the panel
    @param {function} config
    @void
  ]]
  local w, h = 0, 0;
  local function DrawPanel(config)
    local trace = LocalPlayer():GetEyeTrace();
    local ent = nil;
    local x, y = ScrW() * 0.5, ScrH() * config("offset");

    local align = TEXT_ALIGN_RIGHT;
    if (config("align") == 2) then
      align = TEXT_ALIGN_CENTER;
    elseif (config("align") == 3) then
      align = TEXT_ALIGN_LEFT;
    end

    -- Get entity
    if (trace ~= nil) then
      ent = trace.Entity;
    end

    local physgun = IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == PHYSGUN;
    local validEntity = not LocalPlayer():InVehicle() and
                        ((config("physgun") and physgun) or not config("physgun")) and
                        IsValid(ent) and ent ~= nil and
                        not ent:IsPlayer() and not ent:IsNPC() and not (ent:IsScripted() and ent.Type == "nextbot") and
                        BLACKLIST[ent:GetClass()] == nil;

    -- Trigger panel if a valid ent is found
    HOLOHUD:SetPanelActive(PANEL_NAME, validEntity and (not config("sent_only") or ent:IsScripted()));

    -- Prop delay
    if (config("delay") and (not validEntity or ent:GetClass() ~= PROP_PHYSICS)) then
      time = CurTime() + config("time");
    end

    -- What entity type is it?
    if (validEntity) then
      if (ent:GetClass() == PROP_PHYSICS) then
        local health, maxHealth = ent:Health(), ent:GetMaxHealth();

        -- Should draw
        local delay = not config("delay") or time < CurTime() or physgun;
        local unbreakable = (config("unbreakable") and physgun) or not config("unbreakable");
        HOLOHUD:SetPanelActive(PANEL_NAME, validEntity and (delay and unbreakable or (health > 0 and health <= maxHealth)) and not config("no_props"));

        -- Get size
        local model = SanitizeString(ent:GetModel());
        local modelSize = HOLOHUD:GetTextSize(model, "holohud_entity") + 15;

        w, h = math.Clamp(modelSize, BAR_W, ScrW()), draw.GetFontHeight("holohud_entity") + 4;
        if (health > 0) then
          h = h + BAR_H;
        end

        -- Alignment
        if (align == TEXT_ALIGN_CENTER) then
          x = x - (w * 0.5);
        elseif (align == TEXT_ALIGN_LEFT) then
          x = x - w;
        end

        HOLOHUD:DrawFragmentAlignSimple(x, y, w, h, DrawProp, PANEL_NAME, align, health or 0, ent:GetMaxHealth() or 0, model, config("colour"), config("health"));
      elseif (ent:IsWeapon()) then
        local name = ent:GetPrintName();
        local author = ent.Author;
        local category = ent.Category;
        local smallH = draw.GetFontHeight("holohud_pickup");
        local width, height = HOLOHUD:GetTextSize(name, "holohud_entity");

        -- Add name height
        h = height + 2;

        -- Category height
        if (category ~= nil) then
          h = h + smallH - 2;
        end

        -- Author's name height
        if (author ~= nil and string.len(author) > 0) then
          h = h + smallH - 2;
        end

        w = math.max(width + 12, HOLOHUD:GetTextSize(author, "holohud_pickup") + 12, HOLOHUD:GetTextSize(category, "holohud_pickup") + 12);

        -- Alignment
        if (align == TEXT_ALIGN_CENTER) then
          x = x - (w * 0.5);
        elseif (align == TEXT_ALIGN_LEFT) then
          x = x - w;
        end

        HOLOHUD:DrawFragmentAlignSimple(x, y, w, h, DrawWeapon, PANEL_NAME, align, name, author, category, config("colour"));
      else
        local name = language.GetPhrase(ent:GetClass());
        if (name == ent:GetClass()) then name = SanitizeString(name); end
        local author = ent.Author;
        local height = draw.GetFontHeight("holohud_entity") + 4;
        local health, maxHealth = ent:Health(), ent:GetMaxHealth();

        -- Health
        if (health > 0 and health <= maxHealth) then
          height = height + BAR_H;
        end

        -- Author name
        if (author ~= nil and string.len(author) > 0) then
          height = height + draw.GetFontHeight("holohud_pickup") - 2;
        end

        w, h = math.Clamp(math.max(HOLOHUD:GetTextSize(name, "holohud_entity") + 14, HOLOHUD:GetTextSize(author, "holohud_pickup") + 12), BAR_W, ScrW()), height;

        -- Alignment
        if (align == TEXT_ALIGN_CENTER) then
          x = x - (w * 0.5);
        elseif (align == TEXT_ALIGN_LEFT) then
          x = x - w;
        end

        HOLOHUD:DrawFragmentAlignSimple(x, y, w, h, DrawEntity, PANEL_NAME, align, name, health, maxHealth, author, config("colour"), config("health"));
      end
    else
      -- Alignment
      if (align == TEXT_ALIGN_CENTER) then
        x = x - (w * 0.5);
      elseif (align == TEXT_ALIGN_LEFT) then
        x = x - w;
      end

      HOLOHUD:DrawFragmentAlignSimple(x, y, w, h, DrawEntity, PANEL_NAME, align);
    end
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement("entity_info",
    "#holohud.settings.entity_info.name",
    "#holohud.settings.entity_info.description",
    nil,
    {
      offset = { name = "holohud.settings.entity_info.offset", value = 0.58, minValue = 0, maxValue = 1 },
      align = { name = "holohud.settings.entity_info.align", value = 1, options = {"holohud.settings.entity_info.align.right", "holohud.settings.entity_info.align.center", "holohud.settings.entity_info.align.left"} },
      no_props = { name = "holohud.settings.entity_info.no_props", value = false },
      unbreakable = { name = "holohud.settings.entity_info.unbreakable", desc = "holohud.settings.entity_info.unbreakable.description", value = true },
      delay = { name = "holohud.settings.entity_info.delay", desc = "holohud.settings.entity_info.delay.description", value = true },
      time = { name = "holohud.settings.entity_info.time", desc = "holohud.settings.entity_info.time.description", value = 1.46},
      sent_only = { name = "holohud.settings.entity_info.sent_only", desc = "holohud.settings.entity_info.sent_only.description", value = false },
      physgun = { name = "holohud.settings.entity_info.physgun", desc = "holohud.settings.entity_info.physgun.description", value = false },
      colour = { name = "holohud.settings.entity_info.color", value = Color(255, 255, 255) },
      health = { name = "holohud.settings.entity_info.health_color", value = HEALTH_COLOUR }
    },
    DrawPanel
  );

end
