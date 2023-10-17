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
      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post{
              always{
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
      }
      stage("SonarQube - SAST"){
        steps{
          withSonarQubeEnv('SonarQube'){
             sh "mvn sonar:sonar \
                 -Dsonar.projectKey=numeric-application \
                 -Dsonar.host.url=http://localhost:9000"
          }
          timeout(time: 2, unit: 'MINUTES'){
            script{
              waitForQualityGate abortPipeline: true
            }
          }
        }
      }
      stage("Vulnetability Scan - Dependency-check"){
        steps{
             sh "mvn dependency-check:check"
          }
          post{
            always{
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            }
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
      stage('Deploy to Kubernetes Cluster') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']){
                sh "sed -i 's#replace#pubudusenadeera/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh 'kubectl apply -f k8s_deployment_service.yaml'
              }
            }
      }     
  }
}

