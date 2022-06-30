#!/bin/bash

nohup ./frpc -c ./frpc.ini > ./out.log 2>&1 &
