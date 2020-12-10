# List "Orphaned" Terraform State Files

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-orphaned-terraform-statefiles/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-orphaned-terraform-statefiles/releases)

Sometimes terraform state files belonging to test clusters are not deleted when they should be, for example if an error occurs when deleting the cluster.

This repository lists all terraform state files in our S3 bucket, excluding any which;
* do not belong to a specific cluster ("cloud-platform-environments", "global-resources", etc.)
* belong to a cluster which currently exists

All such terraform state files should be deleted.

## Pre-requisites

See `env.example` for a list of the environment variables required for this code to operate.

## Usage

```
./bin/list-statefiles.rb
```


