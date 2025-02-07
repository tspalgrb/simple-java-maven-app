node {
    def dockerImage = docker.image('maven:3.9.2-amazoncorretto-17')

    dockerImage.pull()
    dockerImage.inside {
        try {
            stage('Checkout Code') {
            echo 'Checkout scm...'
            checkout scm
            }

            stage('Build') {
                echo 'Installing dependencies...'
                sh 'mvn -B -DskipTests -Dmaven.repo.local=$WORKSPACE/.m2/repository clean package'
            }

            stage('Test') {
                echo 'Running tests...'
                sh 'mvn -Dmaven.repo.local=$WORKSPACE/.m2/repository test'
                junit 'target/surefire-reports/*.xml'
                input message: 'Lanjutkan ke tahap Deploy? (Klik "Proceed" untuk melanjutkan ke tahap Deploy)'
            }
            
            stage('Deploy') {
                echo 'Deploying application...'
                sh './jenkins/scripts/deliver.sh'
                echo 'Waiting for 60 seconds...'
                sleep(60)
            }
        } finally {
                echo 'Pipeline finished.'
        }
    }
}
