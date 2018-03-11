# pro-cli
- initialize and start whole environments (web server, database, caching, mail server, RabbitMQ, etc.) in seconds
- specify the services depending on your projects needs in your own `docker-compose.local.yml`
- install even complex projects with a single command by using [individual commands](https://github.com/chriha/pro-cli/wiki/Using-the-install-command-and-scripts)
- temporarily [expose](#expose-your-local-server-securely-to-the-internet) the application securely to the internet (ngrok required)
- [start Jenkins builds](https://github.com/chriha/pro-cli/wiki/Jenkins) and print its console output
- reduce amount of necessary commands for each developer
- use the `project` command everywhere in your project, not only in your root directory
- every developer is using the exact same environment and tools
- use (force) the same project structure in **every** project
- no need to install and manage multiple versions for each PHP, NPM, MySQL, etc. on your host
- simple access to log files; tail and concat all or just specific services
- switch between projects that you worked on with a single command

See how you can [use it](#usage), take a look at the [wiki](https://github.com/chriha/pro-cli/wiki) for further help or play around with the [pro-cli-example](https://github.com/chriha/pro-cli-example) project.

[![asciicast](https://asciinema.org/a/fJZoP83vfpNkT2k05v8K8WmFA.png)](https://asciinema.org/a/fJZoP83vfpNkT2k05v8K8WmFA)

> Supported project types: PHP (Laravel), Django, NodeJS


## TOC
- [Install](#install)
  - [Dependencies](#dependencies)
  - [Install pro-cli](#install-pro-cli)
  - [Configuration](#configuration)
  - [Completions](#completions)
- [Update](#update)
- [Uninstall](#uninstall)
- [Usage](#usage)


## Install
### Dependencies
- The amazing [jq](https://stedolan.github.io/jq/) -> [download](https://stedolan.github.io/jq/download/)
- [Docker](https://docs.docker.com/engine/installation/)
- [ngrok](https://ngrok.com/) (optional) to use the [expose](#expose-your-local-server-securely-to-the-internet) command


### Install pro-cli
After you installed all [dependencies](#dependencies):
```bash
git clone -q https://github.com/chriha/pro-cli.git $HOME/.pro-cli && $HOME/.pro-cli/setup.sh
sudo ln -s $HOME/.pro-cli/project.sh /usr/local/bin/project
```
Reload your shell and use the `project` command with all its beauty.


### Configuration
Every pro-cli project has its own [`pro-cli.json`](pro-cli.json) file which you can change
to your needs. Add whole installation processes or single commands. The `docker-compose.yml`
is the default configuration for the services and should not be overwritten. Instead you
should create your own `docker-compose.local.yml`, which can extend the default.


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


## Usage
> **It's mandatory, that the project has the according directory structure and files in order for pro-cli to work properly.** See `environments` directory for structure and files.

The most used commands while working with *pro-cli*. Remember, every command that is executed inside of a container / service, will be executed in the **application root** (`src/.`), no matter from where you run the `project` command on your host.

### Initalize a new project
```shell
project init FOLDER --type=laravel|php|nodejs|django
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

### Expose your local server securely to the internet
ngrok needs to be installed in one of your `bin` folders of your host.
```shell
project expose [--auth='user:password']
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
project exec SERVICE bash
```

### Start Jenkins build
```shell
project build [-o|--output] stage [--branch=develop]
```
