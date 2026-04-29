pipeline {
    agent any

    environment {
        PROJECT_ID = "kong-gke-493913"
        REGION = "asia-south1"
        REPO = "kong-repo"
        IMAGE_NAME = "kong-custom"
        GAR_HOST = "${REGION}-docker.pkg.dev"
        IMAGE_URI = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:3.9"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate GCP') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                    gcloud auth configure-docker ${GAR_HOST} -q
                    '''
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                sh '''
                docker buildx create --use || true

                docker buildx build \
                  --platform linux/amd64 \
                  -t ${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:3.9 \
                  -t ${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${BUILD_NUMBER} \
                  --push .
                '''
            }
        }
    }
}
