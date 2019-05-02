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

##### Common Airflow and Kubernetes Tasks

###### Tips
*  We recommended aliasing `kubectl` as `kbc`
*  The secret manifest file is in 1password in the Data Team Vault as `default_secrets.yaml`.

###### Access Airflow Webserver UI
* `kubectl port-forward deployment/airflow-deployment 1234:8080`. You can now navigate to `localhost:1234` in a browser and it will take you to the webserver for the instance you port-forwarded to. 

###### View Resources
* `kubectl get all`. This will display any pods, deployments, replicasets, etc.
* `kubectl get pods` command to see a list of all pods in your current namespace.

###### View Persistent Volumes
*  To see a list of persistent volumes or persistent volume claims (where the logs are stored), use the commands `kubectl get pv` and `kubectl get pvc` respectively. The command to get persistent volumes will show all volumes regardless of namespace, as persistent volumes don't belong to namespaces. Persistent volume claims do however belong to certain namespaces and therefore will only display ones within the namespace of your current context.

###### Restart Deployment and Pods
* If you need to force a pod restart, either because of Airflow lockup, continual restarts, or refreshing the Airflow image the containers are using, run `kubectl delete deployment airflow-deployment`. This will wipe out any and all pods (including ones being run by airflow so be careful). Run `kubectl apply -f airflow-image/manifests/deployment.yaml` to send the manifest back up to k8s and respawn the pods.

* The resource manifests for kubernetes live in `airflow-image/manifests/`. To create or update these resources in kubernetes first run `kubectl delete deployment airflow-deployment` and then run `kubectl apply -f <manifest-file.yaml>`. Because we are using a persistent volume that can only be claimed by one pod at a time we can't use the the usual `kubectl apply -f` for modifications. A fresh deployment must be set up each time.

###### Access Shell with Pod

-  To get into a shell that exists in a kube pod, use the command `kubectl exec -ti <pod-name> -c <container-name> /bin/bash`. This will drop you into a shell within the pod and container that you chose. This can be useful if you want to run airflow commands directly within a shell instead of trying to do it through the webserver UI.
  
    - `kubectl exec -ti airflow-deployment-56658758-ssswj -c scheduler /bin/bash` Is an example command to access that pod and the container named `scheduler`. The container names are listed in `airflow_image/manifests/deployment.yaml`. This information is also available if you do `kubectl describe <pod>` thought it is harder to read.
      - Additional tip: there is no need to specify a resource type as a separate argument when passing arguments in resource/name form (e.g. 'kubectl get resource/<resource_name>' instead of 'kubectl get resource resource/<resource_name>'

- Things you might do once you're in a shell:

  - Trigger a specfic task in a dag: 
    - Template: `airflow run <dag> <task_name> <execution_date> -f -A` 
    - Specific example: `airflow run dbt dbt-full-refresh 05-02T15:52:00+00:00  -f -A`
    - The `-f` flag forces it to rerun even if there was already a success or failure for that task_run, the `-A` flag forces it to ignore dependencies (aka doesn’t care that it wasn’t branched to upstream)

###### Updating Secrets
-  The easiest way to update secrets is to use the command `kubectl edit secret airflow -o yaml`, this will open the secret in a text editor and you can edit it from there. New secrets must be base64 encoded, the easiest way to do this is to use `echo -n <secret> | base64 -`. There are some `null` values in the secret file when you edit it, for the file to save successfully you must change the `null` values to `""`, otherwise it won't save properly.

###### Stopping a Running DAG
* Navigate to the graph view of the dag in question
* Select the task in the graph view
* In the modal that pops up select either Mark Failed or Mark Success with the Downstream option selected.
* Confirm in the [Kubernetes workloads tab](https://console.cloud.google.com/kubernetes/workload?project=gitlab-analysis&workload_list_tablesize=50) that the relevant pod is stopped. Delete it if necessary.


## Updating the Runner

We execute our CI jobs in Kubernetes in the `gitlab-analysis` project. In the case where a new group runner token needs to be associated, or if we need to update the runner image. These are the basic steps.

To get things installed

`brew install kubernetes-helm`

 `gcloud components install kubectl`

To get the credentials 

`gcloud container clusters get-credentials bizops-runner --zone us-west1-a --project gitlab-analysis`

To see the helm releases

`helm list`

To get the chart values for a specific release

`helm get values <release_name>`

Prep commands

`helm init --client-only`
`helm repo add gitlab https://charts.gitlab.io`
`helm repo update`

To delete a release

`helm del --purge <release_name>`

To install a release

`helm install --namespace <namespace> --name <release_name> -f values.yaml <chart_name>`

Example for updating the group token 

```bash
gcloud components update
helm get values gitlab-runner
helm init
helm get values gitlab-data
touch values.yml
<save values to values.yml>
helm list
helm del --purge gitlab-data
helm install --namespace gitlab-data --name gitlab-data -f values.yaml gitlab/gitlab-runner
kubectl get pod -n gitlab-data
```