# Homelab
Laboratório para testes utilizando IaC em meu servidor Proxmox

## Laboratório
Provisionamento utilizando Terraform, instalação e configuração com Ansible.

### Proposta de estudo
Com este projeto é possível realizar o provisionamento e configuração dos seguintes serviços:
Bind, Pi-hole, IDM, Foreman e AWX.

## Preparando ambiente Proxmox para o Terraform
Crie um usuário que será utilizado no Terraform para autênticação no servidor Proxmox
```sh
# useradd -s /dev/null -d /dev/null -p pve terraform-prov@pve
```
Crie e atribua a função `TerraformProv` ao usuário criado
```sh
# pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
# pveum user add terraform-prov@pve --password <password>
# pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

## Preparando Template para nodes
No servidor PVE, baixe uma imagem cloud da distribuição desejada, exemplo Debian e configure uma VM para gerar o Template
```sh
# cd /tmp
# wget https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2
# apt install libguestfs-tools -y
# virt-customize --add Rocky-9-GenericCloud.latest.x86_64.qcow2 --install qemu-guest-agent
# qm create 9000 --name rocky9-cloud --ostype l26 --cpu cputype=host --net0 virtio,bridge=vmbr0
# qm importdisk 9000 Rocky-9-GenericCloud.latest.x86_64.qcow2 local-lvm
# qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
# rm -rf Rocky-9-GenericCloud.latest.x86_64.qcow2
# qm set 9000 --ide2 local-lvm:cloudinit
# qm set 9000 --boot c --bootdisk scsi0
# qm set 9000 --serial0 socket --vga serial0
# qm set 9000 --agent enabled=1
# qm template 9000
```
Defina um usuário e senha para autênticação e configure a chave SSH da máquina host no Cloud-init do template criado no Proxmox
```sh
# qm set 9000 --ciuser rocky
# qm set 9000 --ciuser rocky
# qm set 9000 --sshkey ~/.ssh/id_rsa.pub
```

## Autênticação no Terraform
Copie o arquivo .env.example para .env
```sh
# cp .env.example .env
```
Configure o endereço da api do servidor Proxmox, usuário e senha para autênticação, opções de logs e defina a configuração de hardware para os nodes masters e workers e em qual host do Proxmox cada node deve ser criado.
```sh
pm_api_url=https://proxmox-server01.example.com/api2/json
pm_auth_user=terraform-prov@pve
pm_auth_password=pve
pm_log_enable=true
pm_log_file=terraform-plugin-proxmox.log
pm_debug=true
```

## Criando imagem de container Terraform com Ansible
```sh
podman build -t terraform-ansible .
```

## Provisionando ambiente com Terraform
Na máquina host, execute o terraform por meio de um container e realize a criação do ambiente apontando o arquivo de variáveis: 
```sh
# podman container run --rm --network=host -v $PWD:/app -w /app -it --entrypoint sh terraform-ansible
/app # echo ssh_key=[\"$(cat /root/.ssh/id_rsa.pub)\"] >> /app/terraform/.env
/app # cd terraform
/app/terraform # terraform init
/app/terraform # terraform plan -var-file=.env
/app/terraform # terraform apply -var-file=.env -auto-approve
```