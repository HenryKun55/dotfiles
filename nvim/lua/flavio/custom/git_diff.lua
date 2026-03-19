local M = {}

M.setup = function() end

-- Verifica se uma branch/ref existe
local function ref_exists(ref)
    local result = vim.fn.system("git rev-parse --verify " .. ref .. " 2>/dev/null")
    return vim.v.shell_error == 0
end

-- Obtém a branch padrão para comparação
local function get_default_branch()
    if ref_exists("origin/development") then
        return "origin/development"
    elseif ref_exists("development") then
        return "development"
    else
        vim.notify("Branch development não encontrada", vim.log.levels.WARN)
        return nil
    end
end

-- Função principal
M.git_diff = function(target_branch)
    -- Guarda o arquivo atual (caminho relativo ao repo)
    local current_file = vim.fn.expand('%:.')

    -- Se não informar branch, usa a padrão
    if target_branch == nil or target_branch == "" then
        target_branch = get_default_branch()
        if not target_branch then
            return
        end
    end

    -- Verifica se a branch alvo existe
    if not ref_exists(target_branch) then
        vim.notify("Branch '" .. target_branch .. "' não encontrada", vim.log.levels.ERROR)
        return
    end

    -- Executa git diff --name-only
    local cmd = "git diff --name-only " .. target_branch .. "...HEAD"
    local output = vim.fn.systemlist(cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("Erro ao executar git diff", vim.log.levels.ERROR)
        return
    end

    -- Cria buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_name(buf, "GitDiff: " .. target_branch)

    -- Header
    local lines = {
        "# Arquivos alterados: " .. vim.fn.system("git branch --show-current"):gsub("\n", "") .. " → " .. target_branch,
        "",
    }

    -- Adiciona arquivos
    if #output == 0 then
        table.insert(lines, "Nenhum arquivo alterado")
    else
        for _, file in ipairs(output) do
            table.insert(lines, file)
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Abre em tela cheia
    vim.cmd('enew')
    vim.api.nvim_set_current_buf(buf)

    -- Posiciona o cursor no arquivo atual (se estiver na lista)
    if current_file ~= "" then
        for i, file in ipairs(output) do
            if file == current_file then
                vim.api.nvim_win_set_cursor(0, { i + 2, 0 }) -- +2 por causa do header
                break
            end
        end
    end

    -- Keymaps locais
    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set('n', 'q', '<cmd>bdelete<CR>', opts)
    vim.keymap.set('n', '<Esc>', '<cmd>bdelete<CR>', opts)
    vim.keymap.set('n', '<CR>', function()
        local line = vim.api.nvim_get_current_line()
        if line ~= "" and not line:match("^#") and not line:match("^Nenhum") then
            vim.cmd('bdelete')
            vim.cmd('edit ' .. line)
        end
    end, opts)
end

-- Registra comando
vim.api.nvim_create_user_command('GitDiff', function(opts)
    M.git_diff(opts.args)
end, { nargs = '?' })

-- Keymap
vim.keymap.set('n', '<leader>gd', ':GitDiff<CR>', { noremap = true, silent = true })

return M

