pipeline {
    agent any

    environment {
        PROJECT_ID = "kong-gke-495314"
        REGION = "us-central1"
        REPO = "my-repo"
        IMAGE_NAME = "kong-custom"
        GAR_HOST = "${REGION}-docker.pkg.dev"
        IMAGE_TAG = "3.9.0.0"
        IMAGE_URI = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
        IMAGE_URI_BUILD = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate GCP') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GCLOUD_KEY')]) {
                    sh '''
                    gcloud auth activate-service-account --key-file="$GCLOUD_KEY"
                    gcloud auth configure-docker us-central1-docker.pkg.dev -q
                    '''
                }
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                docker build \
                  --build-arg KONG_VERSION=3.9.0.0 \
                  -t ${IMAGE_URI} \
                  -t ${IMAGE_URI_BUILD} \
                  .
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker push ${IMAGE_URI}
                docker push ${IMAGE_URI_BUILD}
                '''
            }
        }
    }
}
