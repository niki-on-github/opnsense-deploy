# OPNsense Deploy

Deploy OPNsense with kvm and pci passthrough via terraform.

## Process

1. Build custom iso with packer
2. Deploy custom iso with terraform
3. Let cloudinit apply your previous backup `config.xml`
