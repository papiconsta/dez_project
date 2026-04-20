# Terraform Initialization - IaaC

<p style="font-size:20px"> In order for us to create the infustracture for our Pipelines, we can use an IaaC Solution. The first thing that we need to do is to install Terraform.</p>

<p>
    Once the installation finished we need to verify it
</p>

```bash
terraform --version
```
e.x output:
```bash
Terraform v1.14.8
on linux_amd64
+ provider registry.terraform.io/hashicorp/google v6.8.0
```
In our case we will continue our project with the version above <br>
Next step is to create a folder and initialize the terraform directory ready.

```bash
mkdir terraform
terraform init    
```
## Next step : Create a Service Account on GCP

For our project we will use the Google Cloud Provider to demostrate our architecture/pipeline. We will use a Service Account in order to run our terraform scripts and build our infa.

![alt text](/resources/image.png)

This is our Service account and we gave also the permissions of

![alt text](/resources/image-1.png)

Last part was to create a key on GCP to authenticate our Terraform scripts with GCP. 

## <h1 style="color:#BA8E23 "> Warning ⚠️ Problem Occured</h1>

In my case I had a problem with IAM roles, in order for my service account to create a new JSON key for terraform use, we got the following error: 
![alt text](/resources/image-2.png)

THe solution for this problem is to go on
1) Organazzation Policies 
2) Search for "key creation"
3) Ovveride parent's policy
4) Edit rule to "Enforcment off" 
5) Done.

![alt text](/resources/image-3.png)

## Generate key

Now we are ready to generate a service key in order to use it to our terraform.google_compute_instance


## Splitting terraform 
Our terraform was kinda big as a main.tf. Now our responsibility is to create multiple files with each file to have a specific role for the infustracture.

