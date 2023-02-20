# nvim-ev3.nvim

Neovim lua-plugin for programming LEGO Mindstorms EV3 in nvim. With this plugin
you can write your code locally on your PC and upload it to your EV3. You can
also start programs and browse files on the EV3 from within nvim.
For coding you can use python or micro-python.

## Requirements

- Nvim 7.0 or newer.
- Your PC and EV3-brick must be connected to the same wifi-network.
- For python-projects your EV3 needs to be running on the
[ev3dev](https://www.ev3dev.org) operating system.
- For micro-python you have to use
[Pybricks](https://pybricks.com/install/mindstorms-ev3/installation/) on
your EV3.
- To use the terminal function you have to install the
[toggleterm](https://github.com/akinsho/toggleterm.nvim) nvim plugin.

> **This plugin is tested on Linux (Pop!_OS 22.04) and Windows 10 only.**

## Installation

Install with your plugin manager just like any other lua plugin, for instance
with `Packer`:

```
use 'kwsmit/nvim-ev3.nvim'
```

### Setup

There is one setting you need to add to the setup of the plugin, namely the
directory where all your EV3-projects are stored. For instance:

```
nvim_ev3.setup({ projects_dir = '/home/kees/ev3-projects/' })
```
Be sure the setting ends with a forward-slash (`/`).

## Usage

Working on your projects is done locally on
your PC. The plugin helps you to create a new project or open an existing one.
All projects are supposed to be located in one and the same projects-directory.
Each project is located in its own directory. The name of this directory is
the name of the project.

De plugin uses for each project a hidden project-file `.project.ini`,
which stores project-related information like:

- `USER` - The username on the EV3. Default value is `robot`.
- `HOST` - Hostname or ip-address of your EV3.
- `DIR` - The project directory on the EV3.
- `SCRIPT` - The name of the script with the entrypoint of your project 
  (always `main.py`).
- `INTERPRETER` - The interpreter to be used (`python` or `micro-python`).

This project-file is stored in the project directory.
An example of this project-file:

```
USER=robot
HOST=192.168.2.14
DIR=home/robot/test1
SCRIPT=main.py
INTERPRETER=micro-python
```

### Commands

All commands can be used by typing the leader key of nvim followed by a
two-character command, for instance `<leader>ec` for creating a new project.


| Command         | Action                                               |
|:----------------|:-----------------------------------------------------|
| `<leader>ec  `  | Create a new project in your projects-directory      |
| `<leader>eo  `  | Open an existing project in your projects-directory  |
| `<leader>eu  `  | Upload the project to the EV3                        |
| `<leader>er  `  | Run the project on your EV3                          |
| `<leader>et  `  | Open terminal on EV3                                 |
| `<leader>eb  `  | Check EV3's battery voltage                          |

#### Create new project

This command creates a new project in your projects-directory. All project files
are stored in a folder with the projects name. This command asks the user for
the following input:

- project name
- user name on EV3 (default: `robot`)
- host: the hostname or ip-address of your EV3
- interpreter: python or micro-python

When the user enters a name that already exists in the projects directory, then
the user is asked to overwrite existing project files or not.

The startpoint of your program is `main.py`. This file is automatically created
for your new project.

After creating a new project, all following commands are performed on this
project.

#### Open project

This command shows all projects in the projects-directory and lets the user
choose which project to open.
When a project is opened this way, all successive commands are performed on
this project. Use the open project command to switch between projects.

#### Upload project

This command uploads the active project to the EV3 by using `scp`. It is
recommended to use SSH-keys for ssh-authentication.

#### Run project

This command starts the project remotely on the EV3. The command uses the
`main.py` file in your project directory.

#### Open terminal

This command opens a terminal on the EV3 and shows it in nvim in a
floating window. This gives you the possibility to browse files on the EV3 or
start programs on the EV3 manually.
Close the browser by typing `exit` on the command-line or by pressing `<Ctrl>d`
on your keyboard.

For this functionality you need to install the
[toggleterm](https://github.com/akinsho/toggleterm.nvim) plugin.

#### Check battery

This command shows the current voltage of EV3's battery.
