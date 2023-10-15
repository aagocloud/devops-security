pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archiveArtifacts 'target/*.jar' //so that they can be downloaded later
            }
      }
      stage('Running Unit Tests - JUnit and Jacoco') {
            steps {
              sh "mvn test"
            }
            post{
              always{
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
      }
      stage('Build and Push to DockerHub') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t pubudusenadeera/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push pubudusenadeera/numeric-app:""$GIT_COMMIT""'
              }
            }
      }     
  }
}

