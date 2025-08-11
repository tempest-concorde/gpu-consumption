# Observability Chart with AWS S3 Integration

This Helm chart deploys the necessary components for observability infrastructure, including automated S3 bucket creation using AWS Controllers for Kubernetes (ACK).

## Features

- **AWS S3 Controller**: Deploys ACK S3 controller for managing S3 buckets
- **Automated S3 Bucket Creation**: Creates an S3 bucket in the same region as the cluster
- **Thanos Object Storage**: Configures S3 bucket for Thanos/MCO object storage
- **Region Detection**: Automatically detects AWS region from cluster metadata
- **Security Best Practices**: Implements encryption, versioning, and access controls

## Prerequisites

1. **IAM Permissions**: The cluster must have appropriate IAM permissions to create and manage S3 buckets
2. **AWS Controllers for Kubernetes**: The ACK S3 controller will be deployed as part of this chart
3. **OpenShift/Kubernetes**: Compatible with OpenShift 4.x and Kubernetes 1.21+

## Configuration

### Required Configuration

Update your pattern's values files to include:

```yaml
global:
  aws:
    region: "us-east-1"  # Optional: Will be auto-detected if not provided
  pattern: "gpu-consumption"

aws:
  # IAM role ARN for ACK S3 controller (required for production)
  iamRoleArn: "arn:aws:iam::123456789012:role/ack-s3-controller"

thanos:
  objectStorage:
    namespace: "open-cluster-management-observability"
    s3:
      bucketName: ""  # Optional: Will be auto-generated if not provided
```

### IAM Role Setup

Create an IAM role with the following permissions for the ACK S3 controller:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketVersioning",
        "s3:ListBucket",
        "s3:PutBucketEncryption",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketTagging",
        "s3:PutBucketVersioning",
        "s3:PutLifecycleConfiguration"
      ],
      "Resource": "*"
    }
  ]
}
```

## Deployment

The chart will be automatically deployed as part of the GPU Consumption pattern. The deployment includes:

1. **Region Detection Job**: Automatically detects the AWS region
2. **ACK S3 Controller**: Deploys the AWS controller for S3 management
3. **S3 Bucket**: Creates the bucket with proper configuration
4. **Secrets and ConfigMaps**: Provides configuration for MCO/Thanos

## Resources Created

### S3 Bucket Configuration

The created S3 bucket includes:

- **Encryption**: Server-side encryption with AES256
- **Versioning**: Enabled for data protection
- **Lifecycle Policy**: Automatic transition to cheaper storage classes
- **Public Access Block**: Prevents public access for security
- **Tags**: Proper resource tagging for management

### Kubernetes Resources

- `Namespace`: `ack-s3-system` for the S3 controller
- `Secret`: `thanos-object-storage` with S3 configuration for MCO
- `ConfigMap`: `s3-bucket-config` with bucket information
- `ConfigMap`: `aws-region-config` with detected region

## Region Detection

The chart automatically detects the AWS region using multiple methods:

1. **EC2 Metadata Service**: For EC2-based clusters
2. **Node Topology Labels**: `topology.kubernetes.io/region`
3. **Legacy Node Labels**: `failure-domain.beta.kubernetes.io/region`
4. **Provider ID**: Extracts region from node provider ID
5. **Fallback**: Uses configured value from `global.aws.region`

## Troubleshooting

### Common Issues

1. **IAM Permissions**: Ensure the cluster has proper IAM permissions
2. **Region Detection**: Check the `aws-region-detector` job logs
3. **S3 Controller**: Verify the ACK S3 controller pod status
4. **Bucket Creation**: Check the Bucket custom resource status

### Verification Commands

```bash
# Check region detection
kubectl get configmap aws-region-config -n open-cluster-management-observability -o yaml

# Check S3 bucket status
kubectl get bucket -n open-cluster-management-observability

# Check ACK S3 controller
kubectl get pods -n ack-s3-system

# Verify Thanos configuration
kubectl get secret thanos-object-storage -n open-cluster-management-observability -o yaml
```

## Integration with MCO

This chart creates the necessary S3 bucket and configuration that can be used by ACM's Multi-Cluster Observability (MCO) for Thanos object storage. The `thanos-object-storage` secret contains the proper configuration format expected by MCO.

## Cost Optimization

The S3 bucket includes lifecycle policies to automatically transition data to cheaper storage classes:

- **30 days**: Standard to Standard-IA
- **90 days**: Standard-IA to Glacier
- **365 days**: Glacier to Deep Archive

## Security

- Server-side encryption enabled
- Public access blocked
- IAM role-based authentication
- Versioning enabled for data protection
