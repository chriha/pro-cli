# pro-cli

- [Install](#install)
  - [Dependencies](#dependencies)
  - [Install pro-cli](#install-pro-cli)
- [Commands](#commands)
  - [Logs](#logs)
- [Configuration](#configuration)
  - [Installation scripts](#installation-scripts)
  - [Scripts](#scripts)
- [Used Repos](#used-repos)
  - [docker](#docker)
- [Tips](#tips)
  - [Use aliases](#use-aliases)
  - [Add your node scripts to npm run](#add-your-node-scripts-to-npm-run)
- [Supported Systems](#supported-systems)
- [Uninstall](#uninstall)
- [Todos](#todos)


pro-cli is your local little environment manager. You can:

- use the same project structure in **every** project
- initialize and start whole environments (web server, database, caching, mail server, RabbitMQ, etc.) in seconds
- install projects with a single command by using [installation scripts](#installation-scripts)
- every developer is using the exact same environment and tools
- no need to install multiple versions for each tool locally, just use the `project` command
- reduce amount of necessary commands for each developer
- add custom commands to your project via [scripts](#scripts)
- simple access to log files; tail and concat all or just specific systems

## Install

### Dependencies

- [jq](https://stedolan.github.io/jq/) -> [download](https://stedolan.github.io/jq/download/)

### Install pro-cli

```bash
git clone -q https://github.com/chriha/pro-cli.git $HOME/.pro-cli && $HOME/.pro-cli/setup.sh
```

Reload your shell and use the `project` command with all its beauty.

## Commands

Commands are depending on the project type. List them via the `project` command. If you are inside a project, pro-cli will show you all available commands for that specific type. Outside the projects, you will just see the commands, that are specific to pro-cli.

### Logs

Tail logs of all or just specific services. See `project logs -h` for further help.

## Configuration

Every pro-cli project has an own [`pro-cli.json`](pro-cli.json) file.

### Installation scripts

To use the `project install` command, you should add all your scripts that install the application to the `install` property of the configuration file.

```json
{
  "install": {
    "composer": "project composer install",
    "npm-install": "project npm install",
    "migrations": "project artisan migrate",
    "seeds": "project artisan db:seed ..."
  }
}
```

### Scripts

Of course you can add your own scripts to hook into pro-cli and use them as *run commands*.

```json
{
  "scripts": {
    "watch": "project npm run watch",
    "clean": "project composer clear-cache && project artisan optimize"
  }
}
```

Which can then be executed as:

```bash
project watch
project clean
```


## Used repos

As every project can be different by its type, you'll find further information about the project structure, docker-compose files, etc. at the following respositories:
- [pro-init-php](https://github.com/chriha/pro-init-php)

### docker

Nevertheless, each project has its `docker-compose.yml` which should not be touched as it will be overwritten as soon as the project structure gets updated. Instead you should create your own docker-compose file according to the `env` in `pro-cli.json`. For example, if you set the `env` to `local`, **pro-cli** will look for and use `docker-compose.local.yml`. Take a look at [pro-init-php](https://github.com/chriha/pro-init-php) for an example.

## Tips

### Use aliases

```bash
alias artisan='project artisan'
alias gulp='project gulp'
alias npm='project npm'
alias compose='project compose'
alias composer='project composer'
...
```

### Add your node scripts to npm run

Each project with npm has its `package.json`. You should add your scripts to it! So don't let your co-workers figure out eg. how to compile static files. Help by using `npm run`, these can be:

```bash
npm run dev
npm run watch
npm run production
```

## Supported systems

Currently only PHP is supported. Python and others are coming soon.

## Uninstall

```bash
rm -rf $HOME/.pro-cli && rm $HOME/.bin/project
```

## TODOs

- [ ] command completion
- [ ] provide ability to use project specific nginx conf
- [ ] automated checks for new versions
- [ ] add scaling: `project scale web 3`
