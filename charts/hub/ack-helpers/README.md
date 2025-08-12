# ACK Helpers Chart

This Helm chart deploys helper components for AWS Controllers for Kubernetes (ACK) when running on AWS OpenShift clusters managed by Red Hat Advanced Cluster Management (ACM).

## Overview

The ACK Helpers chart creates a ConfigMap in the `ack-system` namespace that provides configuration for ACK controllers. The deployment is orchestrated using Red Hat ACM policies to ensure it only runs on AWS clusters.

## Features

- **Automatic AWS Detection**: Only deploys on clusters identified as AWS platforms
- **Region Auto-Detection**: Automatically detects AWS region using `topology.kubernetes.io/region` node labels
- **ACM Policy-Based Deployment**: Uses Red Hat ACM policies for controlled deployment across managed clusters
- **Comprehensive Configuration**: Provides skeleton configuration for various ACK controller settings

## Components

### ConfigMap (`ack-system-config`)

The main ConfigMap deployed to the `ack-system` namespace contains:

- **AWS_REGION**: Automatically detected from node topology labels with fallback to `us-east-1`
- **Controller Configuration**: Log levels, leader election settings
- **AWS Service Configuration**: Endpoint URLs, retry settings, throttling configuration
- **Reconciliation Settings**: Sync periods and concurrency limits
- **Resource Management**: Tagging and deletion policies
- **Monitoring Settings**: Metrics and profiling configuration
- **Security Settings**: Namespace watching and development logging
- **Feature Flags**: Resource finalization and assume role ARN support

### ACM Policy Structure

The chart creates three main ACM resources:

1. **Policy**: Defines the ConfigMap to be created on target clusters
2. **PlacementBinding**: Links the policy to the placement rule
3. **PlacementRule**: Targets AWS OpenShift clusters specifically

## Prerequisites

- Red Hat Advanced Cluster Management (ACM) deployed on hub cluster
- Managed OpenShift clusters running on AWS
- ACK controllers installed on target clusters (this chart only provides configuration)

## Usage

### Basic Deployment

The chart is automatically enabled when `global.clusterPlatform` is set to `"AWS"`:

```yaml
global:
  clusterPlatform: "AWS"
```

### Configuration

The chart provides extensive configuration options through `values.yaml`:

```yaml
ackSystem:
  enabled: true
  configMap:
    name: "ack-system-config"
    namespace: "ack-system"
    defaultRegion: "us-east-1"
    controller:
      logLevel: "info"
      enableLeaderElection: true
    aws:
      maxRetries: 3
    # ... additional configuration
```

### Cluster Targeting

By default, the chart targets clusters with these labels:
- `cloud: AWS`
- `vendor: OpenShift`

You can customize targeting through the `placement` values:

```yaml
placement:
  clusterSelector:
    cloud: "AWS"
    vendor: "OpenShift"
    environment: "production"  # Additional selector
```

## Region Detection

The chart uses multiple methods to detect the AWS region, in order of priority:

1. **Node Topology Labels**: `topology.kubernetes.io/region` (primary method)
2. **Fallback**: Uses the configured `defaultRegion` value

The region detection happens at deployment time using ACM policy template functions.

## Integration with ACK Controllers

This ConfigMap is designed to be consumed by ACK controllers deployed on the managed clusters. Common use cases include:

- S3 Controller configuration
- EC2 Controller settings
- RDS Controller parameters
- Lambda Controller options

## Security Considerations

- The ConfigMap is deployed with appropriate labels for traceability
- Resource tags include provenance information
- Development logging is disabled by default
- Namespace watching can be restricted as needed

## Troubleshooting

### ConfigMap Not Created

1. Verify the cluster has `cloud: AWS` label
2. Check ACM policy compliance on the hub cluster
3. Ensure the target cluster is available in ACM

### Incorrect Region Detection

1. Verify nodes have `topology.kubernetes.io/region` labels
2. Check the fallback `defaultRegion` value in configuration
3. Review ACM policy template resolution logs

### Policy Not Applied

1. Confirm the PlacementRule matches target clusters
2. Check PlacementBinding configuration
3. Verify ACM governance is enabled on target clusters

## Contributing

When modifying this chart:

1. Ensure ACM policy templates are properly escaped
2. Test region detection logic on actual AWS clusters
3. Validate YAML formatting for nested configurations
4. Update documentation for new configuration options
