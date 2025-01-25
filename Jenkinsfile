node {
    def dockerImage = docker.image('maven:3.9.2')

    dockerImage.pull()
    dockerImage.inside {
        stage('Checkout Code') {
            checkout scm
        }

        stage('Build') {
            sh 'mvn -B -DskipTests -Dmaven.repo.local=$WORKSPACE/.m2/repository clean package'
        }

        stage('Test') {
            sh 'mvn -Dmaven.repo.local=$WORKSPACE/.m2/repository test'
            junit 'target/surefire-reports/*.xml'
        }

    }
}
