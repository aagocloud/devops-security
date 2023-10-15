pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              withMaven{
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
              }  
            }
        }   
    }
}
