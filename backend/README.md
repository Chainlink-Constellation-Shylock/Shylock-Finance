# Shylock Finance Backend

## Local Development

1. Add environment variables at .env
2. Build docker image and run the container
  ```bash
  sudo ./start.sh
  ```

3. Send an example request (DAO should be fixed, while you can test with your address)
  ```bash
  curl http://localhost:3001/uniswapgovernance.eth/0x683a4F9915D6216f73d6Df50151725036bD26C02
  ```

4. Check logs
  ```bash
  docker ps -al     # Check the CONTAINER_NAME running currently.
  docker logs [CONTAINER_NAME]
  ```

4. Stop and remove the running container 
  ```bash
  sudo ./stop.sh
  ```