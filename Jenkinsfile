def COLOR_MAP = [
    'FAILURE' : 'danger',
    'SUCCESS' : 'good',
    'STARTED' : 'warning'
]
pipeline {
    agent any
     environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "192.168.225.102"
        NEXUS_PORT = "8081"
        DOCKER_CREDENTIALS_ID = "nexus_login_credential"
        NEXUS_REPO_URL = "crelease.webapp.local:10141"
        IMAGE_TAG = "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}"
        NAME_BACKEND = 'registers-backend'
        NAME_FRONTEND = 'register-frontend'

    }
    stages {
        stage("Fetch Repository") {
            steps {
                echo 'Get code from a GitHub repository'
                git url: 'https://github.com/thiendn04/Registers_Docker.git', branch: 'main', credentialsId: 'jenkins-test'
                echo 'Fetch Repository Completed !'
            }
            post {
                always {
                    echo 'Slack Notifications.'
                    slackSend channel: '#registers-webapp',
                        color: '#FF0000',
                        message: "*STARTED:* Job ${env.JOB_NAME} build #${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
                }
            }
        }

        stage('Code Quality Check via SonarQube') {
            steps {
                script {
                def scannerHome = tool 'SONAR-5.1.3006';
                    withSonarQubeEnv("sonar-webapp") {
                    sh "${tool("SONAR-5.1.3006")}/bin/sonar-scanner \
                    -Dsonar.projectKey=Registers_Docker \
                    -Dsonar.sources=. \
                    -Dsonar.css.node=. \
                    -Dsonar.host.url=http://192.168.225.101:9000 \
                    -Dsonar.login=squ_57a5e4b1bd816a02d7144af6fb478ac8c8324bc7"
               }
            }
            timeout(time: 10, unit: 'MINUTES') {
              waitForQualityGate abortPipeline: true
           }
			}
		}

        stage('Build and Push Images') {
            steps {
                script {
                    // Login to Docker registry
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin $NEXUS_REPO_URL"
                    }
                    
                    // Build images using Docker Compose
                    sh 'docker compose build --parallel'
                    
                    // Tag and push Backend image
                    sh "docker tag ${NAME_BACKEND}:${IMAGE_TAG} ${NEXUS_REPO_URL}/${NAME_BACKEND}:${IMAGE_TAG}"
                    sh "docker push ${NEXUS_REPO_URL}/${NAME_BACKEND}:${IMAGE_TAG}"
                    
                    // Tag and push Frontend image
                    sh "docker tag ${NAME_FRONTEND}:${IMAGE_TAG} ${NEXUS_REPO_URL}/${NAME_FRONTEND}:${IMAGE_TAG}"
                    sh "docker push ${NEXUS_REPO_URL}/${NAME_FRONTEND}:${IMAGE_TAG}"
                }
            }
        }
        // stage('Build and push images to Docker Hub'){
        //     steps {
        //         script {
        //             env.IMAGE_TAG = DOCKER_TAG
        //             sh "
        //             && IMAGE_TAG=${IMAGE_TAG} \
        //             && NAME_BACKEND=${NAME_BACKEND} \
        //             && NAME_FRONTEND=${NAME_FRONTEND} \
        //             && docker compose build --parallel \
        //             && docker tag ${NAME_BACKEND}:$DOCKER_TAG ${DOCKER_HUB}/${NAME_BACKEND}:$DOCKER_TAG \
        //             && docker tag ${NAME_FRONTEND}:$DOCKER_TAG ${DOCKER_HUB}/${NAME_FRONTEND}:$DOCKER_TAG \
        //             && echo 
        //             && docker push ${DOCKER_HUB}/${NAME_BACKEND}:$DOCKER_TAG \
        //             && docker push ${DOCKER_HUB}/${NAME_FRONTEND}:$DOCKER_TAG \
        //             && docker rmi ${DOCKER_HUB}/${NAME_BACKEND}:$DOCKER_TAG \
        //             && docker rmi ${DOCKER_HUB}/${NAME_FRONTEND}:$DOCKER_TAG"
        //         }
        //     }
        // }

		stage('Deploy to Staging-Ansible'){
		    steps {
		        script {
                    // Tạo thư mục
                    sh 'mkdir -p inventories'

					// Tạo thư mục con staging
                    sh 'mkdir -p inventories/staging'

					// Tạo thư mục con prod
                    sh 'mkdir -p inventories/prod'

                    // Tạo tệp tin host và ghi nội dung trong thư mục staging
                    def stag = '''
                        web01 ansible_host=192.168.225.110
                        db01 ansible_host=192.168.225.111

                        [stagingsrvgrp]
                        web01

                        [dbsrvgrp]
                        db01
                    '''.stripIndent()
                    // xóa khoản trắng đầu dòng vẫn giữ khoản trắng giữa các dòng
                    def trimmedStag = sh(script: "echo '${stag}' | sed -e 's/^[[:space:]]*//'", returnStdout: true).trim()

                    sh """
                        echo '${trimmedStag}' > inventories/staging/hosts
                    """

                    // Tạo tệp tin host và ghi nội dung trong thư mục prod
                    def pro = '''
                        web02 ansible_host=192.168.225.112

                        [appsrvgrp]
                        web02
                    '''.stripIndent()

                    // xóa khoản trắng đầu dòng vẫn giữ khoản trắng giữa các dòng
                    def trimmedPro = sh(script: "echo '${pro}' | sed -e 's/^[[:space:]]*//'", returnStdout: true).trim()

                    sh """
                        echo '${trimmedPro}' > inventories/prod/hosts
                    """
                    //Lấy username password Nexus từ Jenkins Credential
                    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'nexus_login_credential', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS']]){
                        ansiblePlaybook(
                            credentialsId: 'weblab-staging-ssh-login',
                            disableHostKeyChecking: true,
                            colorized: true,
                            inventory: 'inventories/staging/hosts',
                            playbook: 'ansible/site.yml',
                            extraVars: [
                                USER: "${NEXUS_USER}",
                                PASS: "${NEXUS_PASS}",
                                IMAGE_TAG: "${IMAGE_TAG}",
                                NEXUS_PORT: "${NEXUS_PORT}",
                                NAME_BACKEND: "${NAME_BACKEND}",
                                NAME_FRONTEND: "${NAME_FRONTEND}",
                                NEXUS_URL: "${NEXUS_REPO_URL}"
                                // IMAGENAME: "${imageName}",
                                // TAG: "${TAG}",
                                // CONTAINER_NAME: "Registers",
                                // IMAGE_NAME: "${imageName}"
                                //reponame: "${NEXUS_REPOSITORY}",
                                //artifactname: "${ARTIFACT_NAME}",
                                //hyphen: "$HYPHEN",
                                //registers_version: "${ARTIFACT_NAME}-${VERSION}-${env.BUILD_ID}-${env.BUILD_TIMESTAMP}.${ARTIFACT_EXTENSION}"
                            ],
                        )
                    }
		        }
		    }
		}
	}
    post {
        always {
            cleanWs deleteDirs: true
            echo 'Slack Notifications.'
            slackSend channel: '#registers-webapp',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build #${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}

