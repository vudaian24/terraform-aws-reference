# modules/eks-cluster

Wraps [`terraform-aws-modules/eks/aws`](https://github.com/terraform-aws-modules/terraform-aws-eks)
(`~> 21.0`). Managed node group, EKS-managed addons (`coredns`, `kube-proxy`,
`vpc-cni`), IRSA enabled by default via the module's OIDC provider.

**Status:** skeleton — contract defined, upstream module call not yet wired.
Alternative compute path to `modules/ecs-service` — a given env wires one, not
both. Kubernetes-level resources (Deployments/Services/Ingress) are out of scope
for this module — it stops at the cluster + node group; app deployment is a
separate concern (Helm/kubectl/Argo, not Terraform's job here).

## Intended inputs (contract)

- `name` (string)
- `cluster_version` (string) — default a recent stable EKS version
- `vpc_id`, `private_subnet_ids` (from `modules/network`)
- `node_instance_types` (list(string))
- `min_size`, `max_size`, `desired_size` (number) — node group scaling
- `tags` (map(string))

## Intended outputs

- `cluster_name`, `cluster_endpoint`, `cluster_certificate_authority_data`
- `oidc_provider_arn` (for IRSA role trust policies)

## Upstream reference

<https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>
