node {
    stage('Build') {
        docker.image('python:2-alpine').inside('-p 3000:3000 -v ${pwd()}/sources:/sources') {
            sh 'python -m py_compile sources/add2vals.py sources/calc.py'
        }
    }

    stage('Test') {
        docker.image('qnib/pytest -v ${pwd()}/sources:/sources').inside {
            sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
        }

        junit 'test-reports/results.xml'
    }
}