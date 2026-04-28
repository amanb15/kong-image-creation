pipeline {
    agent any

    environment {
        PROJECT_ID = "kong-gke-493913"
        REGION = "asia-south1"
        REPO = "kong-repo"
        IMAGE_NAME = "kong-custom"
        TAG = "${BUILD_NUMBER}"
        GAR_HOST = "${REGION}-docker.pkg.dev"
        IMAGE_URI = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${TAG}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t ${IMAGE_URI} ."
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

        stage('Push Image') {
            steps {
                sh "docker push ${IMAGE_URI}"
            }
        }
    }
}
