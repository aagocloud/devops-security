pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName  = "devsecops-container"
    serviceName    = "devsecops-svc"
    imageName      = "pubudusenadeera/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://localhost:32098"
    applicationURI = "/increment/99"
  }

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
      }
      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
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
      stage("Vulnetability Scan - Docker"){
        steps{
          parallel(
            "Trivy Scan":{
             sh "./trivy-docker-image-scan.sh"
            },
            "OPA conftest":{
              sh './opa-conftest.sh'
            }
          )
          }
      }
      /*
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
      */
      stage('Build and Push to DockerHub') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t pubudusenadeera/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push pubudusenadeera/numeric-app:""$GIT_COMMIT""'
              }
            }
      }
      stage("Vulnetability Scan - Kubernetes"){
        steps{
          parallel(
            "OPA Scan":{
             sh "./opa-kube-conftest.sh"
            },
            "KubeSec Scan":{
              sh './kubesec-scan.sh'
            }
          )
          }
      }

      stage('Deploy to Kubernetes Cluster') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']){
                sh "./k8s-deployment.sh"
              }
            }
      }

      stage('Verify Deployment to Kubernetes Cluster') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']){
                sh "./k8s-deployment-rollout-status.sh"
              }
            }
      }


  }
  post { 
        always { 
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
        /*
        success{

        }
        failure{

        }
        */    
    }
}

