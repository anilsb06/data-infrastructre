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

4.  Set the default namespace to `testing` by running `kubectl config set-context $(kubectl config current-context) --namespace=testing`

5. (Optional) Use the `kubectl port-forward` command to connect to the webserver by running `kubectl port-forward deployment/airflow-deployment 1234:8080` and open your browser to `localhost:1234` 
