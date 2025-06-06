pipeline {
    agent {
        docker {
            image 'python:3'
        }
    }
    environment {
        PIP_DISABLE_PIP_VERSION_CHECK = '1'
        PYTHONUNBUFFERED = '1'
    }
    stages {
        stage('Preparar') {
            steps {
                sh 'apt-get update && apt-get install -y python3-venv'
                sh 'python3 -m venv venv'
                sh './venv/bin/python3 -m pip install -r requirements.txt'
            }
        }
        stage('Test') {
            steps {
                sh './venv/bin/python3 manage.py test'
            }
        }
    }
}
