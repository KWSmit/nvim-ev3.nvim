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
-- Show battery voltage
vim.api.nvim_set_keymap("n",
                        "<leader>eb",
                        ":lua require('nvim-ev3').check_battery()<CR>",
                        { silent = true }
)

-- Open terminal on EV3
vim.api.nvim_set_keymap("n",
                        "<leader>et",
                        ":lua require('nvim-ev3').open_terminal_ev3()<CR>",
                        { silent = true }
)
