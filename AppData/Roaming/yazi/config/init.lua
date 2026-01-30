require("custom-shell"):setup({
    save_history = false,
})
---- augment-command ----
require("augment-command"):setup({
    open_file_after_creation = true,
    smooth_scrolling = true,
})
---- yatline ----
require("yatline"):setup({
    section_separator = { open = "", close = "" },
    part_separator = { open = "", close = "" },
    inverse_separator = { open = "", close = "" },

    padding = { inner = 1, outer = 1 },

    style_a = {
        bg = "white",
        fg = "black",
        bg_mode = {
            normal = "white",
            select = "brightyellow",
            un_set = "brightred",
        },
    },
    style_b = { bg = "brightblack", fg = "brightwhite" },
    style_c = { bg = "black", fg = "brightwhite" },

    permissions_t_fg = "green",
    permissions_r_fg = "yellow",
    permissions_w_fg = "red",
    permissions_x_fg = "cyan",
    permissions_s_fg = "white",

    tab_width = 20,

    selected = { icon = "󰻭", fg = "yellow" },
    copied = { icon = "", fg = "green" },
    cut = { icon = "", fg = "red" },

    files = { icon = "", fg = "blue" },
    filtereds = { icon = "", fg = "magenta" },

    total = { icon = "󰮍", fg = "yellow" },
    success = { icon = "", fg = "green" },
    failed = { icon = "", fg = "red" },

    show_background = true,

    display_header_line = true,
    display_status_line = true,

    component_positions = { "header", "tab", "status" },

    header_line = {
        left = {
            section_a = {
                { type = "line", name = "tabs" },
            },
            section_b = {
            },
            section_c = {},
        },
        right = {
            section_a = {
                { type = "string", name = "filter_query" }
            },
            section_b = {},
            section_c = {},
        },
    },

    status_line = {
        left = {
            section_a = {
                { type = "string", name = "tab_mode" },
            },
            section_b = {
                { type = "string",   name = "hovered_size" },
                { type = "coloreds", name = "created_time" }
            },
            section_c = {
                { type = "string",   name = "hovered_path" },
                { type = "coloreds", name = "symlink" },
                { type = "coloreds", name = "count",       params = { true, true } },
            },
        },
        right = {
            section_a = {
                { type = "coloreds", custom = false,          name = "task_states" },
                { type = "string",   name = "cursor_position" },
            },
            section_b = {
                { type = "string", name = "cursor_percentage" },
            },
            section_c = {
                { type = "string",   name = "hovered_mime" },
                { type = "coloreds", name = "permissions" },
            },
        },
    },
})
require("yatline-created-time"):setup()
function Yatline.coloreds.get:symlink()
    local symlink = {}
    local h = cx.active.current.hovered

    if not h then
        -- ya.dbg("no hovered")
        return nil
    end
    if not h.cha.is_link then
        -- ya.dbg("not a symlink")
        return nil
    end

    local link_target = h.link_to:strip_prefix(tostring(cx.active.current.cwd))
    local link_target_str = ("symlink:.\\" .. tostring(link_target))
    table.insert(symlink, { link_target_str, th.mgr.cwd:fg() })
    return symlink
end

---- bunny ----
require("bunny"):setup({
    hops = {
        { key = "/",  path = "/", },
        { key = "~",  path = "~",                                                               desc = "Home" },
        { key = "c",  path = "~/.config",                                                       desc = "Config files" },
        { key = "t",  path = "~/tools/tools",                                                   desc = "Tools" },
        { key = "d",  path = "~/Downloads",                                                     desc = "Downloads" },
        { key = "l",  path = "~/.local",                                                        desc = "Local" },
        { key = "s", path = "~/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup", desc = "Startup" }
        -- key and path attributes are required, desc is optional
    },
    desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
    ephemeral = true,       -- Enable ephemeral hops, default is true
    tabs = true,            -- Enable tab hops, default is true
    notify = false,         -- Notify after hopping, default is false
    fuzzy_cmd = "fzf",      -- Fuzzy searching command, default is "fzf"
})
--- fg ---
require("fg"):setup({
})
--- mime-ext ---
require("mime-ext.local"):setup {
    -- Expand the existing filename database (lowercase), for example:
    with_files = {
    },

    -- Expand the existing extension database (lowercase), for example:
    with_exts = {
    },

    -- If the MIME type is not in both filename and extension databases,
    -- then fallback to Yazi's preset `mime.local` plugin, which uses `file(1)`
    fallback_file1 = true,
}
