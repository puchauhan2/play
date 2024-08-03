if [[ -z "${1}" ]] 
then
echo "No argument found,please pass argumrnt for build version"
exit 1 ; 
else
echo "Building container image"
chmod +x script.sh
sudo docker build -t "lambda" .
sudo docker tag lambda:latest 975050198487.dkr.ecr.us-east-1.amazonaws.com/lambda_container:${1}
sudo docker push 975050198487.dkr.ecr.us-east-1.amazonaws.com/lambda_container:${1}
fi
