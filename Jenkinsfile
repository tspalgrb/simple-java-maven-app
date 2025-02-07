node {
    def awsInstanceIP = env.AWS_EC2_IP
    def appName = env.APP_NAME
    def dockerImagePush = "${env.DOCKER_HUB_USERNAME}/${appName}:latest"
    def dockerImage = docker.image('maven:3.9.2-amazoncorretto-17')

    dockerImage.pull()
    dockerImage.inside {

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
        }
        
        stage('Manual Approval'){
            input message: 'Lanjutkan ke tahap Deploy? (Klik "Proceed" untuk melanjutkan ke tahap Deploy)'
        }

        stage('Deploy') {
            echo 'Deploying application...'
            sh './jenkins/scripts/deliver.sh'
            echo 'Waiting for 60 seconds...'
            sleep(60)
            input message: 'Lanjutkan ke tahap Deploy to AWS EC2? (Klik "Proceed" untuk melanjutkan ke tahap Deploy to AWS EC2)'
        }

    }

    stage('Build & Push Docker Image') {
        echo 'Building docker image...' 
        sh "docker build -t ${dockerImagePush} ."
        echo 'Push docker image to docker hub...' 
        withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh """
            echo ${env.DOCKER_PASSWORD} | docker login -u ${env.DOCKER_USER} --password-stdin
            docker push ${dockerImagePush}
            """
        } 
    }

    stage('Deploy to AWS EC2') {
        sshagent(['ec2-ssh-key']) {
            sh """
                ssh -o StrictHostKeyChecking=no -i ${env.SSH_KEY_PATH} ${env.SSH_USER}@${awsInstanceIP} \"
                docker pull ${dockerImagePush}
                docker stop ${appName} || true
                docker rm -f ${appName} || true
                docker run -d --name ${appName} ${dockerImagePush}
                sleep 5
                docker logs ${appName}
                \"
            """
        sleep(60)
        }
    }

    stage('Cleanup') {
        echo "Cleaning up..."
        sh "docker logout"
    }    
}
