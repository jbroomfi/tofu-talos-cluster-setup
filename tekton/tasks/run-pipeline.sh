#!/bin/bash

# Create the pipeline run
PIPELINE_RUN=$(kubectl create -f pipeline-run.yaml -o jsonpath='{.metadata.name}')

# Watch the pipeline execution
tkn pipelinerun logs "$PIPELINE_RUN" -f -n default

# List all pipeline runs
tkn pipelinerun list -n default
