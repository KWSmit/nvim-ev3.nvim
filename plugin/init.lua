-- Keymapping for plugin nvim-ev3

-- Create new EV3 Project
vim.api.nvim_set_keymap("n",
                        "<leader>ec",
                        ":lua require('nvim-ev3').create_ev3_project()<CR>",
                        {}
)
-- Open an existing EV3 Project
vim.api.nvim_set_keymap("n",
                        "<leader>eo",
                        ":lua require('nvim-ev3').open_ev3_project()<CR>",
                        {}
)
-- Upload project to EV3 device
vim.api.nvim_set_keymap("n",
                        "<leader>eu",
                        ":lua require('nvim-ev3').upload_ev3_project()<CR>",
                        { silent = true }
)
-- Run project on EV3 device
vim.api.nvim_set_keymap("n",
                        "<leader>er",
                        ":lua require('nvim-ev3').run_ev3_project()<CR>",
                        { silent = true }
)

