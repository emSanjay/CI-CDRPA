pipeline {
    agent any

    environment {
        PACKAGE_VERSION = '1.0.0'
        ORCHESTRATOR_URL = 'https://cloud.uipath.com/'
        ORCHESTRATOR_TENANT = 'DefaultTenant'
        ORCHESTRATOR_API_KEY = 'UeHP9baEngMB_pguz2CeTFJWaFdMEpnqUy2-rev_QJmI8'
        PROJECT_PATH = 'CI-CD'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout your Git repository
                checkout scm
            }
        }

        stage('Build Package') {
            steps {
                script {
                    // Download and install UiPath CLI
                    def uipathCliPath = 'https://uipath.visualstudio.com/Public.Feeds/_artifacts/feed/UiPath-Official/NuGet/UiPath.CLI.Windows/overview/23.10.8753.32995'
                    sh "${uipathCliPath}/uipcli pack ${PROJECT_PATH} --output output --version ${PACKAGE_VERSION}"
                }
            }
        }

        stage('Publish to Orchestrator') {
            steps {
                script {
                    // Publish the package to Orchestrator
                    def uipathCliPath = tool 'uipath-cli'
                    sh "${uipathCliPath}/uipcli push output/*.nupkg --orchestrator ${ORCHESTRATOR_URL} --tenant ${ORCHESTRATOR_TENANT} --apiKey ${ORCHESTRATOR_API_KEY}"
                }
            }
        }
    }

    post {
        success {
            echo "Package successfully built and published!"
        }
        failure {
            echo "Package build or publish failed."
        }
    }
}
