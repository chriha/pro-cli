# pro-cli

pro-cli is your local little environment manager. You can:

- use the same project structure in **every** project
- initialize and start whole environments (web server, database, caching, etc.) in seconds
- install the project with a single command by using the configuration file
- every developer is using the exact same environment and tools
- simple environment configurations with a single JSON file
- no need to install multiple versions for each tool
- reduce amount of necessary commands for each developer
- simple access to log files

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
project run watch
project run clean
```


## Used repos

- [pro-init-php](https://github.com/chriha/pro-init-php)
- [pro-docker-images](https://github.com/chriha/pro-docker-images)

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

### Add your node scripts to `npm run`

Each project with npm has its `package.json`. You should add your scripts to it! So don't let your co-workers figure out eg. how to compile static files. Help by using `npm run`, these can be:

```bash
npm run dev
npm run watch
npm run production
```

## Supported systems

Currently only PHP is supported. Python and others are coming soon.

## TODOs

- [ ] use `pro-cli.json` (`echo '{"test": {"attr":"Tyler Durden","value":true}}' | jq -r '.test.value'`)
- [ ] update project configuration via `project config`; set a value `project config KEY VALUE`
- [ ] add ability to scale locally
- [ ] command completion
- [ ] add mailcatcher
- [ ] provide ability to use project specific nginx conf
- [ ] automated checks for new versions
- [ ] `project scale web 3`
