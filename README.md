**This project is not maintained anymore. The new version available here: https://github.com/chriha/project-cli**

# pro-cli
- initialize, install and start whole environments (web server, database, caching, mail server, RabbitMQ, etc.) in seconds
- specify the services depending on your projects needs in your `docker-compose.yml`
- install even complex projects with a single command by using [individual commands](https://github.com/chriha/pro-cli/wiki/Using-the-scripts---commands-in-pro-cli.json)
- temporarily [expose](#expose-your-local-server-securely-to-the-internet) the application securely to the internet (ngrok required)
- [start Jenkins builds](https://github.com/chriha/pro-cli/wiki/Jenkins) and print its console output
- reduce amount of necessary commands for each developer
- get support by sharing your terminal session via [tmate](https://tmate.io)
- use the `project` command everywhere in your project, not only in your root directory
- every developer is using the exact same environment and tools
- use (force) the same project structure in **every** project
- no need to install and manage multiple versions for each PHP, NPM, MySQL, etc. on your host
- simple access to log files; tail and concat all or just specific services
- switch between projects that you worked on with a single command
- write your own [plugins](https://github.com/chriha/pro-cli/wiki/Plugins) to extend **pro-cli**
- easily list, enable, disable, add and remove your local hosts 

See how you can [use it](#usage), take a look at the [wiki](https://github.com/chriha/pro-cli/wiki) for further help or play around with the [pro-cli-example](https://github.com/chriha/pro-cli-example) project. For a list of available plugins see [pro-cli/plugins](https://github.com/pro-cli/plugins/blob/master/list.json).

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
rm -rf $HOME/.pro-cli && rm /usr/local/bin/project
```


## Usage
> **It's mandatory, that the project has the according directory structure and files in order for pro-cli to work properly.** See `environments` directory for structure and files.

The most used commands while working with *pro-cli*. Remember, every command that is executed inside of a container / service, will be executed in the **application root** (`src/.`), no matter from where you run the `project` command on your host.

### Initalize a new project
```shell
project init FOLDER --type=laravel|php|nodejs|django
```

### Clone and automatically install an existing project
For automatic installation, you need to add an `install` command to the `pro-cli.json`.
```shell
project clone URL_TO_REPOSITORY
```

### Start and stop environment and its services
```shell
project up|down|restart
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
# install the ngrok plugin for pro-cli
project plugins install ngrok
# expose your application using ngrok
project expose [--auth='user:password']
```

### Show service status and resource statistics
```shell
project status|top
```

### Open / tail logs
```shell
project logs [-f] SERVICE
```

### Enable Xdebug
You still need to configure your IDE
```
project xdebug enable|disable|status
```

### Enable, disable, tail and clear MySQL query logs
```
project query-logs enable|disable|tail|clear
```

### List, enable, disable, add, remove and check hosts for existance
```
project hosts list|enable|disable|add|rm|has [HOSTNAME] [IP]
project hosts enable|disable my.website.local
sudo project hosts add my.website.local local|127.0.0.1
sudo project hosts rm my-old.website.local
```
Whenever you change the hosts file (eg enable, disable, add, rm), you have to run the command with sudo / as root. **There will always be a backup of your hosts file with the previous version.**

### Run Docker Compose commands with your `docker-compose.yml`
```shell
project compose ...
```

### Using bash inside a container / service
```shell
project exec SERVICE bash
```

### Share your terminal, even in the browser
```shell
project support [-h|--help] [attach|close|status|tmate]
```

### Start Jenkins build
```shell
# install the jenkins plugin for pro-cli
project plugins install jenkins
project build [-o|--output] stage [--branch=develop]
```
