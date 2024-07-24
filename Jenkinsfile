pipeline {
    agent any

    environment {
        FLUTTER_HOME = "C:/dev/flutter"
        GIT_HOME = "C:/Program Files/Git/bin"
        PATH = "${FLUTTER_HOME}/bin;${GIT_HOME};${env.PATH}"
    }

    stages {
        stage('Check PATH') {
            steps {
                bat 'echo %PATH%'
                bat 'git --version' // Comando para verificar que Git está disponible
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Edriplx/UnitConnect.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                bat 'flutter pub get'
            }
        }

        stage('Run Tests') {
            steps {
                bat 'flutter test'
            }
        }

        stage('Build APK') {
            steps {
                bat 'flutter build apk'
            }
        }

        stage('Run App') {
            steps {
                bat 'flutter run'
            }
        }
    }
}
