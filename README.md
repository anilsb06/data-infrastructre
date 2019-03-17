## Data Image

The `data_image` dir contains everything needed for building and pushing the `data-image`. If a binary needs to be installed it should be done in the Dockerfile directly, python packages should be added to the `requirements.txt` file and pinned to a confirmed working version.


## Airflow Image

The `airflow_image` dir contains everything needed to build and push not only the `airflow-image` but also the corresponding k8s deployment manifests. The only manual work that needs to be done for a fresh deployment is setting up an `airflow` secret. The required secrets can be found in `airflow_image/manifests/secret.template.yaml`.  

The `default` airflow instance is the production instance, it uses the `airflow` postgres db. The `testing` instance uses the `airflow_testing` db.  

The `default` instance logs are stored in `gs://gitlab-airflow/prod`, the `testing` instance logs are stored in `gs://gitlab-airflow/testing`
##### Connecting to the the Kubernetes Airflow Cluster:

1. [Install Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-with-homebrew-on-macos)

2.  Connect it to the data team cluster by running -> `gcloud container clusters get-credentials airflow --zone us-central1-a --project gitlab-analysis`

3.  Run `kubectl get pods` and make sure it returns successfully 

4. * ALL OF YOUR COMMANDS TOUCH PRODUCTION, THERE IS CURRENTLY NO TESTING ENVIRONMENT IN K8S*. The canonical way to test is to use the local docker-compose setup.

4. (Optional) Use the `kubectl port-forward` command to connect to the webserver by running `kubectl port-forward deployment/airflow-deployment 1234:8080` and open your browser to `localhost:1234` 

##### Troubleshooting Airflow and Basic Kube Commands:

-  It can be easier to alias `kubectl` as `kbc`

-  To see a list of resources, run `kubectl get all`. This will display any pods, deployments, replicasets, etc.

-  To see a list of persistent volumes or persistent volume claims (where the logs are stored), use the commands `kubectl get pv` and `kubectl get pvc` respectively. The command to get persistent volumes will show all volumes regardless of namespace, as persistent volumes don't belong to namespaces. Persistent volume claims do however belong to certain namespaces and therefore will only display ones within the namespace of your current context.

- Use the `kubectl get pods` command to see a list of all pods in your current namespace.

- If you need to force a pod restart, either because of Airflow lockup, continual restarts, or refreshing the Airflow image the containers are using, run `kubectl delete deployment airflow-deployment`. This will wipe out any and all pods (including ones being run by airflow so be careful). Run `kubectl apply -f airflow-image/manifests/deployment.yaml` to send the manifest back up to k8s and respawn the pods.

- The resource manifests for kubernetes live in `airflow-image/manifests/`. To create or update these resources in kubernetes first run `kubectl delete deployment airflow-deployment` and then run `kubectl apply -f <manifest-file.yaml>`. Because we are using a persistent volume that can only be claimed by one pod at a time we can't use the the usual `kubectl apply -f` for modifications. A fresh deployment must be set up each time.

-  The secret manifest files are located in 1pass as `default_secrets.yaml`.

-  To be able to get to an Airflow webserver UI that lives in kubernetes, run the command `kubectl port-forward deployment/airflow-deployment 1234:8080`. You can now navigate to `localhost:1234` in a browser and it will take you to the webserver for the instance you port-forwarded to. 

-  To get into a shell that exists in a kube pod, use the command `kubectl exec -ti <pod-name> -c <container-name> /bin/bash`. This will drop you into a shell within the pod and container that you chose. This can be useful if you want to run airflow commands directly within a shell instead of trying to do it through the webserver UI.

-  The easiest way to update secrets is to use the command `kubectl edit secret airflow -o yaml`, this will open the secret in a text editor and you can edit it from there. New secrets must be base64 encoded, the easiest way to do this is to use `echo -n <secret> | base64 -`. There are some `null` values in the secret file when you edit it, for the file to save successfully you must change the `null` values to `""`, otherwise it won't save properly.
