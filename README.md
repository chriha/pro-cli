# pro-cli

pro-cli is your local little environment manager. You can:

- quickly switch between projects that you worked on
- use the same project structure in **every** project
- initialize and start whole environments (web server, database, caching, mail server, RabbitMQ, etc.) in seconds
- install projects with a single command by using your own [comands](https://github.com/chriha/pro-cli/wiki/Using-the-install-command-and-scripts)
- every developer is using the exact same environment and tools
- no need to install multiple versions for each tool on your host
- reduce amount of necessary commands for each developer
- simple access to log files; tail and concat all or just specific services
- use the `project` command everywhere in your project, not only in your root

See the [wiki](https://github.com/chriha/pro-cli/wiki) for further help.


## TOC
- [Install](#install)
  - [Dependencies](#dependencies)
  - [Install pro-cli](#install-pro-cli)
- [Update](#update)
- [Uninstall](#uninstall)
- [Configuration](#configuration)


## Install
### Dependencies
- The amazing [jq](https://stedolan.github.io/jq/) -> [download](https://stedolan.github.io/jq/download/)


### Install pro-cli
After installing *jq* via `brew install jq`, please install pro-cli via:
```bash
git clone -q https://github.com/chriha/pro-cli.git $HOME/.pro-cli && $HOME/.pro-cli/setup.sh
```

Reload your shell and use the `project` command with all its beauty.


## Update
To manually update **pro-cli** just use the `project self-update` command.


## Uninstall
```bash
rm -rf $HOME/.pro-cli && rm $HOME/.bin/project
```


## Configuration
Every pro-cli project has its own [`pro-cli.json`](pro-cli.json) file which you can change to your needs. Add whole installation processes or single commands.

