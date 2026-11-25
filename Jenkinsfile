pipeline {
    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '15'))
    }

    environment {
        SLA_MAX_DURATION_MS = '8000'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/aldopontoh/automationexercise-jmeter-api.git'
            }
        }

        stage('Clean Previous Artifacts') {
            steps {
                powershell '''
                    if (Test-Path "results.jtl") { Remove-Item -Force "results.jtl" }
                    if (Test-Path "jmeter.log")  { Remove-Item -Force "jmeter.log" }
                    if (Test-Path "report-html") { Remove-Item -Recurse -Force "report-html" }
                '''
            }
        }

        stage('Run JMeter Non-GUI API Suite') {
            steps {
                bat 'jmeter -n -t plans/automationexercise-api-suite.jmx -l results.jtl -e -o report-html'
            }
        }

        stage('Verify Results & SLA Thresholds') {
            steps {
                powershell '''
                    & ".\scripts\verify-results.ps1" -JtlPath "results.jtl" -MaxDurationMs ([int]$env:SLA_MAX_DURATION_MS)
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'results.jtl,report-html/**', allowEmptyArchive: true
        }
    }
}
