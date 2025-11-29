pipeline {
    agent any

    triggers {
        // Poll SCM every 2 minutes as fallback if webhook fails
        pollSCM('H/2 * * * *')
    }

    parameters {
        booleanParam(
            name: 'CLEAN_VOLUMES',
            defaultValue: true,
            description: 'Remove volumes (clears database)'
        )
        string(
            name: 'API_HOST',
            defaultValue: 'http://72.60.236.166:3001',
            description: 'API host URL for frontend to connect to.'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "🏎️ Checking out code..."
                    checkout scm
                    env.GIT_COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    echo "Build: ${env.BUILD_NUMBER}, Commit: ${env.GIT_COMMIT_SHORT}"
                }
            }
        }

        stage('Validate') {
            steps {
                echo "🔧 Validating Docker Compose configuration..."
                sh 'docker compose config'
            }
        }

        stage('Prepare Environment') {
            steps {
                script {
                    echo "⚙️ Preparing environment configuration..."
                    withCredentials([
                        string(credentialsId: 'MYSQL_ROOT_PASSWORD', variable: 'MYSQL_ROOT_PASS'),
                        string(credentialsId: 'MYSQL_PASSWORD', variable: 'MYSQL_PASS')
                    ]) {
                        writeFile file: '.env', text: """\
MYSQL_ROOT_PASSWORD=${env.MYSQL_ROOT_PASS}
MYSQL_DATABASE=attractions_db
MYSQL_USER=attractions_user
MYSQL_PASSWORD=${env.MYSQL_PASS}
MYSQL_PORT=3306
PHPMYADMIN_PORT=8888
API_PORT=3001
DB_PORT=3306
FRONTEND_PORT=3000
NODE_ENV=production
API_HOST=${params.API_HOST}
""".stripIndent()
                        echo ".env file created successfully"
                    }
                }
            }
        }

        stage('Deploy Services') {
            parallel {
                stage('Deploy API') {
                    steps {
                        script {
                            echo "🚀 Deploying API service..."
                            sh """
                                docker compose build --no-cache api
                                docker compose up -d api
                            """
                        }
                    }
                }

                stage('Deploy Frontend') {
                    steps {
                        script {
                            echo "🚀 Deploying Frontend service..."
                            sh """
                                docker compose build --no-cache frontend
                                docker compose up -d frontend
                            """
                        }
                    }
                }
            }
        }

        stage('Database & phpMyAdmin') {
            steps {
                script {
                    echo "🛠️ Ensuring MySQL and phpMyAdmin are up..."
                    sh 'docker compose up -d mysql phpmyadmin'
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "🔎 Performing health checks..."
                    // Wait a few seconds for services to start
                    sh 'sleep 15'

                    // Check each service
                    def services = [
                        [name: 'API', url: 'http://localhost:3001/health'],
                        [name: 'Frontend', url: 'http://localhost:3000'],
                        [name: 'phpMyAdmin', url: 'http://localhost:8888']
                    ]

                    services.each { s ->
                        echo "Checking ${s.name}..."
                        retry(5) {
                            sh "curl -f ${s.url} || (echo '${s.name} not ready, retrying...' && exit 1)"
                        }
                        echo "${s.name} is ✅"
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "📋 Verifying container status and logs..."
                    sh """
                        docker compose ps
                        echo ""
                        echo "=== Last 20 logs ==="
                        docker compose logs --tail=20
                        echo ""
                        echo "Frontend: http://localhost:3000"
                        echo "API: http://localhost:3001"
                        echo "phpMyAdmin: http://localhost:8888"
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🏁 Deployment completed successfully!"
            echo "Build: ${env.BUILD_NUMBER}"
            echo "Commit: ${env.GIT_COMMIT_SHORT}"
        }
        failure {
            echo "❌ Deployment failed!"
            sh 'docker compose logs --tail=50 || true'
        }
        always {
            echo "🧹 Cleaning up Docker resources..."
            sh """
                docker image prune -f
                docker container prune -f
                ${params.CLEAN_VOLUMES ? 'docker volume prune -f' : ''}
            """
        }
    }
}
