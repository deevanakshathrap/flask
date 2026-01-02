pipeline {
    agent any

    environment {
        FLASK_EC2 = "ubuntu@13.233.146.57"
        APP_DIR  = "/home/ubuntu/flask-app"
        SSH_KEY  = "/var/lib/jenkins/.ssh/id_ed25519"
    }

    stages {

        stage('Checkout Source') {
            steps {
                echo "=== Checking out source code ==="
                checkout scm
            }
        }

        stage('Install Dependencies Locally') {
            steps {
                echo "=== Installing dependencies locally for test ==="
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Basic Test') {
            steps {
                echo "=== Running basic Flask import test ==="
                sh '''
                . venv/bin/activate
                python - << 'EOF'
import flask
print("Flask OK:", flask.__version__)
EOF
                '''
            }
        }

        stage('Deploy to Flask EC2') {
            steps {
                echo "=== Deploying to Flask EC2 ==="
                sh '''
                # Create application directory on slave EC2
                ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${FLASK_EC2} \
                "mkdir -p ${APP_DIR}"

                # Copy application files to slave EC2
                scp -r -i ${SSH_KEY} -o StrictHostKeyChecking=no \
                app.py requirements.txt templates \
                ${FLASK_EC2}:${APP_DIR}/

                # SSH into slave EC2 and start Flask app
                ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${FLASK_EC2} "
                    cd ${APP_DIR} &&

                    # Create virtual environment if not exists
                    if [ ! -d venv ]; then
                        python3 -m venv venv
                    fi &&

                    # Activate venv and install dependencies
                    . venv/bin/activate &&
                    pip install --upgrade pip &&
                    pip install -r requirements.txt &&

                    # Stop old Flask app if running
                    pkill -f 'venv/bin/python app.py' || true &&

                    # Start Flask app in background using nohup
                    nohup venv/bin/python app.py > flask.log 2>&1 &
                    disown
                "
                '''
            }
        }
    }

    post {
        success {
            echo "=== Deployment successful! ==="
            echo "Visit: http://13.233.146.57:5000"
        }
        failure {
            echo "=== Deployment failed — check Jenkins logs ==="
        }
        always {
            echo "=== Pipeline finished ==="
        }
    }
}
