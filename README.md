# pro-cli

pro-cli is your local little environment manager. You can:

- switch between projects that you worked on with a single command
- use (force) the same project structure in **every** project
- initialize and start whole environments (web server, database, caching server, mail server, RabbitMQ, etc.) in seconds
- install projects with a single command by using [individual commands](https://github.com/chriha/pro-cli/wiki/Using-the-install-command-and-scripts)
- every developer is using the exact same environment and tools
- no need to install and manage multiple versions for each PHP, NPM, MySQL, etc. on your host
- reduce amount of necessary commands for each developer
- simple access to log files; tail and concat all or just specific services
- use the `project` command everywhere in your project, not only in your root directory

See the [wiki](https://github.com/chriha/pro-cli/wiki) for further help.


## TOC
- [Install](#install)
  - [Dependencies](#dependencies)
  - [Install pro-cli](#install-pro-cli)
  - [Completions](#completions)
- [Update](#update)
- [Uninstall](#uninstall)
- [Configuration](#configuration)
- [Usage](#usage)


## Install
### Dependencies
- The amazing [jq](https://stedolan.github.io/jq/) -> [download](https://stedolan.github.io/jq/download/)
- [Docker](https://docs.docker.com/engine/installation/)


### Install pro-cli
After installing *jq* via `brew install jq`, please install pro-cli via:
```bash
git clone -q https://github.com/chriha/pro-cli.git $HOME/.pro-cli && $HOME/.pro-cli/setup.sh
```

Reload your shell and use the `project` command with all its beauty.


### Completions
To use the *zsh completions*, add the following to your `~/.zshrc`:
```bash
fpath=($HOME/.pro-cli/completions $fpath)

autoload -U compinit
compinit
```
Run `project self-update` to update the completions and reload your shell via `. ~/.zshrc`.


## Update
To manually update **pro-cli** just use the `project self-update` command.


## Uninstall
```bash
rm -rf $HOME/.pro-cli && rm $HOME/.bin/project
```


## Configuration
Every pro-cli project has its own [`pro-cli.json`](pro-cli.json) file which you can change to your needs. Add whole installation processes or single commands.


## Usage
The most used commands while working with *pro-cli*. Remember, every command that is executed inside of a container / service, will be executed in the application root (src/.), no matter from where you run the `project` command on your host.

### Initalize a new project
```shell
project init FOLDER --type=laravel|php|nodejs
```

### Start and stop environment and its services
```shell
project up
project down
project restart
```

### Run any service specific command
```shell
# for the web service
project artisan|tinker|composer|...
# for the npm service
project npm install|run|...
```

### Show service status and resource statistics
```shell
project status
project top
```

### Open / tail logs
```shell
project logs SERVICE
```

### Using bash inside a container / service
```shell
project compose exec SERVICE bash
```
