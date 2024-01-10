pipeline {
	    agent any
	

	        // Environment Variables
	        environment {
	        MAJOR = '1'
	        MINOR = '1'
	        //Orchestrator Services
	        UIPATH_ORCH_URL = "https://cloud.uipath.com/"
	        UIPATH_ORCH_LOGICAL_NAME = "anupaminc"
	        UIPATH_ORCH_TENANT_NAME = "Default"
	        UIPATH_ORCH_FOLDER_NAME = "CI-CD"
	    }
	

	    stages {
	

	        // Printing Basic Information
	        stage('Preparing'){
	            steps {
	                echo "Jenkins Home ${env.JENKINS_HOME}"
	                echo "Jenkins URL ${env.JENKINS_URL}"
	                echo "Jenkins JOB Number ${env.BUILD_NUMBER}"
	                echo "Jenkins JOB Name ${env.JOB_NAME}"
	                echo "GitHub BranchName ${env.BRANCH_NAME}"
	                checkout scm
	

	            }
	        }
	

	         // Building Tests
	        stage('Build Tests') {
	            steps {
	                echo "Building package with ${WORKSPACE}"
	                UiPathPack (
	                      outputPath: "Output\\Tests\${env.BUILD_NUMBER}",
						  outputType: 'Tests',
	                      projectJsonPath: "project.json",
	                      version: [$class: 'ManualVersionEntry', version: "${MAJOR}.${MINOR}.${env.BUILD_NUMBER}"],
	                      useOrchestrator: false,
						  traceLevel: 'None'
						)
	            }
	        }
			
	         // Deploy Stages
	        stage('Deploy Tests') {
	            steps {
	                echo "Deploying ${BRANCH_NAME} to orchestrator"
	                UiPathDeploy (
	                packagePath: "Output\\Tests\${env.BUILD_NUMBER}",
	                orchestratorAddress: "${UIPATH_ORCH_URL}",
	                orchestratorTenant: "${UIPATH_ORCH_TENANT_NAME}",
	                folderName: "${UIPATH_ORCH_FOLDER_NAME}",
	                environments: 'INT',
	                //credentials: [$class: 'UserPassAuthenticationEntry', credentialsId: 'APIUserKey']
	                credentials: Token(accountName: "${UIPATH_ORCH_LOGICAL_NAME}", credentialsId: 'APIUserKey'),
					traceLevel: 'None',
					entryPointPaths: 'Main.xaml'
	

					)
	            }
			
			}
			
			
	         // Test Stages
	        stage('Perform Tests') {
	            steps {
	               echo 'Testing the workflow...'
					UiPathTest (
					  testTarget: [$class: 'TestSetEntry', testSet: "AnnounceFavouriteSinger_Tests"],
					  orchestratorAddress: "${UIPATH_ORCH_URL}",
					  orchestratorTenant: "${UIPATH_ORCH_TENANT_NAME}",
					  folderName: "${UIPATH_ORCH_FOLDER_NAME}",
					  timeout: 10000,
					  traceLevel: 'None',
					  testResultsOutputPath: "result.xml",
					  //credentials: [$class: 'UserPassAuthenticationEntry', credentialsId: "credentialsId"]
					  credentials: Token(accountName: "${UIPATH_ORCH_LOGICAL_NAME}", credentialsId: 'APIUserKey'),
					  parametersFilePath: ''
					)
	            }
			}
				
	         // Building Package
	        stage('Build Process') {
				when {
					expression {
						currentBuild.result == null || currentBuild.result == 'SUCCESS'
						}
				}
				steps {
					echo "Building package with ${WORKSPACE}"
					UiPathPack (
						  outputPath: "Output\\${env.BUILD_NUMBER}",
						  projectJsonPath: "project.json",
						  version: [$class: 'ManualVersionEntry', version: "${MAJOR}.${MINOR}.${env.BUILD_NUMBER}"],
						  useOrchestrator: false,
						  traceLevel: 'None'
						)
					}
	        }			
			
	         // Deploy to Production Step
	        stage('Deploy Process') {
				when {
					expression {
						currentBuild.result == null || currentBuild.result == 'SUCCESS' 
						}
				}
				steps {
	                echo 'Deploying process to orchestrator...'
	                UiPathDeploy (
	                packagePath: "Output\\${env.BUILD_NUMBER}",
	                orchestratorAddress: "${UIPATH_ORCH_URL}",
	                orchestratorTenant: "${UIPATH_ORCH_TENANT_NAME}",
	                folderName: "${UIPATH_ORCH_FOLDER_NAME}",
	                environments: 'INT',
	                //credentials: [$class: 'UserPassAuthenticationEntry', credentialsId: 'APIUserKey']
	                credentials: Token(accountName: "${UIPATH_ORCH_LOGICAL_NAME}", credentialsId: 'APIUserKey'),
					traceLevel: 'None',
					entryPointPaths: 'Main.xaml'
					)
				}   
			}	
		
	    }
	

	    // Options
	    options {
	        // Timeout for pipeline
	        timeout(time:80, unit:'MINUTES')
	        skipDefaultCheckout()
	    }
	

	

	    // 
	    post {
	        success {
	            echo 'Deployment has been completed!'
	        }
	        failure {
	          echo "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.JOB_DISPLAY_URL})"
	        }
	        always {
	            /* Clean workspace if success */
	            cleanWs()
	        }
	    }
	
	}
