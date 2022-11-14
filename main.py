from kubernetes import client, config

import random
import os
import time
import datetime

h = os.environ.get('h')
m = os.environ.get('m')
s = os.environ.get('s')

def delete_pod():
  config.load_incluster_config()
  v1 = client.CoreV1Api()
  ns = os.environ.get('NAMESPACE')
  all_pod = v1.list_namespaced_pod(namespace=ns)
  pod_name = [item.metadata.name for item in all_pod.items]

  random_pod = random.choice(pod_name)
  v1.delete_namespaced_pod(name=random_pod, namespace=ns, body=client.V1DeleteOptions())
  print("Deleting random pod: " + random_pod)

def chaos_monkey(h, m, s):
  while True:
    total_seconds = h*3600 + m*60 + s
    while total_seconds > 0:
      time_left = datetime.timedelta(seconds = total_seconds)
      print(time_left)
      time.sleep(1)
      total_seconds -= 1
    delete_pod()

def main():
  chaos_monkey(int(h), int(m), int(s))

if __name__ == '__main__':
  main()