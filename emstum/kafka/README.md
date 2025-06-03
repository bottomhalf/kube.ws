Make sure to replace the value while creating the broker 

        - name: KAFKA_ZOOKEEPER_CONNECT
          value: 10.152.183.78:2181


Here: <local-kafka-broker-service-ip>:<port>

To start the kafka first we need to map service name with local system ip
i.e. here in our case kafka broker service = kafka-broker should be mapped to localhost
=> cat /etc/hosts
add ip
=> 127.0.0.1 kafka-broker

Then do port forward, command:
Blocking command:
    kc port-forward -n <namespace> <kafka-broker-pod-name>

Non-blocking command:
    kc port-forward -n <namespace> <kafka-broker-pod-name> &
To kill the process and stop port forwarding
    $ telnet localhost 9092
    $ ps aux | grep "kubectl port-forward"
    $ kill <process-id>