---@mod rtp_nvim
---
---@brief [[
---
---Source |plugin| and |ftdetect| directories on the Neovim runtimepath
---
---If you install plugins to a different location than the |packpath|,
---you can use this library to source their
---|plugin|, |ftdetect| and |after-directory| scripts.
---@brief ]]

-- Copyright (C) 2024 Neorocks Org.
--
-- License:    GPLv3
-- Created:    24 Apr 2024
-- Updated:    24 Apr 2024
-- Homepage:   https://github.com/nvim-neorocks/rtp.nvim

local rtp_nvim = {}

---`ftdetect` scripts should only be sourced once.
---@type table<string, boolean|nil>
local _sourced_ftdetect = {}

---@enum RtpSourceDir Directories to be sourced on packadd
local RtpSourceDir = {
    plugin = "plugin",
    ftdetect = "ftdetect",
    after_plugin = vim.fs.joinpath("after", "plugin"),
}

---Recursively iterate over a directory's children
---@param dir string
---@return fun(_:any, path:string):(path: string, name: string, type: string)
---@async
local function iter_children(dir)
    return coroutine.wrap(function()
        local handle = vim.uv.fs_scandir(dir)
        while handle do
            local name, ty = vim.uv.fs_scandir_next(handle)
            local path = vim.fs.joinpath(dir, name)
            ty = ty or vim.uv.fs_stat(path).type
            if not name then
                return
            elseif ty == "directory" then
                for child_path, child, child_type in iter_children(path) do
                    coroutine.yield(child_path, child, child_type)
                end
            end
            coroutine.yield(path, name, ty)
        end
    end)
end

---@param rtp_source_dir RtpSourceDir
---@param dir string
local function source(rtp_source_dir, dir)
    local rtp_dir = vim.fs.joinpath(dir, rtp_source_dir)
    for script, name, ty in iter_children(rtp_dir) do
        local ext = name:sub(-3)
        if vim.tbl_contains({ "file", "link" }, ty) and vim.tbl_contains({ "lua", "vim" }, ext) then
            local ok, err = pcall(vim.cmd.source, script)
            if not ok and type(err) == "string" then
                vim.notify(err, vim.log.levels.ERROR)
                break
            end
        end
    end
end

---@param dir string
local function source_plugin(dir)
    source(RtpSourceDir.plugin, dir)
end

---@param dir string
local function source_ftdetect(dir)
    if not _sourced_ftdetect[dir] then
        source(RtpSourceDir.ftdetect, dir)
        _sourced_ftdetect[dir] = true
    end
end

---@param dir string
local function source_after_plugin(dir)
    source(RtpSourceDir.after_plugin, dir)
end

---Source the `plugin` and `ftdetect` directories.
---@param dir string The runtime directory to source
function rtp_nvim.source_rtp_dir(dir)
    source_plugin(dir)
    source_ftdetect(dir)
end

---Source the `after` scripts
---@param dir string The runtime directory to source
function rtp_nvim.source_after_plugin_dir(dir)
    source_after_plugin(dir)
end

return rtp_nvim
