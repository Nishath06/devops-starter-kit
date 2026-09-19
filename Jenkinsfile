// =============================================================================
// DevOps Starter Kit — Production Declarative Jenkinsfile (Plain ArgoCD GitOps)
// Multi-Service Architecture: Frontend (React/Vite) & Backend (FastAPI)
// =============================================================================
// Architecture:
//   Push ➔ Pytest (Backend) ➔ Build (Frontend) ➔ Docker Build (Both)
//   ➔ Trivy Scan (Both) ➔ Docker Hub Login ➔ Push Images (Both)
//   ➔ Install yq & gh ➔ Clone GitOps Repo ➔ Update Deployment Manifests
//   ➔ Commit & Push Branch ➔ Create Pull Request (gh) ➔ STOP
//
// GitOps Principles:
//   - CI stops immediately after opening the PR in the infrastructure repo.
//   - ArgoCD monitors the infrastructure repository and synchronizes on merge.
//   - Zero direct cluster access: no kubectl, terraform, or argocd CLI commands.
//   - Plain Kubernetes YAML manifests applied directly by ArgoCD (No Helm).
//
// Required Jenkins Credentials:
//   - 'dockerhub-credentials' (Username with password): Docker Hub authentication.
//   - 'github-pat'            (Secret Text): GitHub PAT for GitOps PR creation.
// =============================================================================

pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '15'))
        disableConcurrentBuilds()
    }

    environment {
        // Global Pipeline Variables
        BACKEND_IMAGE       = 'docker.io/nishathjp/devops-starter-kit-backend'
        FRONTEND_IMAGE      = 'docker.io/nishathjp/devops-starter-kit-frontend'
        GITOPS_REPO         = 'Nishath06/devops-starter-kit-infrastructure'
        BACKEND_MANIFEST    = 'apps/backend/deployment.yaml'
        FRONTEND_MANIFEST   = 'apps/frontend/deployment.yaml'
        BASE_BRANCH         = 'main'

        // Jenkins Credential IDs
        DOCKERHUB_CRED_ID   = 'dockerhub-credentials'
        GITHUB_PAT_CRED_ID  = 'github-pat'
        IMAGE_TAG           = ''
        CHANGES_COMMITTED   = 'false'
    }

    stages {
        // --- Stage 1 — Checkout Repository ---
        stage('Checkout Repository') {
            steps {
                script {
                    checkout scm
                    IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "=================================================="
                    echo "  Commit SHA : ${IMAGE_TAG}"
                    echo "  Branch     : ${env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'main'}"
                    echo "=================================================="
                }
            }
        }

        // --- Stage 2 — Backend Pytest ---
        stage('Backend Pytest') {
            steps {
                echo "Setting up Python virtual environment and executing backend tests..."
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --upgrade pip
                    if [ -f "backend/requirements.txt" ]; then
                        pip install -r backend/requirements.txt
                    elif [ -f "requirements.txt" ]; then
                        pip install -r requirements.txt
                    fi
                    pip install pytest pytest-cov
                    echo "Executing pytest..."
                    if [ -d "backend/tests" ]; then
                        pytest -v backend/tests
                    elif [ -d "tests" ]; then
                        pytest -v tests
                    else
                        pytest -v
                    fi
                '''
            }
        }

        // --- Stage 3 — Frontend Build ---
        stage('Frontend Build') {
            steps {
                echo "Installing dependencies and building React frontend..."
                sh '''
                    if [ -d "frontend" ]; then
                        cd frontend
                    fi
                    if [ -f "package-lock.json" ]; then
                        npm ci
                    else
                        npm install
                    fi
                    npm run build
                '''
            }
        }

        // --- Stage 4 — Docker Build (Backend) ---
        stage('Docker Build (Backend)') {
            steps {
                echo "Building backend Docker image tags: ${BACKEND_IMAGE}:${IMAGE_TAG} and latest..."
                sh """
                    if [ -f "backend/Dockerfile" ]; then
                        docker build \\
                          -t ${BACKEND_IMAGE}:${IMAGE_TAG} \\
                          -t ${BACKEND_IMAGE}:latest \\
                          -f backend/Dockerfile backend/
                    elif [ -f "Dockerfile" ]; then
                        docker build \\
                          -t ${BACKEND_IMAGE}:${IMAGE_TAG} \\
                          -t ${BACKEND_IMAGE}:latest \\
                          .
                    else
                        echo "Error: Dockerfile for backend not found!" && exit 1
                    fi
                """
            }
        }

        // --- Stage 5 — Docker Build (Frontend) ---
        stage('Docker Build (Frontend)') {
            steps {
                echo "Building frontend Docker image tags: ${FRONTEND_IMAGE}:${IMAGE_TAG} and latest..."
                sh """
                    if [ -f "frontend/Dockerfile" ]; then
                        docker build \\
                          -t ${FRONTEND_IMAGE}:${IMAGE_TAG} \\
                          -t ${FRONTEND_IMAGE}:latest \\
                          -f frontend/Dockerfile frontend/
                    else
                        echo "Error: Dockerfile for frontend not found!" && exit 1
                    fi
                """
            }
        }

        // --- Stage 6 — Trivy Scan (Backend) ---
        stage('Trivy Scan (Backend)') {
            steps {
                echo "Scanning backend container image with Aqua Security Trivy..."
                sh """
                    trivy image \\
                      --format table \\
                      --exit-code 1 \\
                      --severity HIGH,CRITICAL \\
                      ${BACKEND_IMAGE}:${IMAGE_TAG}
                """
            }
        }

        // --- Stage 7 — Trivy Scan (Frontend) ---
        stage('Trivy Scan (Frontend)') {
            steps {
                echo "Scanning frontend container image with Aqua Security Trivy..."
                sh """
                    trivy image \\
                      --format table \\
                      --exit-code 1 \\
                      --severity HIGH,CRITICAL \\
                      ${FRONTEND_IMAGE}:${IMAGE_TAG}
                """
            }
        }

        // --- Stage 8 — Docker Hub Login ---
        stage('Docker Hub Login') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                echo "Logging into Docker Hub..."
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CRED_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin'
                }
            }
        }

        // --- Stage 9 — Push Backend Image ---
        stage('Push Backend Image') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                echo "Pushing backend container image tags to Docker Hub..."
                sh """
                    docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                    docker push ${BACKEND_IMAGE}:latest
                """
            }
        }

        // --- Stage 10 — Push Frontend Image ---
        stage('Push Frontend Image') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                echo "Pushing frontend container image tags to Docker Hub..."
                sh """
                    docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                    docker push ${FRONTEND_IMAGE}:latest
                """
            }
        }

        // --- Stage 11 — Install yq ---
        stage('Install yq') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                sh '''
                    if ! command -v yq >/dev/null; then
                        echo "Installing yq..."
                        sudo wget -qO /usr/local/bin/yq \
                          https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
                        sudo chmod +x /usr/local/bin/yq
                    fi
                    yq --version
                '''
            }
        }

        // --- Stage 12 — Install GitHub CLI ---
        stage('Install GitHub CLI') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                sh '''
                    if ! command -v gh >/dev/null; then
                        echo "Installing GitHub CLI..."
                        sudo apt-get update -qq
                        sudo apt-get install -y gh
                    fi
                    gh --version
                '''
            }
        }

        // --- Stage 13 — Clone GitOps Repo ---
        stage('Clone GitOps Repo') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                echo "Cloning GitOps infrastructure repository: ${GITOPS_REPO}..."
                withCredentials([string(credentialsId: GITHUB_PAT_CRED_ID, variable: 'GH_PAT')]) {
                    sh """
                        rm -rf infra-repo
                        git clone --depth 1 --branch "${BASE_BRANCH}" \\
                          "https://x-access-token:\${GH_PAT}@github.com/${GITOPS_REPO}.git" infra-repo
                    """
                }
            }
        }

        // --- Stage 14 — Update Backend Deployment ---
        stage('Update Backend Deployment') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                echo "Updating backend deployment manifest (${BACKEND_MANIFEST})..."
                dir('infra-repo') {
                    sh """
                        export BACKEND_IMAGE="${BACKEND_IMAGE}"
                        export IMAGE_TAG="${IMAGE_TAG}"
                        yq -i '
                        .spec.template.spec.containers =
                        (
                          .spec.template.spec.containers
                          | map(
                              if .name == "backend"
                              then .image = (env(BACKEND_IMAGE) + ":" + env(IMAGE_TAG))
                              else .
                              end
                            )
                        )
                        ' "${BACKEND_MANIFEST}"

                        echo "--- Git Diff (${BACKEND_MANIFEST}) ---"
                        git diff "${BACKEND_MANIFEST}"
                    """
                }
            }
        }

        // --- Stage 15 — Update Frontend Deployment ---
        stage('Update Frontend Deployment') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                echo "Updating frontend deployment manifest (${FRONTEND_MANIFEST})..."
                dir('infra-repo') {
                    sh """
                        export FRONTEND_IMAGE="${FRONTEND_IMAGE}"
                        export IMAGE_TAG="${IMAGE_TAG}"
                        yq -i '
                        .spec.template.spec.containers =
                        (
                          .spec.template.spec.containers
                          | map(
                              if .name == "frontend"
                              then .image = (env(FRONTEND_IMAGE) + ":" + env(IMAGE_TAG))
                              else .
                              end
                            )
                        )
                        ' "${FRONTEND_MANIFEST}"

                        echo "--- Git Diff (${FRONTEND_MANIFEST}) ---"
                        git diff "${FRONTEND_MANIFEST}"
                    """
                }
            }
        }

        // --- Stage 16 — Commit & Push ---
        stage('Commit & Push') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                echo "Checking for manifest changes and creating feature branch..."
                dir('infra-repo') {
                    withCredentials([string(credentialsId: GITHUB_PAT_CRED_ID, variable: 'GH_PAT')]) {
                        script {
                            sh """
                                BRANCH_NAME="update/image-${IMAGE_TAG}"
                                COMMIT_MSG="chore(gitops): update frontend and backend images to ${IMAGE_TAG}"

                                git config user.name "Jenkins CI"
                                git config user.email "jenkins@ci.local"

                                git checkout -b "\${BRANCH_NAME}"
                                git add "${BACKEND_MANIFEST}" "${FRONTEND_MANIFEST}"

                                if git diff --cached --quiet; then
                                    echo "No manifest changes detected. Both images are already up to date. Skipping commit and push."
                                    echo "false" > ../changes_committed.flag
                                else
                                    git commit -m "\${COMMIT_MSG}"
                                    git push origin "\${BRANCH_NAME}" --force
                                    echo "true" > ../changes_committed.flag
                                fi
                            """
                            def flag = readFile('../changes_committed.flag').trim()
                            CHANGES_COMMITTED = flag
                        }
                    }
                }
            }
        }

        // --- Stage 17 — Create Pull Request ---
        stage('Create Pull Request') {
            when {
                anyOf { branch 'main'; branch 'master' }
            }
            steps {
                script {
                    if (CHANGES_COMMITTED == 'false') {
                        echo "No manifest changes were committed. Skipping Pull Request creation."
                    } else {
                        dir('infra-repo') {
                            withCredentials([string(credentialsId: GITHUB_PAT_CRED_ID, variable: 'GH_PAT')]) {
                                sh """
                                    BRANCH_NAME="update/image-${IMAGE_TAG}"
                                    COMMIT_MSG="chore(gitops): update frontend and backend images to ${IMAGE_TAG}"
                                    export GH_TOKEN="\${GH_PAT}"

                                    echo "Checking for existing Pull Request on branch \${BRANCH_NAME}..."
                                    EXISTING=\$(gh pr list \\
                                      --repo "${GITOPS_REPO}" \\
                                      --head "\${BRANCH_NAME}" \\
                                      --json number \\
                                      --jq 'length')

                                    if [ "\${EXISTING}" = "0" ]; then
                                        echo "No existing PR found. Creating Pull Request..."
                                        gh pr create \\
                                          --repo "${GITOPS_REPO}" \\
                                          --base "${BASE_BRANCH}" \\
                                          --head "\${BRANCH_NAME}" \\
                                          --title "\${COMMIT_MSG}" \\
                                          --body "Automated GitOps update for commit \\\`${IMAGE_TAG}\\\`.\\n\\n### Updated Deployments:\\n- **Backend**: \\\`${BACKEND_IMAGE}:${IMAGE_TAG}\\\` (\\\`${BACKEND_MANIFEST}\\\`)\\n- **Frontend**: \\\`${FRONTEND_IMAGE}:${IMAGE_TAG}\\\` (\\\`${FRONTEND_MANIFEST}\\\`)\\n\\nPlain ArgoCD GitOps will detect the merged PR and deploy automatically to Kubernetes."
                                    else
                                        echo "Pull Request already exists for branch \${BRANCH_NAME}. Skipping PR creation."
                                    fi
                                """
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs deleteDirs: true, notFailBuild: true
        }
        success {
            echo "Pipeline finished successfully! GitOps Pull Request is ready for review."
        }
        failure {
            echo "Pipeline failed. Review stage logs for diagnostics."
        }
    }
}
