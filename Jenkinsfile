pipeline {
    agent any

    environment {
        FLUTTER_HOME = "C:/dev/flutter" // Reemplaza con la ruta correcta al SDK de Flutter
        GIT_HOME = "C:/Program Files/Git/bin" // Ruta a Git según tu captura de pantalla
        PATH = "${FLUTTER_HOME}/bin;${GIT_HOME};${env.PATH}"
    }

    stages {
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
                bat 'flutter run' // Elimina "--no-sound-null-safety" si no es necesario
            }
        }
    }
}
