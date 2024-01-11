pipeline {
    agent any

    environment {
        MAJOR = '1'
        MINOR = '1'
        UIPATH_CLI_PATH = 'https://uipath.visualstudio.com/Public.Feeds/_artifacts/feed/UiPath-Official/NuGet/UiPath.CLI.Windows/overview/23.10.8753.32995'
        UIPATH_ORCH_URL = "https://cloud.uipath.com/"
        UIPATH_ORCH_LOGICAL_NAME = "emindqzrkobt"
        UIPATH_ORCH_TENANT_NAME = "DefaultTenant"
        UIPATH_ORCH_FOLDER_NAME = "CI-CD"
    }

    stages {
        stage('Preparing') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Build Process') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                echo "Building package with ${WORKSPACE}"
                bat "${UIPATH_CLI_PATH}uipack.exe project.json --output \"Output\\${env.BUILD_NUMBER}\" --version ${MAJOR}.${MINOR}.${env.BUILD_NUMBER} --traceLevel None"
            }
        }

        stage('Deploy Process') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                echo 'Deploying process to orchestrator...'
                bat "${UIPATH_CLI_PATH}uipublish.exe -i \"Output\\${env.BUILD_NUMBER}\\YourPackageName.nupkg\" --orchestratorUrl ${UIPATH_ORCH_URL} --folderName ${UIPATH_ORCH_FOLDER_NAME} --tenant ${UIPATH_ORCH_TENANT_NAME} --entryPointPaths 'Main.xaml' --apiKey 'YourApiKey'"
                // Add any additional deployment steps or notifications as needed
            }
        }
    }

    options {
        timeout(time: 80, unit: 'MINUTES')
        skipDefaultCheckout()
    }

    post {
        success {
            echo 'Deployment has been completed!'
        }
        failure {
            echo "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.JOB_DISPLAY_URL})"
        }
        always {
            cleanWs()
        }
    }
}
