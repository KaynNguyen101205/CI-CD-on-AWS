def appImage
def effectiveTag

pipeline {
  agent any

  parameters {
    string(
      name: 'IMAGE_REPO',
      defaultValue: 'your-dockerhub-username/sample-next-app',
      description: 'Docker Hub repository in username/name form'
    )
    string(
      name: 'APP_VERSION',
      defaultValue: '',
      description: 'tag override (falls back to build number)'
    )
  }

  environment {
    DOCKER_REGISTRY = 'https://index.docker.io/v1/'
    DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timestamps()
  }

  stages {
    stage('Clean workspace') {
      steps {
        deleteDir()
      }
    }

    stage('Checkout source') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          effectiveTag = params.APP_VERSION?.trim() ? params.APP_VERSION.trim() : env.BUILD_NUMBER
          def imageName = "${params.IMAGE_REPO}:${effectiveTag}"
          echo "Building ${imageName}"
          appImage = docker.build(imageName)
        }
      }
    }

    stage('Push image to Docker Hub') {
      steps {
        script {
          docker.withRegistry(env.DOCKER_REGISTRY, env.DOCKER_CREDENTIALS_ID) {
            appImage.push()
            sh "docker tag ${appImage.imageName()} ${params.IMAGE_REPO}:latest"
            sh "docker push ${params.IMAGE_REPO}:latest"
          }
        }
      }
    }

    stage('Verify Docker Hub tags') {
      steps {
        script {
          def repo = params.IMAGE_REPO
          sh label: 'Verify tags exist via Docker Hub API', script: """
            set -euo pipefail
            mkdir -p metrics
            python3 - <<'PY'
import json
import math
import urllib.request

repo = "${repo}"
tags = ["${effectiveTag}", "latest"]
metrics_path = "metrics/image-size.csv"
rows = ["tag,size_mb"]
for tag in tags:
    url = f"https://hub.docker.com/v2/repositories/{repo}/tags/{tag}"
    with urllib.request.urlopen(url) as resp:
        if resp.status != 200:
            raise SystemExit(f"Failed to find tag {tag} (status {resp.status})")
        data = json.load(resp)
    size_mb = data.get("full_size", 0) / (1024 * 1024)
    rows.append(f"{tag},{size_mb:.2f}")
with open(metrics_path, "w", encoding="utf-8") as file_out:
    file_out.write("\\n".join(rows) + "\\n")
PY
          """
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'metrics/*.csv', fingerprint: true, onlyIfSuccessful: false
      sh 'docker image prune -f || true'
    }
    success {
      echo "Image ${params.IMAGE_REPO}:${effectiveTag} pushed and verified."
    }
    failure {
      echo 'Pipeline failed. Check logs above.'
    }
  }
}

