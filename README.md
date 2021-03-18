### Deploying a single module

1. `cd` into the module's folder (e.g. `cd dev/vpc`).
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.


### Deploying all modules in a region

1. `cd` into the region folder (e.g. `cd prod`).
1. Run `terragrunt plan-all` to see all the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply-all`.

### Troubleshooting Terragrunt

Clearing the Terragrunt cache
You can safely delete this folder any time and Terragrunt will recreate it as necessary.

`find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;`


There might be cases where terragrunt does not properly detect that terraform init needs be called. In this case, terraform would fail. Running init command corrects this situation.

`terragrunt init`
 
