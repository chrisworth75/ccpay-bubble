// Jenkinsfile for ccpay-bubble local deployment
pipeline {
    agent any

    environment {
        REGISTRY = 'localhost:5000'
        IMAGE_NAME = 'ccpay-bubble'
        NODE_ENV = 'local'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'echo "Checked out ccpay-bubble successfully"'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def image = docker.build("${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}")
                    docker.withRegistry("http://${REGISTRY}") {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'local'
            }
            steps {
                script {
                    // Stop existing container if running
                    sh """
                        docker stop ${IMAGE_NAME} || true
                        docker rm ${IMAGE_NAME} || true
                    """

                    // Run new container on port 3000
                    sh """
                        docker run -d \\
                        --name ${IMAGE_NAME} \\
                        --restart unless-stopped \\
                        -p 3000:3000 \\
                        -e NODE_ENV=local \\
                        ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Health Check') {
            when {
                branch 'local'
            }
            steps {
                script {
                    sleep 15 // Wait for container to start
                    sh '''
                        echo "🔄 Waiting for ccpay-bubble to be ready..."
                        timeout=60
                        while [ $timeout -gt 0 ]; do
                            health_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health/liveness || echo "000")

                            if [ "$health_status" = "200" ]; then
                                echo "✅ ccpay-bubble is ready"
                                break
                            fi

                            echo "⏳ Health status: $health_status - waiting..."
                            sleep 2
                            timeout=$((timeout-2))
                        done

                        if [ $timeout -le 0 ]; then
                            echo "❌ Service failed to start within timeout"
                            docker logs ${IMAGE_NAME}
                            exit 1
                        fi
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ ccpay-bubble pipeline completed successfully!'
            echo '📍 Application available at http://localhost:3000'
        }
        failure {
            echo '❌ ccpay-bubble pipeline failed!'
            sh 'docker logs ${IMAGE_NAME} || true'
        }
    }
}
