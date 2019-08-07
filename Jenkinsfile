pipeline {

  agent {
    label 'test-agent'
  }

  environment {
    PROJECT = "wannacrypt"
    ECRSHORTURL = '123456789.dkr.ecr.eu-west-1.amazonaws.com'
  }

  stages {    
    stage('CHECKOUT') {
      agent {
       label 'jenkins-slave'
      }
      steps {
        deleteDir()
        checkout scm
        script {
          gitCommitHash = "${GIT_COMMIT}"
          env.SHORT_GIT_COMMIT = gitCommitHash.take(7)
          env.BUILD_IMAGE = "${PROJECT}:$SHORT_GIT_COMMIT"
          echo "Short Commit Hash is ${SHORT_GIT_COMMIT}"
        }
      }
    }
    stage ('PreBuild') {
      steps {
        script {

          sh '''
            ###### Checking if ECR repo exists ######
            if aws ecr describe-repositories --repository-name ${PROJECT} --region ${AWS_REGION}
            then
              echo ECR repo ${PROJECT} already exists on AWS account
            else
              echo ECR repo ${PROJECT} not found, so creating...
              aws ecr create-repository --repository-name ${PROJECT} --region ${AWS_REGION}
            fi

            ###### Replacing common values in the template for all environments ######
            sed -e \"s~{{PROJECT}}~${PROJECT}~g\" \
              -e \"s~{{IMAGE_URL}}~$ECRSHORTURL/$BUILD_IMAGE~g\" -i manifest/nginx-test.yaml
          '''
        }
      }
    }
    stage ('Build') {
      steps {
        script {
          sh '''
            echo "Build started on `date`"

            ###### Logging into ECR ######
            set +x
            $(aws ecr get-login --no-include-email --region $AWS_REGION)
            set -x

            ###### Building ######
            docker build --build-arg PROJECT_NAME=${PROJECT_NAME} -t "${PROJECT_NAME}:${SOURCE_HASH}" .

            ###### Tagging Docker image for ECS ######
            docker tag "${PROJECT_NAME}:${SOURCE_HASH}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:${PROJECT_NAME}-${SOURCE_HASH}"
          '''

          // Pushing image to ECR, docker plugin should be installed to use the below command
          docker.withRegistry('https://${ECRSHORTURL}',) {
            docker.image("$BUILD_IMAGE").push()
          }

          currentBuild.description = "Build Git SHA = ${SHORT_GIT_COMMIT}"

          // Stashing the manifest  to be able to restart deployment from any deployment stage
          stash name: "k8s-template", includes: "manifest/"
        }
      }
    }
    stage ('DeployTest') {
      options {
        timeout(time: 15, unit: 'MINUTES')
      }
      environment {
        REPLICAS = '1'
        CPU_LIMIT = '256m'
        MEMORY_LIMIT = '256'
        CPU_REQUEST = '256m'
        MEMORY_REQUEST = '256Mi'
      }
      steps {
        unstash 'k8s-template'
        script {
          // Deploy Composer to dev
          kubeDeploy("${PROJECT}","deployment","nginx.yaml","${PROJECT}","image updated to ${BUILD_IMAGE}")

        }
      }
    }
  }
}




def kubeDeploy(app,type,manifest,namespace,deploy_comment) {
  withEnv(["app=${app}", "type=${type}", "manifest=${manifest}", "namespace=${namespace}", "deploy_comment=${deploy_comment}"]) {
    sh '''
      sed -e \"s~{{PROJECT}}~${PROJECT}~g\" \
        -e \"s~{{REPLICAS}}~${REPLICAS}~g\" \
        -e \"s~{{CPU-LIMIT}}~${CPU_LIMIT}~g\" \
        -e \"s~{{MEMORY-LIMIT}}~${MEMORY_LIMIT}~g\" \
        -e \"s~{{CPU-REQUEST}}~${CPU_REQUEST}~g\" \
        -e \"s~{{MEMORY-REQUEST}}~${MEMORY_REQUEST}~g\" cfn/templates/composer-k8s.yaml > composer_k8s_${STAGE}.yaml
    '''

    sh '''
    kubectl apply -f ${manafest} -n ${namespace}
    kubectl annotate ${type}/${app} -n ${namespace} kubernetes.io/change-cause=\"${deploy_comment}\"
    set +e
    timeout ${TIMEOUT_IN_SECS} kubectl rollout status ${type}/${app} -n ${namespace}
    RESULT=$?
    set -e
    if [ $RESULT != 0 ]; then
        if [ $RESULT = 124 ]; then
          echo 'Deployment timedout...'
          echo "Describe the ${type}.."
          kubectl describe ${type}/${app} -n ${namespace}
          echo "getting the pod details.."
          kubectl get pods -n ${namespace}
          echo "get current generation details.."
          GENERATION=`kubectl get ${type}/${app} -n ${namespace} -o "jsonpath={.metadata.generation}"`
          if [ $GENERATION != 1 ]; then
            echo "Previous generations found, rollback the current deployment..."
            kubectl rollout undo ${type}/${app} -n ${namespace}
          fi
          exit $RESULT
            fi
          echo 'Unable to retreive rollout status...'
          exit $RESULT
    fi
    '''
    }
}

