# Sui Gas Updater

The purpose of this repo is to provide an automatic method of updating validators gas price using the average of all the other validators gas price. It is intended to be used with a cronjob run every 3 days for instance.

## Requirements

1. Run the docker container by using `docker-compose up -d`
2. Set up an account on the cli, that account should have ownership of the `0x3::validator_cap::UnverifiedValidatorOperationCap` object of your validator and some SUI coin objects for being able to pay for gas update transaction gas fees.

## Script

The `updater.sh` script could work in an interactive/non interactive way (if used with cron jobs you must run it in non-interactive mode). It gets the average gas price value of all the nodes in the network and then executes the `request_set_gas_price` function.
Script will make usage of the `sui-cli` container, so make sure to have it up before running it.

### Interactive mode

You can just run the `updater.sh` without any flags. User interaction required.

```
./updater.sh
```

### Non interactive mode

For non interactive mode you must provide at least network flag `-n` and UnverifiedValidatorOperationCap flag `-u`. You can also provide a gas flag `-g` for skipping the average gas price.

```
./updater.sh -n mainnet -u 0x0000000000000000000000
```

## Setting up cron task

First you need to create a new job using `crontab -e`. In case you want to run it every 3 days (and you wish to keep logs of the script on `/home/ubuntu/cron.log`) this line should be added to the end of the file:

```
0 0 */3 * * /home/ubuntu/updateGas.sh -n mainnet -u 0x0000000000000000000000 >> /home/ubuntu/cron.log 2>&1
```

Make sure to accomodate `-n` and `-u` flags according to your needs.
