pipeline {
    agent any

    environment {
        PROJECT_ID = "kong-gke-493913"
        REGION = "asia-south1"
        REPO = "kong-repo"
        IMAGE_NAME = "kong-custom"
        GAR_HOST = "${REGION}-docker.pkg.dev"
        IMAGE_TAG = "3.9-amd64"
        IMAGE_URI = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
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
                docker buildx inspect mybuilder >/dev/null 2>&1 || docker buildx create --name mybuilder --use

                docker buildx build \
                  --platform linux/amd64 \
                  -t ${IMAGE_URI} \
                  -t ${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${BUILD_NUMBER} \
                  --push .
                '''
            }
        }
    }
}
