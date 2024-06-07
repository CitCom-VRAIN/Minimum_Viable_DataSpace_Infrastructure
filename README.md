>[!WARNING]
> **Branch Halted**
>
> This development has been halted and will not be continued in the foreseeable future.
>
> `module/ds_marketplace`

---

<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/CitCom-VRAIN/Minimum_Viable_DataSpace_Infrastructure">
    <img src="images/logo.png" alt="Logo" width="100" height="100">
  </a>

  <h3 align="center">Minimum Viable Data Space Infrastructure (MVDS-IaaS)</h3>

  <p align="center">
    Infrastructure as a Service for a Minimum Viable Data Space (MVDS) using FIWARE components.
    <br />
    <a href="https://citcom-vrain.github.io/"><strong>Explore the docs »</strong></a>
    <br />
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#tested-on">Tested On</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started-prerequisites">Getting Started (Prerequisites)</a>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#references">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

This repo is part of the tasks of the European project [Citcom.ai](https://citcom.ai/). The main objective is to describe the necessary infrastructure to deploy a data space (with all its components) using [FIWARE](https://www.fiware.org/) technology, providing a detailed and easy-to-follow guide for different environments. This includes the configuration of the infrastructure, the installation and configuration of the necessary components, and the integration with existing applications.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

<div align="center">

  | <!-- -->                                  | <!-- -->        | <!-- -->      |
  |:-----------------------------------------:|:---------------:|:-------------:|
  | [![terraform][Terraform]][Terraform-url]  | [![kubernetes][k8s]][k8s-url] | [![docker][docker]][docker-url] |
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Tested on

<div align="center">

  | <!-- -->                                  | 
  |:-----------------------------------------:|
  | [![ubuntu22.04.03LTS][ubuntu]][ubuntu-url]  | 
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started (Prerequisites)

This project was developed on:

* Ubuntu 22.04.3 LTS

These are the necessary requirements to be able to execute the project:

* [Docker](https://docs.docker.com/engine/install/ubuntu/) (v. 25.0.2)
* [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries) (v. 0.20.0)
  ```bash
  # For AMD64 / x86_64
  [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-amd64
  
  # For ARM64
  [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-arm64
  
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  ```
* [Helm](https://helm.sh/docs/intro/install/#from-apt-debianubuntu) (v. 3.14.0)
  ```bash
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm
  ```
* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) (v. 1.28.3)
* [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform) (v. 1.7.3)
  ```bash
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ```
* [Make](https://www.gnu.org/software/make/) (v. 4.3)
  ```bash
  sudo apt install make
  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

1. Clone the repository.

2. Access one of the examples, in this case we will use as an example: `kind_cluster`

  ```bash
  cd examples/kind_cluster
  ```

3. From the example folder, deploy the infrastructure using terraform.
  ```bash
  make init_apply

  # make destroy
  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the AGPL-3.0 License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
<!-- ## Contact

Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - email@email_client.com

Project Link: [https://github.com/github_username/repo_name](https://github.com/github_username/repo_name)

<p align="right">(<a href="#readme-top">back to top</a>)</p> -->



<!-- REFERENCES -->
## References

* [Readme Template](https://github.com/othneildrew/Best-README-Template)
* [FIWARE DS example](https://github.com/FIWARE-Ops/fiware-gitops/tree/master/aws/dsba)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[Terraform]: https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white
[Terraform-url]: https://www.terraform.io/

[k8s]: https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white
[k8s-url]: https://kubernetes.io/

[docker]: https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white
[docker-url]: https://www.docker.com/

[ubuntu]: https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white
[ubuntu-url]: https://ubuntu.com/
