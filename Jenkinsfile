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
		HYPHEN = "-"
		VERSION = "1.0.0"
        imageName = "webappdocker"
        dockerImage = ''
        registryCredentials = "nexus_login_credential"
        registry = "crelease.webapp.local:10141"
        TAG = "${VERSION}-${env.BUILD_ID}-${env.BUILD_TIMESTAMP}"

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
        stage('Building image') {
            steps{
                script {
                    dockerImage = docker.build imageName
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
        // Uploading Docker images into Nexus Registry
        stage('Uploading to Nexus') {
            steps{  
                script {
                    docker.withRegistry( 'https://'+registry, registryCredentials ) {
                    dockerImage.push("${TAG}")
                    }
                }
            }
        }                
	
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
                                IMAGE_TAG: "${TAG}"
                                NEXUS_URL: "${NEXUS_URL}"
                                NEXUS_PORT: "${NEXUS_PORT}"
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
            //cleanWs deleteDirs: true
            echo 'Slack Notifications.'
            slackSend channel: '#registers-webapp',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build #${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"            
        }
    } 
}

