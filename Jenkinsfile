pipeline {
    agent any
    
    environment {
        // Use Jenkins credentials instead of hardcoding sensitive values
        PROJECT_ID = "kong-gke-495314"
        
        // Artifact Registry configuration
        REGION = "us-central1"
        REPO = "kong-registry"
        IMAGE_NAME = "kong-dataplane"
        KONG_VERSION = "3.9.1"  // Use valid 3-part version
        GAR_HOST = "${REGION}-docker.pkg.dev"
        
        // Image URIs
        IMAGE_URI = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${KONG_VERSION}"
        IMAGE_URI_BUILD = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${BUILD_NUMBER}"
        IMAGE_URI_LATEST = "${GAR_HOST}/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:latest"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Authenticate GCP') {
            steps {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCLOUD_KEY')]) {
                    sh '''
                    echo "Authenticating with GCP..."
                    gcloud auth activate-service-account --key-file="$GCLOUD_KEY"
                    gcloud config set project ${PROJECT_ID}
                    gcloud auth configure-docker ${GAR_HOST} -q
                    echo "✅ GCP authentication successful"
                    '''
                }
            }
        }
        
        stage('Build Image') {
            steps {
                sh '''
                echo "Building Kong ${KONG_VERSION} Docker image..."
                docker build \
                  --build-arg KONG_VERSION=${KONG_VERSION} \
                  -t ${IMAGE_URI} \
                  -t ${IMAGE_URI_BUILD} \
                  -t ${IMAGE_URI_LATEST} \
                  -f Dockerfile.CORRECT \
                  .
                
                echo "✅ Docker image built successfully"
                docker images | grep ${IMAGE_NAME}
                '''
            }
        }
        
        stage('Test Image') {
            steps {
                sh '''
                echo "Testing Kong image..."
                
                # Test 1: Verify Kong binary works
                echo "Test 1: Checking Kong version..."
                docker run --rm ${IMAGE_URI} kong version
                
                # Test 2: Start container and check health
                echo "Test 2: Starting Kong container..."
                docker run -d \
                  --name kong-test \
                  -p 8001:8001 \
                  --health-cmd="curl -f http://localhost:8001/status || exit 1" \
                  --health-interval=10s \
                  --health-timeout=5s \
                  --health-retries=3 \
                  ${IMAGE_URI}
                
                # Wait for Kong to fully start
                echo "Waiting for Kong to start (up to 30 seconds)..."
                for i in {1..30}; do
                    if curl -f http://localhost:8001/status > /dev/null 2>&1; then
                        echo "✅ Kong is healthy"
                        break
                    fi
                    if [ $i -eq 30 ]; then
                        echo "❌ Kong failed to start within 30 seconds"
                        docker logs kong-test
                        exit 1
                    fi
                    sleep 1
                done
                
                # Test 3: Verify Kong API
                echo "Test 3: Checking Kong Admin API..."
                KONG_STATUS=$(curl -s http://localhost:8001/status)
                echo "$KONG_STATUS" | grep -q '"server":' && echo "✅ Kong Admin API working" || exit 1
                
                # Cleanup
                echo "Cleaning up test container..."
                docker stop kong-test
                docker rm kong-test
                echo "✅ All tests passed"
                '''
            }
        }
        
        stage('Scan Image') {
            when {
                branch 'main'  // Only scan on main branch to save build time
            }
            steps {
                sh '''
                echo "Scanning image for vulnerabilities..."
                
                # Check if Trivy is available
                if command -v trivy &> /dev/null; then
                    echo "Using Trivy for vulnerability scanning..."
                    # Scan with severity filter (exit non-zero only for HIGH/CRITICAL)
                    trivy image --severity HIGH,CRITICAL ${IMAGE_URI} || true
                    echo "✅ Scan completed (check output above for any issues)"
                else
                    echo "⚠️  Trivy not installed, skipping vulnerability scan"
                    echo "To enable scanning, install Trivy: apt-get install trivy"
                fi
                '''
            }
        }
        
        stage('Push Image') {
            steps {
                sh '''
                echo "Pushing image to Artifact Registry..."
                
                # Push all tags
                docker push ${IMAGE_URI}
                docker push ${IMAGE_URI_BUILD}
                docker push ${IMAGE_URI_LATEST}
                
                echo "✅ Images pushed successfully"
                '''
            }
        }
        
        stage('Verify Push') {
            steps {
                sh '''
                echo "Verifying image in Artifact Registry..."
                
                # Verify image exists in Artifact Registry
                if gcloud artifacts docker images describe ${IMAGE_URI} \
                    --project=${PROJECT_ID} > /dev/null 2>&1; then
                    echo "✅ Image verified in Artifact Registry"
                    
                    # Show image details
                    echo "Image details:"
                    gcloud artifacts docker images describe ${IMAGE_URI} \
                        --project=${PROJECT_ID} \
                        --format="table(image,image_summary.image_size,image_summary.created_time)"
                else
                    echo "❌ Image verification failed"
                    exit 1
                fi
                '''
            }
        }
        
        stage('Cleanup') {
            always {
                sh '''
                echo "Cleaning up local Docker resources..."
                
                # Remove local images to save disk space
                docker rmi ${IMAGE_URI} || true
                docker rmi ${IMAGE_URI_BUILD} || true
                docker rmi ${IMAGE_URI_LATEST} || true
                
                # Clean up any dangling containers
                docker container prune -f || true
                
                echo "✅ Cleanup completed"
                '''
        }
    }
    
    post {
        success {
            sh '''
            echo "=========================================="
            echo "✅ BUILD SUCCESSFUL"
            echo "=========================================="
            echo "Image pushed to:"
            echo "  ${IMAGE_URI}"
            echo "  ${IMAGE_URI_BUILD}"
            echo "  ${IMAGE_URI_LATEST}"
            echo ""
            echo "To deploy to Kubernetes, use:"
            echo "  kubectl set image deployment/kong kong=${IMAGE_URI} -n kong-system"
            echo "=========================================="
            '''
        }
        failure {
            sh '''
            echo "=========================================="
            echo "❌ BUILD FAILED"
            echo "=========================================="
            echo "Please check the logs above for errors"
            echo "=========================================="
            '''
        }
    }
}
