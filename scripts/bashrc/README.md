# Bashrc scripts
This folder contains various shell scripting modules that can be sourced from your .bashrc file
to provide enhanced shell functionality.

Each script-module should begin (after the shebang) with a comment describing the general
functionality it offers. Optionally, a script-module may offer a specific README (i.e <script-module-name>-README.md)
describing the functions it exposes.

## script-module design guidelines
- Has meaningful name
- Has shebang
- Comment describing the script-module functionality at the top of the file
- Init() function : Any global/one-time operations should be performed here
- Function per desired functionality exposed to the user
- Optionally a usage function per desired functionality may be added and invoked if the first
  argument is `-h`
- No operations aside of init call should be performed outside of a function's scope

## Usage
- Copy relevant scripts to your home directory
- Edit `~/.bashrc` and source relevant scripts
- Happy hacking!

