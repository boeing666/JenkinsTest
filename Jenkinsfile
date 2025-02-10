node {
    
    stage('Build') {
        docker.image('python:latest').inside() {
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
        docker.image('python:latest').inside('-u root') {
            sh 'pip install pyinstaller'
            sh 'pyinstaller --onefile sources/add2vals.py'
        }
        
        archiveArtifacts 'dist/add2vals'
        
	// Create a Dockerfile

	sh '''
	echo "FROM ubuntu" > Dockerfile
	echo "WORKDIR /usr/local/bin" >> Dockerfile
	echo "COPY dist/add2vals /usr/local/bin/add2vals" >> Dockerfile
	echo "RUN chmod +x /usr/local/bin/add2vals" >> Dockerfile
	echo "ENTRYPOINT [\"/usr/local/bin/add2vals\"]" >> Dockerfile
	'''

	// Build add2vals-image

	sh "docker build -t add2vals-image:latest ."

	// Push image into docker registry and upload it to Render

	withCredentials([usernamePassword(credentialsId: 'docker-credentials',
		usernameVariable: 'DOCKER_USERNAME',
		passwordVariable: 'DOCKER_PASSWORD'),
			 string(credentialsId: 'render-api-key',
		variable: 'RENDER_API_KEY'),
			 string(credentialsId: 'render-owner-id',
		variable: 'RENDER_OWNER_ID')]) {
			def DOCKER_REPO = 'add2vals-repo'
			def DOCKER_TAG = 'latest'
			def RENDER_REGION = 'oregon'
			def RENDER_INSTANCE = 'free'
			def RENDER_SERVICE_NAME = "render-service-${env.BUILD_NUMBER}"
 
			sh '''
			echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
			'''
			
			sh "docker push ${env.DOCKER_USERNAME}/${DOCKER_REPO}:${DOCKER_TAG}"

			def RENDER_PAYLOAD = """
                        {
                          "name": "${RENDER_SERVICE_NAME}",
                          "type": "web_service",
                          "imagePath": "{env.DOCKER_USERNAME}/${DOCKER_REPO}:${DOCKER_TAG}",
			  "region": "${RENDER_REGION}",
			  "plan": "${RENDER_INSTANCE}",
			  "ownerId": "${env.RENDER_OWNER_ID}
			  "numInstances": 1
			}
			"""

			writeFile file: 'render-payload.json', text: RENDER_PAYLOAD

			sh '''
			curl -X POST "https://api.render.com/v1/services" \
			     -H "Accept: application/json" \
			     -H "Content-Type: application/json" \
			     -H "Authorization: Bearer $RENDER_API_KEY" \
			     -d @render-payload.json
			''' 
	}

        echo 'Pipeline has finished succesfully.'
        sleep time:1, unit: 'MINUTES'
    }
}
