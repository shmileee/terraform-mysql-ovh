# Deploying MySQL to OVH using Terraform & Ansible

A collection of scripts to install and configure MySQL on OVH public cloud. Custom `db-server` Terraform module used to deploy databases with Ansible on a s1-2 flavor instance in OVH public cloud. OpenStack dynamic inventory plugin is used to pull hosts information. Ansible Galaxy is used to pull `geerlingguy.mysql` role.

## Requirements

Please make sure before going any further that all the following pre requisites are met on your side:

- Register an [OVH account](https://www.ovh.com/world/support/new_nic.xml)
- Order a Public Cloud project
- Create an [OpenStack user](https://www.youtube.com/watch?v=BIMb0iR1YhY)
- Download openrc to `~/openrc.sh`
- Python 3 is installed.

Install `pipenv` and further `ansible` dependencies:

    python3 -m pip install --user pipenv
    cd ansible && python3 -m pipenv install

Next run `./run.sh` to fetch rest of the dependencies:

- jq
- terraform
- terraform-inventory (optional but very useful to troubleshoot yout TF state without leveraging Ansible internals)

## Ansible Role Variables

For default variables used please refer to roles fetched via ansible-galaxy documentation. Custom variables are under `inventories/<project>/<environment>/group_vars`):

    # Databases.
    mysql_databases:
    - name: amxbans
        collation: utf8_general_ci
        encoding: utf8
        replicate: 1
    - name: screenshots
        collation: utf8_general_ci
        encoding: utf8
        replicate: 1

    # Users.
    mysql_users:
    - name: amxbans_user
        host: '%'
        password: "{{ vaulted_amxbans_user_password }}"
        priv: 'amxbans.*:ALL/screenshots.*:ALL'


## Deployment

After requirements are met, deployment can be trigger using `run.sh -c apply`. For ruther assistance refer to `--help`.

    Usage: ./run.sh [arguments]...

    -n, --number            number of instances (default: 1)
    -c, --command           select terraform command to run
                            possible options: @(refresh|plan|apply|destroy|validate)
    -a, --auto-approve      auto-approve terraform command (default: false)
    -h, --help              display this help message

## Example execution

    $  ./run.sh -a -c apply

    [+] Selected command: apply
    [+] Selected number of instances: 1
    [+] Automatically approve: true
    [+] Dependency check previously conducted. To rerun remove file .dep_check
    [+] Running command: terraform apply --parallelism 20 -auto-approve
    module.db-server.data.http.myip: Refreshing state...
    module.db-server.data.openstack_networking_network_v2.public: Refreshing state...
    module.db-server.openstack_compute_keypair_v2.keypair: Refreshing state... [id=csb]
    module.db-server.data.template_file.setup: Refreshing state...
    module.db-server.data.template_file.userdata: Refreshing state...
    module.db-server.openstack_networking_port_v2.public[0]: Refreshing state... [id=134a9579-74cb-41c3-9ab6-89ce37efc65d]
    module.db-server.openstack_compute_instance_v2.nodes[0]: Refreshing state... [id=ac61e44b-e0a8-40c0-bdc2-b8003fdff8ea]
    module.db-server.null_resource.inventory: Refreshing state... [id=6764917110691146859]

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

    Outputs:

    instance_ips = [
    "x.x.x.x.",
    ]

## Miscellaneous

To keep TF state in Swift make sure you're using `WAW` region when running `terraform init`, since `WAW1` does not support object storage. Compute instances in contrast are deployed to `WAW1`. Ansible OpenStack plugin expects environmental variable `OS_REGION_NAME` to be set to `WAW1` to query for hosts.
