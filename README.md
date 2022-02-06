# Splunk Utility 🐋 Images & Ansible roles

<div align="center" >🤝 Show your support - give a ⭐️ if you liked the project | Share on
<a target="_blank" href='https://twitter.com/intent/tweet?url=https%3A%2F%2Fgithub.com%2Fnextpart%2Fsplunk-utilities'><img src='https://img.shields.io/badge/Twitter-1DA1F2?logo=twitter&logoColor=white'/></a>
| Follow us on
<a target="_blank" href='https://www.linkedin.com/company/69421851'><img src='https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white'/></a>
</br></div>
</br></br>
<div align="center" >

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

</div>

---

This will be a collection of
[![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?logo=ansible&logoColor=white)](https://www.ansible.com/)
roles and
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
images (built with
[![Packer](https://img.shields.io/badge/Packer-1DAEFF?logo=packer&logoColor=white)](https://www.packer.io/)
) to help in development with
[![image](https://img.shields.io/badge/Splunk-6fac4c.svg?logo=splunk&logoColor=white)](https://splunk.com/)
Enterprise & Cloud.

## Motivation

When we work with [Splunk][splunk], we use various tools in the supply chain that we
ideally want to have available quickly and immutable so that they can be used locally
but also in pipelines and other automations.

## Utility Roles/Images

> TODO

To build an image you can run the generic packer file (`generic.pkr.hcl`) and provide
the arguments for the desired role:

```bash
packer build --var='ansible_playbook=<something>' \
  --var='docker_image_name=splunk-<something>' \
  --var='docker_registry=<registryname>' \
  generic.pkr.hcl
```

you could also create local role specific configuration files, like
`<something>.pkrvars.hcl` and provide the arguments via `--var-file`:

```hcl
ansible_playbook  = "<something>"
docker_image_name = "splunk-<something>"
docker_registry   = "<registryname>"
```

### Splunk Application Packaging

**Image**:
[_`nextpart/splunk-package:latest`_](https://hub.docker.com/r/nextpart/splunk-package)

![package_image_size](https://img.shields.io/docker/image-size/nextpart/splunk-package/latest)

This packaging image (resp. role) is used, as the name suggests, to [package][packaging]
and [validate][appinspect] apps. For this purpose, there is the `/apps` folder (resp.
`APP_DIR`), where the **source code of the application** is supplied, and the `/dist`
folder or distribution (resp. `PKG_DIR`), where the **finished package with the test
reports** is then located when the container is finished with its task.

```bash
docker run -it \
    -v "`pwd`/apps/APP_FOLDER_NAME:/apps/APP_FOLDER_NAME" \
    -v "`pwd`/dist:/dist" \
    -e "MYUSER=`id -u`" \
    splunk-package:latest
```

It is also possible to map several apps into the directory and process them in bulk as
the primary use case in the initial implementation was the usage in CI/CD pipelines.

The process is currently still very static but will be expanded soon so that more
parameters can be passed for various use cases.

**Parameter variables for packaging**:

- `MYUSER`: Local user ID which should own the final `dist`.
- `APP_DIR`: Path to application source mapping (e.g. `Build.SourcesDirectory` for Azure
  Pipelines CI/CD purposes)
- `PKG_DIR`: Path to distribution package mapping (e.g. `Build.ArtifactStagingDirectory`
  for Azure Pipelines CI/CD purposes)
- `SPL_IGNORE`: Files (& wildcards) to be ignored in packaging process.

### Splunk standalone EventGen (_`eventgen`_)

This image (resp. role) provides you a standalone service or installation of splunk
[eventgen], allowing you to send sample data to various instances and utilize it's API.

> TODO

## Contribution

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/michael-nextpart/remote-development)
or use as
[![VS Code Container](https://img.shields.io/static/v1?label=VS+Code&message=Container&logo=visualstudiocode&color=007ACC&logoColor=007ACC&labelColor=2C2C32)](https://open.vscode.dev/microsoft/vscode)

Pull requests are welcome. For major changes, please open an issue first to discuss what
you would like to change.

Please make sure to update tests as appropriate.

## Roadmap / ToDo

in progress ... waiting for suggestions

- [ ] Standalone eventgen service

## References

[splunk]: https://www.splunk.com/

- [Splunk][splunk]

[appinspect]: https://dev.splunk.com/enterprise/reference/appinspect

- [Splunk AppInspect][appinspect]

[packaging]: https://dev.splunk.com/enterprise/reference/packagingtoolkit

- [Splunk Packaging Toolkit][packaging]

[eventgen]: http://splunk.github.io/eventgen/

- [Splunk Eventgen][eventgen]

## Support

[![Support via PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/donate/?hosted_button_id=UXNY3UEYKBJ7L)

...

---
