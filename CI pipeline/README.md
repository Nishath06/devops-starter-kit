# ⚙️ CI Pipeline Starter Kit (GitHub Actions & Jenkins)

> **Simple, Production-Style Continuous Integration for ArgoCD GitOps on Kubernetes**

This folder contains standalone, beginner-friendly CI pipeline templates that follow strict **GitOps principles**:
* The CI pipeline tests code, builds Docker images, runs security scans, pushes to a container registry, and opens a Pull Request against your GitOps infrastructure repository.
* **The CI pipeline stops after creating the Pull Request.**
* **Zero direct cluster access**: CI never executes `kubectl`, `helm`, `terraform`, or `argocd` commands. Deployment is handled automatically by ArgoCD after the PR is reviewed and merged.

---

## 📁 What's Inside This Directory

```text
CI pipeline/
├── README.md               # You are here — complete setup & customization guide
├── actions-config.md       # Quick-reference cheat sheet for secrets & conventions
├── Jenkinsfile             # Single, standalone declarative Jenkins pipeline
└── workflows/
    └── ci.yml              # Single, standalone GitHub Actions workflow
```

---

## 🔄 End-to-End GitOps CI/CD Flow

```text
Developer Git Push
       │
       ▼
 1. Checkout Code ──────▶ Detect Git commit SHA (IMAGE_TAG)
       │
       ▼
 2. Run Tests ──────────▶ Run pytest / unit tests (pipeline stops if tests fail)
       │
       ▼
 3. Build Docker Image ─▶ Tag with commit SHA and "latest"
       │
       ▼
 4. Trivy Security Scan ─▶ Scan image; fail build if HIGH or CRITICAL CVEs exist
       │
       ▼
 5. Push Docker Image ──▶ Push to Registry (Docker Hub active / AWS ECR commented)
       │
       ▼
 6. GitOps Pull Request ─▶ Clone infra repo, update values.yaml with yq, open PR via gh
       │
       ▼
   [CI STOPS] ──────────▶ Team reviews and merges Pull Request
                                   │
                                   ▼
                         [ArgoCD GitOps Sync]
                         Detects commit in GitOps repo
                         Automatically deploys to Amazon EKS
```

---

## 🚀 The 6 Pipeline Stages Explained

Both `.github/workflows/ci.yml` and `Jenkinsfile` contain the exact same 6 sequential stages:

### Stage 1: Checkout Repository
* Clones the application source code.
* Extracts the short Git commit SHA (e.g. `a1b2c3d`) and exports it as `IMAGE_TAG`.
* Displays repository name, branch, and commit metadata in the build logs.

### Stage 2: Run Tests (Pytest)
* Sets up the runtime environment (Python 3.12).
* Installs dependencies from `requirements.txt`.
* Executes unit tests using `pytest -v`.
* **If any test fails, the pipeline immediately stops** to prevent faulty images from being built.

### Stage 3: Build Docker Image
* Builds the container image using the project `Dockerfile`.
* Tags the image with two tags:
  1. Git commit SHA tag: `<IMAGE_NAME>:<IMAGE_TAG>` (e.g., `docker.io/username/myapp:a1b2c3d`)
  2. Latest tag: `<IMAGE_NAME>:latest`

### Stage 4: Trivy Security Scan
* Runs **Aqua Security Trivy** vulnerability scanner against the local container image before pushing.
* Enforces a security quality gate: if any `HIGH` or `CRITICAL` vulnerabilities are found, the step exits with code `1` and fails the pipeline.
* Prints a clean vulnerability table directly in the console logs.

### Stage 5: Push Docker Image (Dual Registry Support)
* **Option A (Active by default)**: Authenticates with **Docker Hub** using credentials and pushes both tags (`<IMAGE_TAG>` and `latest`).
* **Option B (Commented out)**: Fully scaffolded **Amazon ECR** login and push block. Can be enabled in seconds by uncommenting the ECR section and commenting the Docker Hub section.

### Stage 6: GitOps Infrastructure Pull Request
* Clones your separate GitOps infrastructure repository (`GITOPS_REPO`).
* Creates a dedicated feature branch: `update/image-<IMAGE_TAG>`.
* Uses `yq` to update **only** the image repository and tag inside the Helm values file (e.g., `environments/dev/backend/values.yaml`):
  ```yaml
  image:
    repository: docker.io/username/myapp
    tag: a1b2c3d
  ```
* Verifies the change with `git diff`.
* Commits and pushes the feature branch.
* Automatically creates an unmerged Pull Request using the **GitHub CLI (`gh`)** with a rich description.
* **Pipeline stops here.** ArgoCD takes over after human review and merge.

---

## 🛠️ How to Customize: What Do You Need to Change?

Customizing the pipeline for your project takes less than 2 minutes. Open `.github/workflows/ci.yml` or `Jenkinsfile` and edit the `env` / `environment` block at the top:

| Variable | What It Is | Example / What to Change |
| :--- | :--- | :--- |
| `IMAGE_NAME` | Full container image name | Change `docker.io/username/myapp` to your Docker Hub repository or AWS ECR repository URI |
| `GITOPS_REPO` | Target GitOps infrastructure repo | Change `your-org/starter-app-infrastructure` to your GitHub repo (`owner/repo`) |
| `ENVIRONMENT` | Target deployment environment | Set to `dev`, `staging`, or `prod` (default: `dev`) |
| `VALUES_FILE` | Path to values.yaml in GitOps repo | Set to `environments/dev/backend/values.yaml` (or your service path) |
| `BASE_BRANCH` | Default branch in GitOps repo | Usually `main` or `master` |

---

## 🔄 How to Switch from Docker Hub to Amazon ECR

Both pipelines come with Docker Hub active and Amazon ECR commented out. To switch:

### In GitHub Actions (`workflows/ci.yml`):
1. Change `IMAGE_NAME` at the top of the file:
   ```yaml
   IMAGE_NAME: "${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/myapp"
   ```
2. In **Stage 5**, comment out the `Option A: Docker Hub Push` steps.
3. Uncomment the `Option B: Amazon ECR Push` steps:
   ```yaml
   - name: Stage 5 (ECR) — Configure AWS Credentials
     if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master' || github.event_name == 'workflow_dispatch'
     uses: aws-actions/configure-aws-credentials@v4
     with:
       aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
       aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
       aws-region: ${{ secrets.AWS_REGION }}

   - name: Stage 5 (ECR) — Push Image to Amazon ECR
     if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master' || github.event_name == 'workflow_dispatch'
     run: |
       aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com
       docker push "${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}"
       docker push "${{ env.IMAGE_NAME }}:latest"
   ```

### In Jenkins (`Jenkinsfile`):
1. Update `IMAGE_NAME` in the `environment` block to your ECR URI.
2. In **Stage 5**, comment out `Option A` and uncomment the `Option B` block wrapped in `withCredentials`.

---

## 🧪 How to Customize Stage 2 for Other Tech Stacks

If your application is not Python/FastAPI, simply update Stage 2:

### For Node.js / React / Next.js:
```bash
# In GitHub Actions (replace Stage 2 steps):
- uses: actions/setup-node@v4
  with:
    node-version: 22
- run: |
    npm ci
    npm run lint --if-present
    npm test -- --watchAll=false --passWithNoTests
```

### For Go (Golang):
```bash
- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
- run: |
    go test -v ./...
```

### For Java / Spring Boot (Maven):
```bash
- uses: actions/setup-java@v4
  with:
    distribution: 'temurin'
    java-version: '21'
- run: mvn clean test
```

---

## 🔐 Required Secrets & Credentials Setup

### For GitHub Actions:
Navigate to your repository on GitHub: **Settings ➔ Secrets and variables ➔ Actions ➔ New repository secret**

1. **Always Required (for GitOps PR)**:
   * `GH_PAT`: Personal Access Token (classic or fine-grained) with `repo` permissions to clone and push to `GITOPS_REPO`.
2. **For Docker Hub (Default)**:
   * `DOCKER_USERNAME`: Your Docker Hub username.
   * `DOCKER_TOKEN`: Docker Hub Personal Access Token.
3. **For Amazon ECR (If switching to ECR)**:
   * `AWS_ACCESS_KEY_ID`: IAM user access key with ECR push permissions.
   * `AWS_SECRET_ACCESS_KEY`: IAM user secret access key.
   * `AWS_REGION`: AWS region (e.g. `us-east-1`).
   * `AWS_ACCOUNT_ID`: 12-digit AWS account number.

---

### For Jenkins:
Navigate to **Manage Jenkins ➔ Credentials ➔ System ➔ Global credentials ➔ Add Credentials**

| Credential ID | Kind | Value |
| :--- | :--- | :--- |
| `github-pat` | **Secret text** | GitHub Personal Access Token (`repo` scope) |
| `dockerhub-credentials` | **Username with password** | Docker Hub username & password/PAT |
| `aws-credentials` | **Username with password** | AWS Access Key ID (username) & Secret Key (password) *(If using ECR)* |
| `aws-account-id` | **Secret text** | 12-digit AWS Account ID *(If using ECR)* |
| `aws-region` | **Secret text** | Target AWS region, e.g. `us-east-1` *(If using ECR)* |

---

## 🚀 How to Use These Files in Your Project

### Using GitHub Actions:
1. In your application repository, create the directory `.github/workflows/`.
2. Copy `CI pipeline/workflows/ci.yml` to `.github/workflows/ci.yml`.
3. Set your GitHub secrets and customize `IMAGE_NAME` & `GITOPS_REPO`.
4. Commit and push to `main` — your pipeline will run automatically!

### Using Jenkins:
1. Copy `CI pipeline/Jenkinsfile` to the root of your application repository.
2. Ensure Docker, Trivy, and `yq` are installed on your Jenkins agent (or available in PATH).
3. In Jenkins, create a **Pipeline** or **Multibranch Pipeline** job pointing to your Git repository.
4. Add the credentials described above in Jenkins Credentials Manager.
5. Click **Build Now** to execute the pipeline!
