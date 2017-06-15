#!/bin/bash



######################### Running tests #########################

if [ -d "arquillian.github.com-tests" ]; then
    rm -rf arquillian.github.com-tests
fi
git clone git@github.com:MatousJobanek/arquillian.github.com-tests.git

cd ../arquillian.github.com-tests/
#todo use mvnw
mvn clean verify -Darquillian.blog.url=http://localhost:4242/ -Dbrowser=chromeHeadless
#google-chrome http://localhost:4242/ > /dev/null 2>&1 &
firefox http://localhost:4242/ > /dev/null 2>&1 &

echo -e "======================================================================================================"
echo -e "Generation of the blog web pages has been finished!"
echo -e "Check the current state in your browser, go through the test results and check the generation output."
while true; do
    read -p "Do you want to deploy the generated web pages? [y/n]:" yn
    case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo -e "Exiting - for more information see the logs: ${LOGS_LOCATION}"; 
		exit;;
	* ) echo "Please answer yes or no.";;
    esac
done

docker exec -i ${DOCKER_ID} kill ${PROCESS_TO_KILL}
docker exec -it ${DOCKER_ID} ${DOCKER_SCRIPTS_LOCATION}/deploy.sh
docker kill ${DOCKER_ID}
