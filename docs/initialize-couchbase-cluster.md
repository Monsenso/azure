## Initializing a Couchbase cluster

- Get access to the corresponding VPN by following the [Wiki article on Azure VPN](https://dev.azure.com/monsenso/Clients/_wiki/wikis/Wiki/47/Azure-VPN).
  - The corresponding ResourceGroup should relate to the Region, so for an EU setup, use the eu-vpn
- SSH to the server, using your Azure account.
  - Example in bash:
    `ssh surname@monsenso.com@10.7.5.5`
- Install Couchbase Enterprise on the VM:
  - Version requirements: Couchbase v6.latest, Ubuntu 18.04.
  - [Couchbase installation guide.](https://docs.couchbase.com/server/current/install/ubuntu-debian-install.html)
- Copy the `couchbase` folder and `initialize-couchbase-cluster.sh`, fx with `scp`, to the VM and run the script.

  - Use sudo.
  - Default values should be fine.
  - When prompted for an Admin Password, this will be the password for the Couchbase Administrator account, so make sure it is secure and not lost.
  - Example `scp` commands in bash:

    ```bash
    scp -r /monsenso/repos/azure/couchbase surname@monsenso.com@10.7.5.5:/home/azure/couchbase
    ```

    ```bash
    scp /monsenso/repos/azure/initialize-couchbase-cluster.sh surname@monsenso.com@10.7.5.5:/home/azure/
    ```
