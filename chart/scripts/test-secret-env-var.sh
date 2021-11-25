#!/bin/bash
[ ! -z $TEST_SECRET ] &&\
[ $TEST_SECRET == 'test-value' ] &&\
[ ! -z $TEST_RANDOM_SECRET ]
