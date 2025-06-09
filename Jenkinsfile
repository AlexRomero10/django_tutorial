pipeline {
    agent none

    environment {
        IMAGEN = "aleromero10/jenkins"
        LOGIN = 'USER_DOCKERHUB'     // Credencial tipo: username/password
        REMOTE_HOST = '217.160.22.156'
        COMPOSE_URL = 'https://raw.githubusercontent.com/AlexRomero10/django_tutorial/master/docker-compose.yaml'
    }

    stages {

        stage('Desarrollo') {
            agent {
                docker {
                    image 'python:3'
                    args '-u root:root'
                }
            }
            stages {
                stage('Clonar Repo') {
                    steps {
                        git branch: 'master', url: 'https://github.com/AlexRomero10/django_tutorial.git'
                    }
                }

                stage('Instalar Dependencias') {
                    steps {
                        sh 'pip install -r requirements.txt'
                    }
                }

                stage('Lint (opcional)') {
                    steps {
                        sh 'pip install flake8 && flake8 . || true'
                    }
                }

                stage('Ejecutar Tests') {
                    steps {
                        sh 'python3 manage.py test'
                    }
                }
            }
        }

        stage('Construcción y Despliegue') {
            agent any

            when {
                expression {
                    return currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }

            stages {
                stage('Clonar en Host') {
                    steps {
                        git branch: 'master', url: 'https://github.com/AlexRomero10/django_tutorial.git'
                    }
                }

                stage('Build Docker Image') {
                    steps {
                        script {
                            def newApp = docker.build("${IMAGEN}:latest")
                            env.NEW_IMAGE_BUILT = "true"
                        }
                    }
                }

                stage('Subir Imagen a DockerHub') {
                    when {
                        expression { return env.NEW_IMAGE_BUILT == "true" }
                    }
                    steps {
                        script {
                            docker.withRegistry('', LOGIN) {
                                docker.image("${IMAGEN}:latest").push()
                            }
                        }
                    }
                }

                stage('Eliminar Imagen Local') {
                    steps {
                        sh "docker rmi ${IMAGEN}:latest || true"
                    }
                }

                stage('Desplegar via SSH') {
                    steps {
                        sshagent(credentials: ['SSH_ROOT']) {
                            sh """
                                ssh -o StrictHostKeyChecking=no root@${REMOTE_HOST} "wget ${COMPOSE_URL} -O docker-compose.yaml"
                                ssh -o StrictHostKeyChecking=no root@${REMOTE_HOST} "docker-compose up -d --force-recreate"
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            mail to: 'aletromp00@gmail.com',
                 subject: "Resultado del pipeline: ${currentBuild.fullDisplayName}",
                 body: "${env.BUILD_URL} terminó con estado: ${currentBuild.result}"
        }
    }
}
