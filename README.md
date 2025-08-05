# GPU Consumption

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)



# About
A basic demo of aggregating consumption metrics of GPUs on OpenShift Clusters

# Why ACM's multi cluster observability
MCO uses thanos. Thanos uses object storage. This allows long term persistence of metrics to ensure stability for billing.
MCO is also configured to guarantee metrics delivery. This eliminates the risks that can occur in prometheus metrics where averaging occurs if metrics are missed.



# Demo constraints
1. Presumption AWS is available for provisioning s3 resources. 
2. GPUs are optionally faked. We don't need real consumption
3. Demo starts with one cluster.
4. This demo only reports consumption. Discounting / tiering etc is out of scope.

# Definining a tenant
- A tenant is defined by a namespace which can be in one or more clusters
  - tenants must not use `openshift-*` namespaces
  - tenants MUST be consistent across multiple clusters, however, may not exist across all clusters
  - A tenant for our purposes is defined as exactly one namespace. Tenants with more than one namespace must be aggregated outside of ACM


# Metrics users stories for a pure GPU cloud

## Red Hat as the owner of a CCSP program
- As a CCSP program owner, for any hour, on the hour, I want to know the number of active worker nodes
- As a CCSP program owner, for any given hour, I want to know the number of GPUs on each worker node that were active:
  - GPUs being active in a given hour is when they are allocated to a running pod
  - Number of GPUs for an hour is the maximum number GPUs allocated at any given time per node.
- AS a CCSP owner I want to known the total number of GPUS active for each hour rolling up from the node definition above

## A provider in the context of billing my tenants
- As a provider, I want a stable repository of consumption data, so that I can retrospectively analyse if any issues arise.
- As a provider, I want to be able generate GPU consumption data to a (TBD) minute resolution fo *note default in ACM is 5 minutes).
- As a provider on a per pod pod basis I want to be able to integrate over a defined period to get GPU / hours or minutes.
  - This must allow for pods to restart / be pending etc.
- As a provider I want a tenant by tenant roll-up
- As a provider I want a tenant roll-up over the billing period until 'now' as best as possible (to estimate whether a tenant will exceed budget)
- As a provider I want the tenants to only see their own metrics
- As a provider I want to be able to differentiate between different GPU classes for billing
- As a provider I want to be able to bill less for MIG slices.
- As a provider I want an internal dashboard
- 
## A tenant in context of understanding their consumption
- As a tenant I want to be able get my consumption directly as well
- As a tenant I want my 'burn rate' on a per pod/deployment as well as the total rate
- As a tenant I want my current consumption for the billing period up to now
- As a tenant I want to be able to configure alerts based on my metrics (e.g hitting 90% of a budget)
- As a tenant I want a dashboard of my consumption

