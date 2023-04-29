local M = {}

local GROUP = "NERDTreeDiagnosticSigns"

local signDefineList = {
  { name="NERDTreeLspDiagnosticsError", text="E", texthl="DiagnosticError"},
  { name="NERDTreeLspDiagnosticsWarning", text="W", texthl="DiagnosticWarn"},
  { name="NERDTreeLspDiagnosticsInfo", text="I", texthl="DiagnosticInfo"},
  { name="NERDTreeLspDiagnosticsHint", text="H", texthl="DiagnosticHint"},
}

function M._getbufnr()
	local tabwins = vim.api.nvim_tabpage_list_wins(0)
	local ok, bufname = pcall(vim.api.nvim_tabpage_get_var, 0, "NERDTreeBufName")
	if not ok then
		return false
	end
	for i, win in pairs(tabwins) do
		local bufnr = vim.api.nvim_win_get_buf(win)
		local fullname = vim.api.nvim_buf_get_name(bufnr)
		if fullname:find(bufname.."$") then
			return bufnr
		end
	end
	return false
end

local function add_sign(linenr, severity)
  local bufnr = M._getbufnr()
	if not bufnr then
		return
	end
  local sign_name = signDefineList[severity].name
  vim.fn.sign_place(0, GROUP, sign_name, bufnr, { lnum = linenr, priority = 2 })
end

local function from_nvim_lsp()
  local bufname2severity = {}

  for _, diagnostic in ipairs(vim.diagnostic.get()) do
    local buf = diagnostic.bufnr
    if vim.api.nvim_buf_is_valid(buf) then
      local bufname = vim.api.nvim_buf_get_name(buf)
      local lowest_severity = bufname2severity[bufname]
      if not lowest_severity or diagnostic.severity < lowest_severity then
        bufname2severity[bufname] = diagnostic.severity
      end
    end
  end

  return bufname2severity
end

function M._getpath2line()

	local bufnr = M._getbufnr()
	if not bufnr then
		return {}
	end
	local ok, root = pcall(vim.api.nvim_buf_get_var, bufnr, "NERDTreeRoot")
	if not ok then
		return {}
	end
	local path2line = {}
	--[[
		let.Node = Struct {
			path=Struct {
				pathSegments=List(String),
			},
			isOpen=Union(0,1,Nil),
			parent=let.Node,
			children=Option(List(let.Node)),
		}
	]]
	local function put(node)
		local path = "/"..table.concat(node.path.pathSegments, "/")
		path2line[path] = node.lineNum
		if node.children and node.isOpen == 1 then
			for _, subnode in ipairs(node.children or {}) do
				put(subnode)
			end
		end
	end
	put(root)
	return path2line
end

function M.clear()
  vim.fn.sign_unplace(GROUP)
end

function M.update()
	local bufnr = M._getbufnr()
	if not bufnr then
		return
	end
	M.clear()

	local bufname2severity = from_nvim_lsp()
	local path2line = M._getpath2line()
	for bufname, severity in pairs(bufname2severity) do
		if 0 < severity and severity < 5 then
			local gnum = 0
			while true do
				local line = path2line[bufname]
				if line then
					add_sign(line, severity)
				end
				bufname, gnum = bufname:gsub("[/][^/]*$", "")
				if gnum == 0 then
					break
				end
			end
		end
	end
end

function M.getroot()
	local bufnr = M._getbufnr()
	return vim.api.nvim_buf_get_var(bufnr, "NERDTreeRoot")
end

function M.setup()
  local augroup_id = vim.api.nvim_create_augroup("NERDTree", { clear = true })
	vim.api.nvim_create_autocmd("DiagnosticChanged", vim.tbl_extend("force", {group = augroup_id}, {
      callback = function()
				M.update()
      end,
	}))
	for severity=1,4 do
		local name = signDefineList[severity].name
		local text = signDefineList[severity].text
		local texthl = signDefineList[severity].texthl
		vim.fn.sign_define(name, { text = text, texthl = texthl })
	end
end

return M
