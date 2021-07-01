## Initializing a Couchbase cluster

- Get access to the corresponding VPN by following the [Wiki article on Azure VPN](https://dev.azure.com/monsenso/Clients/_wiki/wikis/Wiki/47/Azure-VPN).
  - The corresponding ResourceGroup should relate to the Region, so for an EU setup, use the eu-vpn
- SSH to the server, using your Azure account.
  - Example in bash:
    `ssh surname@monsenso.com@$IP_ADDRESS_VM_COUCHBASE`
  - Troubleshooting:
    - Verify that your user has 'Virtual Machine Administrator Login' role
    - Check your VPN connection
    - Check the virtual machine's inbound port rule's ssh source ip address allowed ranges to include your VPN-assigned IP.
    - (Check that new env address space does not collide with other address spaces(incl. VPN ones) )
- Install Couchbase Enterprise on the VM:
  - Version requirements: Couchbase v6.latest, Ubuntu 18.04.
  - [Couchbase installation guide.](https://docs.couchbase.com/server/current/install/ubuntu-debian-install.html)
- Copy the `couchbase` folder and `initialize-couchbase-cluster.sh`, fx with `scp`, to the VM and run the script.   
  - Example `scp` commands in bash:

    ```bash
    IP_ADDRESS_VM_COUCHBASE=10.13.5.5; YOUR_USER_DIR_ON_VM=brink; scp -r ./couchbase $YOUR_USER_DIR_ON_VM@monsenso.com@$IP_ADDRESS_VM_COUCHBASE:~/azure
    ```

    ```bash
    IP_ADDRESS_VM_COUCHBASE=10.13.5.5; YOUR_USER_DIR_ON_VM=brink; scp ./initialize-couchbase-cluster.sh $YOUR_USER_DIR_ON_VM@monsenso.com@$IP_ADDRESS_VM_COUCHBASE:~/azure/
    ```
    Note: You need to first create for `scp` the directory `azure` under the VM's user's home ~ directory

  - Run script:
    - Use sudo.
    - Default values should be fine.
    - When prompted for an Admin Password, this will be the password for the Couchbase Administrator account, so make sure it is secure and not lost.
  