vim.g.mapleader = " "

local keymap = vim.keymap


-- ---------- 视觉模式 ---------- ---

-- ---------- 正常模式 ---------- ---
-- 窗口
keymap.set("n", "<leader>ll", "<C-w>v") -- 水平新增窗口 

-- 取消高亮
keymap.set("n", "<leader>nn", ":nohl<CR>")

-- 切换buffer
keymap.set("n", "<C-L>", ":bnext<CR>")
keymap.set("n", "<C-H>", ":bprevious<CR>")

-- ---------- 插件 ---------- ---
-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
-- toggleterm
-- 打开
keymap.set("n", "<leader>tt", ":ToggleTerm<CR>")
-- 关闭
keymap.set("t", "<leader>tt", "<C-\\><C-n>:ToggleTerm<CR>")
