# About

GitHub action to implement mutual exclusion within your workflow. It
prevents parallel execution of "protected" steps in your workflow by using
a kubernetes secret as a distributed lock.

# Example

In the following example we protect the "Deploy" step from concurrent
execution by other runs of the workflow.

```yaml
on:
  push:
    branches:
      - master
name: Deployer
jobs:
  deploy-plz:
    runs-on: ubuntu-18.04
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Lock workflow
      uses: directangular/k8s-lock-action@v1
      with:
        kube_config_data: ${{ secrets.KUBE_CONFIG_DATA }}
        lock_name: "my-deploy-lock"
    - name: Deploy
      uses: ./actions/deployer/
```

Note that you'll need to make any necessary workspace preparations for
proper operation of your `kubeconfig`. For example, with EKS you would need
to configure your AWS credentials prior to `k8s-lock-action` since your
`kubeconfig` likely uses the `aws eks` command to authenticate. The image
this action runs with includes the `aws-cli-v2` package, which will pick up
authentication from `aws-actions/configure-aws-credentials` or
similar. Here's the above example with AWS credential configuration added:

```yaml
    - name: Checkout
      uses: actions/checkout@v2
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
    - name: Lock workflow
      uses: directangular/k8s-lock-action@v1
      with:
        kube_config_data: ${{ secrets.KUBE_CONFIG_DATA }}
        lock_name: "my-deploy-lock"
    - name: Deploy
      uses: ./actions/deployer/
```

# Inputs

## `kube_config_data`

Required. Use `base64 < ~/.kube/config` (or similar) to generate.

## `lock_name`

Required. Must be unique across the repository where this action is used
(otherwise unrelated actions might block each other).

## `kube_context`

Optional. The context from the provided `kubeconfig` that should be
used. This string is simply passed to `kubectl use-context`.

## `max_attempts`

Optional. How many times we try to grab the lock before bailing. Defaults
to 10000.

# How it works

This action abuses kubernetes secrets by using them as a distributed
lock. The value of the secret is the build number that is currently allowed
to execute. During the post action cleanup phase the value of the secret is
incremented, allowing the next build to execute.

# Limitations

## Stuck locks

If the secret gets messed up somehow the task will block until it hits
`max_attempts`, and then will fail. You can unblock it by overwriting the
secret manually:

    kubectl create secret generic <secret_name> --from-literal=next_build=<next_build> --dry-run -o yaml | kubectl replace -f -

(The exact command is also displayed at the beginning of the lock process
for easy reference.)

## Supported k8s environments

Currently only tested on EKS. Test results and patches for other
environments are welcome.

## Re-runs

GitHub does not increment the `GITHUB_RUN_NUMBER` when you re-run a
workflow. Therefore, re-runs will never successfully grab the lock since
the lock value increases monotonically with each build.

The bottom line is that you should avoid re-running your builds. If you
really want to re-run a build you'll just need to intervene as per the
"Stuck locks" section above.

## Releases

### v2

- kubectl 1.32

### v1

- kubectl 1.17
