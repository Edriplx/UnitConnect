pipeline {
    agent any

    environment {
        FLUTTER_HOME = "C:/dev/flutter" }
        PATH = "${FLUTTER_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/Edriplx/UnitConnect.git' 
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'flutter test'
            }
        }

        stage('Build APK') {
            steps {
                sh 'flutter build apk'
            }
        }

        stage('Run App') {
            steps {
                sh 'flutter run' 
            }
        }
    }
}
