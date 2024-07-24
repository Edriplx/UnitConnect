pipeline {
    agent any

    environment {
        FLUTTER_HOME = "C:/dev/flutter" // Reemplaza con la ruta correcta al SDK de Flutter
        PATH = "${FLUTTER_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Edriplx/UnitConnect.git' // Asegúrate de especificar la rama correcta
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
                sh 'flutter run' // Elimina "--no-sound-null-safety" si no es necesario
            }
        }
    }
}
