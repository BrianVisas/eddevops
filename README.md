# DevOps Platform Deployment Example

A compact deployment project that demonstrates application packaging, containerization, Kubernetes orchestration, Terraform-based infrastructure configuration, and automated validation through GitHub Actions.

## Architecture

```text
Client
  |
  v
FastAPI service
  |
  +--> Docker image
          |
          +--> Docker Compose (local execution)
          |
          +--> Kubernetes Deployment + Service
                    |
                    +--> Terraform-managed Kubernetes resources
```

The application exposes two endpoints:

- `GET /health` — health probe used by container and Kubernetes checks
- `GET /status` — service status and UTC timestamp

## Repository structure

```text
.
├── app/
│   └── main.py
├── infra/
│   └── terraform/
│       ├── main.tf
│       └── variables.tf
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── tests/
│   └── test_app.py
├── .github/workflows/ci.yml
├── compose.yaml
├── Dockerfile
├── requirements.txt
├── requirements-dev.txt
└── sample-project.zip
```

`sample-project.zip` is retained from the earlier Azure DevOps starter setup as historical material. The maintained implementation is the application, container, Kubernetes, Terraform, and CI configuration documented above.

## Local execution

### Python

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
uvicorn app.main:app --reload
```

The service is available at `http://localhost:8000`.

### Docker

```bash
docker build -t platform-status-api:local .
docker run --rm -p 8000:8000 platform-status-api:local
```

### Docker Compose

```bash
docker compose up --build
```

The Compose health check calls `/health` from inside the container.

## Kubernetes deployment

The manifests under `k8s/` define:

- two application replicas
- readiness and liveness probes
- CPU and memory requests/limits
- an internal `ClusterIP` service

Example deployment:

```bash
kubectl apply -f k8s/
kubectl get deployments,services,pods
```

For local clusters such as `kind` or `minikube`, load or publish the image before applying the manifests.

## Terraform

The Terraform configuration under `infra/terraform/` creates:

- a dedicated namespace
- the application Deployment
- the application Service

Initialize and validate:

```bash
cd infra/terraform
terraform init
terraform validate
```

Apply against the Kubernetes cluster referenced by the configured kubeconfig:

```bash
terraform plan
terraform apply
```

Inputs include the namespace, replica count, container image, and kubeconfig path.

## Continuous integration

GitHub Actions runs three independent validation jobs:

1. **Test API** — installs Python dependencies and runs `pytest`
2. **Build container** — verifies that the Docker image builds successfully
3. **Validate Terraform** — checks Terraform formatting, initializes providers without a backend, and validates the configuration

Keeping these checks independent makes failures easier to isolate and prevents an unrelated validation step from masking the others.

## Reliability considerations

The deployment configuration includes health probes, resource constraints, multiple replicas, and container-level health checks. These controls provide basic failure detection and scheduling boundaries, but they do not replace production concerns such as ingress configuration, TLS termination, autoscaling, persistent observability, secret management, image signing, or centralized logging.

## Security considerations

No credentials are stored in the repository. Cluster access remains external through kubeconfig configuration. In a production environment, application and infrastructure secrets should be supplied through an appropriate secret-management mechanism rather than committed as files or Terraform variables containing plaintext values.
