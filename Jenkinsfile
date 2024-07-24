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
                bat 'git --version'
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Edriplx/UnitConnect.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                bat '''
                set PATH=C:\\dev\\flutter\\bin;C:\\Program Files\\Git\\bin;%PATH%
                flutter pub get
                '''
            }
        }

        stage('Run Tests') {
            steps {
                bat '''
                set PATH=C:\\dev\\flutter\\bin;C:\\Program Files\\Git\\bin;%PATH%
                flutter test
                '''
            }
        }

        stage('Build APK') {
            steps {
                bat '''
                set PATH=C:\\dev\\flutter\\bin;C:\\Program Files\\Git\\bin;%PATH%
                flutter build apk
                '''
            }
        }

        stage('Run App') {
            steps {
                bat '''
                set PATH=C:\\dev\\flutter\\bin;C:\\Program Files\\Git\\bin;%PATH%
                flutter run
                '''
            }
        }
    }
}
