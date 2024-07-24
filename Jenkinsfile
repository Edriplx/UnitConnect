pipeline {
    agent any

    environment {
        FLUTTER_HOME = "C:/dev/flutter"
        GIT_HOME = "C:/Program Files/Git/bin"
        PATH = "${FLUTTER_HOME}/bin;${GIT_HOME};${env.PATH}"
        // Variable específica para Git (importante para Flutter en Windows)
        GIT_PYTHON_GIT_EXECUTABLE = "${GIT_HOME}/git.exe"
    }

    stages {
        stage('Check PATH') {
            steps {
                // Mostrar el PATH actual para depuración
                bat 'echo %PATH%'
                // Verificar que Git esté accesible
                bat 'git --version'
            }
        }

        stage('Clone Repository') {
            steps {
                // Clonar el repositorio
                git branch: 'main', url: 'https://github.com/Edriplx/UnitConnect.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Instalar dependencias de Flutter
                bat 'flutter pub get'
            }
        }

        stage('Run Tests') {
            steps {
                // Ejecutar las pruebas de Flutter
                bat 'flutter test'
            }
        }

        stage('Build APK') {
            steps {
                // Construir el APK de Flutter
                bat 'flutter build apk'
            }
        }

        stage('Run App') {
            steps {
                // Este paso probablemente no se ejecutará en Jenkins directamente
                // ya que requiere un emulador o dispositivo conectado
                bat 'flutter run' 
            }
        }
    }
}
