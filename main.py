from os import path
from kubernetes import client, config

import yaml
import random
import os



def main():
    # Configs can be set in Configuration class directly or using helper
    # utility. If no argument provided, the config will be loaded from
    # default location.
    config.load_kube_config()
    v1 = client.CoreV1Api()
    all_pod = v1.list_namespaced_pod(namespace=os.environ.get('NAMESPACE')) #json output
    pod_name = [item.metadata.name for item in all_pod.items] #format in a list

    print(pod_name)
    random_pod = random.choice(pod_name)
    print(random_pod)
    v1.delete_namespaced_pod(name=random_pod, namespace=os.environ.get('NAMESPACE'), body=client.V1DeleteOptions())




    
if __name__ == '__main__':
    main()