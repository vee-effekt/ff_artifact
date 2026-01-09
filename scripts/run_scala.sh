#!/bin/bash
cd /ff_artifact/artifact

cd waffle-house/staged-scala

sbt "jmh:run -rf csv -rff /ff_artifact/artifact/results/scala_results.csv"
