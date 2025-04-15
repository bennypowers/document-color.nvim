local helpers = require("document-color.helpers")

local M = {}
local NAMESPACE = vim.api.nvim_create_namespace("lsp_documentColor")
local METHOD =  "textDocument/documentColor"

local MODE_NAMES = {
  background = "mb",
  foreground = "mf",
  single = "mb",
  inlay = "il"
}

local OPTIONS = {
  mode = "background",
}

local STATE = {
  HIGHLIGHTS = {},
}

local function create_highlight(color_info)
  local color = helpers.lsp_color_to_hex(color_info.color)
  -- This will create something like "mb_d023d9"
  local cache_key = table.concat({ MODE_NAMES[OPTIONS.mode], color }, "_")

  if STATE.HIGHLIGHTS[cache_key] then
    return STATE.HIGHLIGHTS[cache_key]
  end

  -- This will create something like "lsp_documentColor_mb_d023d9", safe to start adding to neovim
  local highlight_name = table.concat({ "lsp_documentColor", MODE_NAMES[OPTIONS.mode], color }, "_")

  if OPTIONS.mode == "foreground" or OPTIONS.mode == "inlay" then
    vim.api.nvim_set_hl(0, highlight_name, {
      fg = "#"..color,
    })
  else
    vim.api.nvim_set_hl(0, highlight_name, {
      fg = helpers.color_is_bright(color) and "Black" or "White",
      bg = '#'..color
    })
  end

  STATE.HIGHLIGHTS[cache_key] = highlight_name

  return highlight_name
end

local function set_extmark(color_info, bufnr)
  local range = color_info.range
  local row = range.start.line
  local col = range.start.character
  local hl = create_highlight(color_info)
  ---@type vim.api.keyset.set_extmark
  local opts
  if OPTIONS.mode == "inlay" then
    opts = {
      virt_text = { { '■' , hl } },
      virt_text_pos = 'inline',
    }
  elseif OPTIONS.mode == "background" or OPTIONS.mode == "foreground" then
    opts = {
      hl_group = hl,
      end_col = color_info.range['end'].character,
      end_row = color_info.range['end'].line,
    }
  elseif OPTIONS.mode == "single" then
    opts = {
      hl_group = hl,
      end_col = col + 1,
      end_row = row,
    }
  end

  local ok = pcall(vim.api.nvim_buf_set_extmark, bufnr, NAMESPACE, row, col, opts)
  if not ok then
    vim.api.nvim_buf_clear_namespace(bufnr, NAMESPACE, 0, -1)
  end
end

local function handle_document_color(err, colors, context)
  -- There is no error, the buffer is valid, and we actually got something back.
  if err == nil and colors ~= nil and vim.api.nvim_buf_is_valid(context.bufnr) then

    -- Clear all our in the buffer highlights
    vim.api.nvim_buf_clear_namespace(context.bufnr, NAMESPACE, 0, -1)

    -- `_` is a TextDocumentIdentifier, not important
    for _, color_info in pairs(colors) do
      set_extmark(color_info, context.bufnr)
    end
  end
end

---@param client vim.lsp.Client
---@param bufnr number
local function request(client, bufnr)
  vim.notify('requesting')
  client:request(METHOD, {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
  }, nil, bufnr)
end

---@param client vim.lsp.Client
---@param bufnr number
function M.on_attach(client, bufnr)
  if client.server_capabilities.colorProvider then
    vim.api.nvim_buf_attach(bufnr, false, {
      on_lines = function() request(client, bufnr) end,
    })

    -- Wait for tailwind to load. 150 to be safe
    -- After further investiation, servers seem to be sluggish for *every* new buffer!!
    vim.wait(150)

    -- Try again after some time
    request(client, bufnr)
  end
end

function M.setup(options)
  OPTIONS = helpers.merge(OPTIONS, options)
  vim.lsp.handlers[METHOD] = handle_document_color
end

return M
