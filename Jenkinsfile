pipeline {
    environment {
        IMAGEN = "aleromero10/jenkins"
        USUARIO = 'USER_DOCKERHUB'
    }
    agent none
    stages {
        stage("test the project") {
            agent {
                docker {
                image "python:3"
                args '-u root:root'
                }
            }
            stages {
                stage('Clone') {
                    steps {
                        git branch:'main',url:'https://github.com/AlexRomero10/django_tutorial.git'
                    }
                }
                stage('Install') {
                    steps {
                        sh 'pip install -r requirements.txt'
                    }
                }
                stage('Test')
                {
                    steps {
                        sh 'python3 manage.py test --settings=django_tutorial.settings_desarrollo'
                    }
                }
            }
        }
        stage('Creación de la imagen') {
            agent any
            stages {
                stage('Build') {
                    steps {
                        script {
                            newApp = docker.build "$IMAGEN:$BUILD_NUMBER"
                        }
                    }
                }
                stage('Deploy') {
                    steps {
                        script {
                            docker.withRegistry( '', USUARIO ) {
                                newApp.push()
                                newApp.push("latest")
                            }
                        }
                    }
                }
                stage('Clean Up') {
                    steps {
                        sh "docker rmi $IMAGEN:$BUILD_NUMBER"
                        }
                }
            }
        }
        stage ('Despliegue') {
            agent any
            stages {
                stage ('Despliegue django_tutorial'){
                    steps{
                        sshagent(credentials : ['SSH_KEY']) {
                        sh 'ssh -o StrictHostKeyChecking=no alejandro@art "cd django_tutorial && git pull && docker-compose down && docker pull aleromero10/djangotutorial:latest && docker-compose up -d"'
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
        body: "El despliegue ${env.BUILD_URL} ha tenido como resultado: ${currentBuild.result}"
        }
    }
}
