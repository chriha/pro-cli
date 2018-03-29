# NEW PROJECT

## Requirements
- [Docker](https://docs.docker.com/engine/installation/)
- [pro-cli](https://github.com/chriha/pro-cli) and its own requirements

## Installation
Execute the following command to install the application:
```bash
project install
# show all available commands for this project
project
```

## Configuration

### Ports
To change ports, just update the `./.env` file to your needs.

## Services
Correct the ports if you changed them in your `./.env` file.
- App: https://localhost
- RabbitMQ Management: http://localhost:15672/
- Mailcatcher Frontend: http://localhost:1080/
- phpMyAdmin: http://localhost:8082/
