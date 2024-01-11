pipeline {
    agent any
    
    environment {
        PROJECT_NAME = 'CI-CDRPA'
        PROJECT_FOLDER = 'CI-CD'
        ORCH_URL = 'https://cloud.uipath.com/'
        ORCH_TENANT = 'DefaultTenant'
        ORCH_CLIENT_ID = '8DEv1AMNXczW3y4U15LL3jYf62jK93n5'
        ORCH_USER_KEY = 'jvT_SkKaYoYnagIy-S0kS2cGdLdGLbR36l2epiwqL08VV'
        ORCH_ACC_NAME = 'emindqzrkobt'
        CLI_URL = 'https://uipath.visualstudio.com/Public.Feeds/_artifacts/feed/UiPath-Official/NuGet/UiPath.CLI.Windows/overview/23.10.8753.32995'
        SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/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'
    }

    stages {
        stage('Print Details') {
            steps {
                script {
                    echo "Home: ${HOME}"
                    echo "BRANCH_NAME: ${BRANCH_NAME}"
                    echo "BUILD_NUMBER: ${BUILD_NUMBER}"
                    echo "JOB_NAME: ${JOB_NAME}"
                    echo "WORKSPACE: ${WORKSPACE}"
                    echo "CHANGE_ID: ${CHANGE_ID}"
                    echo "CHANGE_URL: ${CHANGE_URL}"
                    echo "CHANGE_TITLE: ${CHANGE_TITLE}"
                }
            }
        }

        stage('Clean Workspace') {
            steps {
                script {
                    echo "Cleaning up previous run"
                    deleteDir()
                }
            }
        }

        stage('Build UiPath NuGet Package') {
            agent {
                label 'windows'
            }

            steps {
                script {
                    checkout scm
                    powershell "$WORKSPACE\\Scripts\\UiPathPack.ps1 $WORKSPACE\\project.json -destination_folder $WORKSPACE\\package -autoVersion"
                    archiveArtifacts artifacts: 'package/**/*.*', excludes: ''
                    archiveArtifacts artifacts: 'Scripts/**/*.*', excludes: ''
                }
            }
        }

        stage('Publish UiPath NuGet Package') {
            agent {
                label 'windows'
            }

            steps {
                script {
                    unarchive mapping: ['Artifacts' : '.']
                    powershell "$WORKSPACE\\Scripts\\UiPathDeploy.ps1 $WORKSPACE\\package $ORCH_URL $ORCH_TENANT -UserKey $ORCH_USER_KEY -account_name $ORCH_ACC_NAME"
                }
            }
        }

        stage('Notify Slack') {
            agent {
                label 'master'
            }

            steps {
                script {
                    if (currentBuild.resultIsBetterOrEqualTo('SUCCESS')) {
                        sh 'curl -X POST -H "Content-type: application/json" --data "{\"text\":\"UiPath NuGet Package build and publish successful!\"}" $SLACK_WEBHOOK_URL'
                    } else {
                        sh 'curl -X POST -H "Content-type: application/json" --data "{\"text\":\"UiPath NuGet Package build or publish failed!\"}" $SLACK_WEBHOOK_URL'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

