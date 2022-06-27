#!/bin/bash
KEYWORD=$1
ls /dev/serial/by-id | grep -i $KEYWORD
