node {
    stage('Build') {
        docker.image('python:2-alpine').inside() {
            sh 'python -m py_compile sources/add2vals.py sources/calc.py'
        }
    }

    stage('Test') {
        docker.image('qnib/pytest').inside() {
            sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
        }

        junit 'test-reports/results.xml'
    }

    stage('Manual Approval') {
        input message: 'Lanjutkan ke tahap Deploy?'
    }

    stage('Deploy') {
        docker.image('cdrx/pyinstaller-linux:python2').inside('-p 3000:3000') {
            sh 'pyinstaller --onefile sources/add2vals.py'
        }

        success {
            archiveArtifacts 'dist/add2vals'
        }
    }
}