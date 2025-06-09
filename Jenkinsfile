pipeline {
    environment {
        IMAGEN = "aleromero10/jenkins"
        LOGIN = 'USER_DOCKERHUB' // Jenkins credential ID con usuario y token de DockerHub
    }

    agent none

    stages {
        stage("Desarrollo") {
            agent {
                docker {
                    image "python:3"
                    args '-u root:root'
                }
            }
            stages {
                stage('Clone') {
                    steps {
                        git branch: 'master', url: 'https://github.com/AlexRomero10/django_tutorial.git'
                    }
                }
                stage('Install') {
                    steps {
                        sh 'pip install -r requirements.txt'
                    }
                }
                stage('Test') {
                    steps {
                        sh 'python3 manage.py test'
                    }
                }
            }
        }

        stage("Construccion y despliegue") {
            agent { label 'master' } // Asegúrate que Jenkins master tenga Docker instalado
            stages {
                stage('Clone en anfitrión') {
                    steps {
                        git branch: 'master', url: 'https://github.com/AlexRomero10/django_tutorial.git'
                    }
                }

                stage('Construir imagen Docker') {
                    steps {
                        script {
                            dockerImage = docker.build("${IMAGEN}:latest")
                        }
                    }
                }

                stage('Subir a DockerHub') {
                    steps {
                        script {
                            docker.withRegistry('', LOGIN) {
                                dockerImage.push()
                            }
                        }
                    }
                }

                stage('Eliminar imagen local') {
                    steps {
                        sh "docker rmi ${IMAGEN}:latest"
                    }
                }

                stage('Desplegar remotamente') {
                    steps {
                        sshagent(credentials: ['SSH_ROOT']) {
                            sh '''
                                ssh -o StrictHostKeyChecking=no root@217.160.22.156 "wget -O docker-compose.yaml https://raw.githubusercontent.com/AlexRomero10/django_tutorial/master/docker-compose.yaml"
                                ssh -o StrictHostKeyChecking=no root@217.160.22.156 "docker-compose pull && docker-compose up -d --force-recreate"
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            mail to: 'aletromp00@gmail.com',
                 subject: "Estado del pipeline: ${currentBuild.fullDisplayName}",
                 body: "El pipeline terminó con resultado: ${currentBuild.result}\n\nDetalles: ${env.BUILD_URL}"
        }
    }
}
