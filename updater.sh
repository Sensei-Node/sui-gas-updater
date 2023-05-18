#!/bin/bash

INTERACTIVE_MODE=true
NETWORK=""
GAS=""
UNVERIFIED_VAL_CAP=""
# set up these two variables in order to run it with non-interactive mode without -u flag specified
DEFAULT_UNVERIFIED_VAL_CAP_TESTNET="" 
DEFAULT_UNVERIFIED_VAL_CAP_MAINNET=""

while getopts "n:g:u:" opt; do
  case $opt in
    n)
      NETWORK="$OPTARG"
      INTERACTIVE_MODE=false
      ;;
    g)
      GAS="$OPTARG"
      INTERACTIVE_MODE=false
      ;;
    u)
      UNVERIFIED_VAL_CAP="$OPTARG"
      INTERACTIVE_MODE=false
      ;;
    *)
      echo "Usage: $0 -n <network> [-g <gas>] [-u <unverified_val_cap>]"
      exit 1
      ;;
  esac
done

if $INTERACTIVE_MODE; then
  read -p "Enter the network ('mainnet' or 'testnet'): " NETWORK

  if [[ "$NETWORK" == "testnet" ]]; then
    EXPLORER_URL="https://explorer-rpc.testnet.sui.io/"
    UNVERIFIED_VAL_CAP=$DEFAULT_UNVERIFIED_VAL_CAP_TESTNET
  elif [[ "$NETWORK" == "mainnet" ]]; then
    EXPLORER_URL="https://explorer-rpc.mainnet.sui.io/"
    UNVERIFIED_VAL_CAP=$DEFAULT_UNVERIFIED_VAL_CAP_MAINNET
  else
    echo "Invalid network. Exiting..."
    exit 1
  fi

  echo "Selected network: $NETWORK"
  echo "Explorer URL: $EXPLORER_URL"
  echo "Unverified validator cap Object: $UNVERIFIED_VAL_CAP"

  GAS=$(curl -s -X POST -H "Content-Type:application/json" -d '{"method": "suix_getLatestSuiSystemState","jsonrpc": "2.0","params": [],"id": "1"}' "$EXPLORER_URL" | jq '[.result.activeValidators[].gasPrice] | map(tonumber) | add/length | floor')

  read -p "Current GAS value: $GAS. Enter a new value (leave empty to use current): " modified_gas

  if [[ -n "$modified_gas" ]]; then
    GAS="$modified_gas"
  fi

  read -p "Enter a value for UNVERIFIED_VAL_CAP (leave empty to use default): " modified_unverified_val_cap

  if [[ -n "$modified_unverified_val_cap" ]]; then
    UNVERIFIED_VAL_CAP="$modified_unverified_val_cap"
  fi
else
  if [[ -z "$NETWORK" ]]; then
    echo "Error: Network flag is required."
    echo "Usage: $0 -n <network> [-g <gas>] [-u <unverified_val_cap>]"
    exit 1
  fi

  if [[ "$NETWORK" == "testnet" ]]; then
    EXPLORER_URL="https://explorer-rpc.testnet.sui.io/"
    DEFAULT_UNVERIFIED_VAL_CAP=$DEFAULT_UNVERIFIED_VAL_CAP_TESTNET
  elif [[ "$NETWORK" == "mainnet" ]]; then
    EXPLORER_URL="https://explorer-rpc.mainnet.sui.io/"
    DEFAULT_UNVERIFIED_VAL_CAP=$DEFAULT_UNVERIFIED_VAL_CAP_MAINNET
  else
    echo "Invalid network. Exiting..."
    exit 1
  fi

  echo "Selected network: $NETWORK"
  echo "Explorer URL: $EXPLORER_URL"

  if [[ -z "$UNVERIFIED_VAL_CAP" ]]; then
    UNVERIFIED_VAL_CAP="$DEFAULT_UNVERIFIED_VAL_CAP"
  fi

  echo "Unverified validator cap Object: $UNVERIFIED_VAL_CAP"

  if [[ -z "$GAS" ]]; then
    GAS=$(curl -s -X POST -H "Content-Type:application/json" -d '{"method": "suix_getLatestSuiSystemState","jsonrpc": "2.0","params": [],"id": "1"}' "$EXPLORER_URL" | jq '[.result.activeValidators[].gasPrice] | map(tonumber) | add/length | floor')
  fi

  echo "Using GAS value: $GAS"
fi

date
docker exec -it sui-cli sui client call --package 0x3 --module sui_system --function request_set_gas_price --args 0x5 "$UNVERIFIED_VAL_CAP" "$GAS" --gas-budget 20000000