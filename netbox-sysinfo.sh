# Field                         Required        Accessor        Description
# name                                  *               —                       Name
# status                                *                       —               Operational status of device
# role                                  —               name            Functional role
# cluster                               *               name            Assigned cluster
# tenant                                —               name            Assigned tenant
# platform                              —               name            Assigned platform
# vcpus                                 —               —                       VCPUs
# memory                                —               —                       Memory (MB)
# disk                                  —               —                       Disk (GB)
# comments                              —               —                       Comments
# cf_Access from:               —               —                       The hopping station/VDI this device is accessed from.
# cf_FQDN                               —               —                       Fqdn
# cf_Application                —               —                       Application
# cf_Environment                —               —                       Environment
# cf_Hypervisor                 —               —                       Hypervisor fqdn
# cf_Last updatedL              —               —                       Last updatedl
# cf_Product                    —               —                       Product
# cf_Service URL                —               —                       Service url
# cf_SNOW id                    —               —                       SNOW Incident, change, so on
# cf_SNOW Role                  —               —                       Snow role
# cf_OS version                 —               —                       Os version



vm_name="N/A"
vm_status="N/A"
vm_role="N/A"
vm_cluster="N/A"
vm_tenant="N/A"
vm_platform="N/A"
vm_vcpus="N/A"
vm_memory="N/A"
vm_disk="N/A"
vm_comments="N/A"
vm_cf_Access="N/A"
vm_cf_FQDN="N/A"
vm_cf_Application="N/A"
vm_cf_Environment="N/A"
vm_cf_Hypervisor="N/A"
vm_cf_Last="N/A"
vm_cf_Product="N/A"
vm_cf_Service="N/A"
vm_cf_SNOW="N/A"
vm_cf_SNOW="N/A"
vm_cf_OS="N/A"


vm_name=$(hostname -f)
if [[ -z "${vm_name}" ]]; then 
        vm_name=$(hostname)
fi

vm_status="active"
vm_role="Developer VM"
if [[ -f "/usr/bin/hostnamectl" ]]; then 
        vm_platform="$(hostnamectl | grep Virtualization)"
else
        vm_platform="virtualization: unknown"
fi
vm_cpus=$(cat /proc/cpuinfo  | grep processor | wc -l)
vm_memory=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
vm_disk=$(df -h | grep root | awk '{ print $2, $4}')
vm_cf_FQDN=$(hostname -A)

if [[ -f "/etc/redhat-release" ]]; then
        vm_cf_OS=$(cat /etc/redhat-release)
else 
        if [[ -f "/etc/os-release" ]]; then
                . /etc/os-release
                vm_cf_OS="${ID}"
        else 
                vm_cf_OS="unknown"
        fi
fi

echo "vm_name: ${vm_name}"
echo "vm_status: ${vm_status}"
echo "vm_role: ${vm_role}"
echo "vm_cluster: ${vm_cluster}"
echo "vm_tenant: ${vm_tenant}"
echo "vm_platform: ${vm_platform}"
echo "vm_vcpus: ${vm_vcpus}"
echo "vm_memory: ${vm_memory}"
echo "vm_disk: ${vm_disk}"
echo "vm_comments: ${vm_comments}"
echo "vm_cf_Access: ${vm_cf_Access}"
echo "vm_cf_FQDN: ${vm_cf_FQDN}"
echo "vm_cf_Application: ${vm_cf_Application}"
echo "vm_cf_Environment: ${vm_cf_Environment}"
echo "vm_cf_Hypervisor: ${vm_cf_Hypervisor}"
echo "vm_cf_Last: ${vm_cf_Last}"
echo "vm_cf_Product: ${vm_cf_Product}"
echo "vm_cf_Service: ${vm_cf_Service}"
echo "vm_cf_SNOW: ${vm_cf_SNOW}"
echo "vm_cf_SNOW: ${vm_cf_SNOW}"
echo "vm_cf_OS: ${vm_cf_OS}"
