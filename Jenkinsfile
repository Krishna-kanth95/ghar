pipeline {
    agent { lable 'linux' }

    stages {
        stage ('Check version') {
            steps {
                sh "cd /usr/bin/jenkins && java -jar jenkins.war –version"
            }
        }
    }
}
