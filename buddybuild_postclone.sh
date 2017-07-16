#!/usr/bin/env bash

cd $BUDDYBUILD_WORKSPACE

brew install sourcery
sourcery

ls -hal
