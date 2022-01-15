#!/bin/sh

ssh -o ControlMaster=auto -o ControlPersist=30m -o ControlPath=/tmp/ansible-%r@%h:%p -F configuration/ssh.config $1