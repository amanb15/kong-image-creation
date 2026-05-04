pipeline {
    agent any

    environment {
        PROJECT_ID = "kong-gke-495314"
        REGION = "us-central1"
        REPO = "my-repo"
        IMAGE_NAME = "kong-custom"
        GAR_HOST = "us-central1-docker.pkg.dev"
        IMAGE_TAG = "${BUILD_NUMBER}"
        IMAGE_URI = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {

        stage('Debug Info') {
            steps {
                sh '''
                echo "Running as user: $(whoami)"
                docker --version
                gcloud --version
                '''
            }
        }

        stage('Validate Env') {
            steps {
                sh '''
                echo "PROJECT_ID=$PROJECT_ID"
                echo "REGION=$REGION"
                echo "REPO=$REPO"
                echo "IMAGE_URI=$IMAGE_URI"
                '''
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
                # Initialize buildx
                docker buildx create --name mybuilder --use || true
                docker buildx inspect --bootstrap

                # Build and push image
                docker buildx build \
                  --platform linux/amd64 \
                  -t ${IMAGE_URI} \
                  --push .
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Image successfully pushed: ${IMAGE_URI}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
